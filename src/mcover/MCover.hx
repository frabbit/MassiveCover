/****
* Copyright 2012 Massive Interactive. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Massive Interactive.
****/

package mcover;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import mcover.macro.ClassParser;
import mcover.coverage.macro.CoverageMacroDelegate;
import mcover.logger.macro.LoggerMacroDelegate;
import mcover.macro.MacroDelegate;

#if haxe_208
	import neko.io.File;
	import neko.Sys;
	import neko.FileSystem;
#else
	import sys.io.File;
	import sys.FileSystem;
#end

/**
MCover provides a collection of macro based tools for measuring code quality and behavior.

To enable code coverage

	--macro mcover.MCover.coverage(['package.name'],['sourcePath'], ['ignored patterns'])

To enable function entry/exit logging
	
	--macro mcover.MCover.logger(['package.name'],['sourcePath'], ['ignored patterns'])

*/
@:keep class MCover
{
	/** 
	Configures MCover for code coverage
	
	From the command line/hxml add a macro reference:
		--macro mcover.MCover.coverage(['package.name'], ['src'], null)
	
	@param packages 	array of packages to include (e.g. "com.example") (defaults to all [""])
	@param classPaths 	array of classpaths to search in (defaults to local scope only [''])
	@param exclusions 	array of qualified class names to exclude (supports '*' wildcard patterns)
	*/
	public static function coverage(?packages : Array<String>=null, ?classPaths : Array<String>=null, ?exclusions : Array<String>=null)	
	{	delegateClasses.push(CoverageMacroDelegate);
		include(packages, classPaths, exclusions);
	}

	/** 
	Configures MCover for function logging
	
	From the command line/hxml add a macro reference:
		--macro mcover.MCover.logger(['package.name'], ['src'], null)
	
	@param packages 	array of packages to include (e.g. "com.example") (defaults to all [""])
	@param classPaths 	array of classpaths to search in (defaults to local scope only [''])
	@param exclusions 	array of qualified class names to exclude (supports '*' wildcard patterns)
	*/
	public static function logger(?packages : Array<String>=null, ?classPaths : Array<String>=null, ?exclusions : Array<String>=null)
	{	delegateClasses.push(LoggerMacroDelegate);
		include(packages, classPaths, exclusions);
	}

	public static var TEMP_DIR:String = ".temp/mcover/";
	static var delegateClasses:Array<Class<MacroDelegate>> = [];
	static var delegates:Array<MacroDelegate> = [];
	static var delegatesById:Hash<MacroDelegate> = new Hash();

	/** 
	Includes classes within multiple classpaths and/or packages.
	Adds @:build(mcover.macro.ClassParser.build()) to included classes.
	
	@param packages 	array of packages to include (e.g. "com.example") (defaults to all [""])
	@param classPaths 	array of classpaths to search in (defaults to local scope only [''])
	@param exclusions 	array of qualified class names to exclude (supports '*' wildcard patterns)
	*/
	static function include(?packages : Array<String>=null, ?classPaths : Array<String>=null, ?exclusions : Array<String>=null)
	{	
		var temp = TEMP_DIR.split("/");

		var path = "";
		
		while(temp.length > 0)
		{	
			var part = temp.shift();
			if(part == "" && temp.length == 0) break;

			path += part;

			if(!FileSystem.exists(path)) FileSystem.createDirectory(path);

			path += "/";
		}

		Console.removePrinter(Console.defaultPrinter);
		Console.addPrinter(new FilePrinter(TEMP_DIR + "mcover.log"));
		Console.start();

		if(exclusions == null) exclusions = [];

		classPaths = convertToFullPaths(classPaths);

		for(delegateClass in delegateClasses)
		{
			var delegate = Type.createInstance(delegateClass, []);
			delegates.push(delegate);
			delegatesById.set(delegate.id, delegate);
		}

		var classMacroHash:Hash<Array<String>> = new Hash();

		for(delegate in delegates)
		{
			var classHash = delegate.filterClasses(packages, classPaths, exclusions);

			for(cls in classHash.keys())
			{
				
				var args:Array<String> = null;

				if(classMacroHash.exists(cls)) args = classMacroHash.get(cls);
				else args = [];

				if(classHash.get(cls) == true) args.push(delegate.id);

				classMacroHash.set(cls, args);
			}
		}

		if(Lambda.count(classMacroHash)==0)
		{
			Context.warning("No classes match criteria in MCover macro:\n	packages: " + packages + ",\n	classPaths: " + classPaths + ",\n	exclusions: " + exclusions, Context.currentPos());
		}
		
		for(cls in classMacroHash.keys())
		{
			var args = classMacroHash.get(cls);

			if(args.length > 0)
			{
				var argsString = "[\"" + args.join("\",\"") + "\"]";
				Compiler.addMetadata("@:build(mcover.MCover.build(" + argsString + "))", cls);
				Compiler.keep(cls, null, true);//ignored in haxe 2_0_8
			}
			else
			{
				exclusions.push(cls);
			}
		}

		trace("Excluding: " + exclusions);

		for(pack in packages)
		{
			Compiler.include(pack, true, exclusions, classPaths);
		}

		haxe.macro.Context.onGenerate(onGenerate);
	}

	static function convertToFullPaths(paths:Array<String>)
	{
		var fullPaths:Array<String> = [];

		for(path in paths)
		{
			fullPaths.push(FileSystem.fullPath(path));	
		}
		return fullPaths;
	}

	/**
	Per class build macro.
	Loops through delegate ids and adds matching ExpressionParsers to the ClassParser

	@param ids 	Array of MacroDelegagte ids for including in this class build
	@return updated array of fields for the class
	*/
	@:macro public static function build(ids:Array<String>):Array<Field>
	{
		var classParser = new ClassParserImpl(); 

		for(id in ids)
		{
			if(!delegatesById.exists(id))
			{
				Context.error("Unknown macro id: " + id, Context.currentPos());
			}
			var delegate = delegatesById.get(id);
			var parserClass = delegate.getExpressionParser();


			if(parserClass != null)
			{
				var parser = Type.createInstance(parserClass, []);
				classParser.addExpressionParser(parser);
			}
		}
		try
		{
			var fields = classParser.parseFields();
			return fields;
		}
		catch(e:Exception)
		{
			trace(e);
			Sys.sleep(.1);
			Context.error("Exception parsing class: " + e, Context.currentPos());
		}

		return null;
		
		
	}
	
	/**
	Generate method for macro.Context.
	Loops through all registered include macros and calls their generate method.
	
	@param types 		macro types passed through from the compiler
	*/
	static function onGenerate(types:Array<haxe.macro.Type>):Void
	{
		for(instance in delegates)
		{
			instance.generate(types);
		}
	}


}


class FilePrinter extends mconsole.FilePrinter
{

	public function new(path:String)
	{
		if(FileSystem.exists(path))
			FileSystem.deleteFile(path);
		super(path);
	}

	/**
	Fiters out any logs outside of current package.
	*/
	override public function print(level: mconsole.LogLevel, params:Array<Dynamic>, indent:Int, pos:haxe.PosInfos):Void
	{
		if(StringTools.startsWith(pos.className, "mcover"))
			super.print(level, params, indent, pos);
	}

}


#end

