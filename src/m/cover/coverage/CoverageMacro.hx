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

package m.cover.coverage;

#if macro
import haxe.macro.Context;
import m.cover.MCover;
import m.cover.macro.PackageHelper;
import m.cover.macro.BuildMacro;
import m.cover.macro.IncludeMacro;
import m.cover.coverage.data.Coverage;
import m.cover.coverage.macro.CoverageBuildMacro;

class CoverageMacro implements IncludeMacro
{
	static public var coverage = new Coverage();
	static public var classPathHash:IntHash<String> = new IntHash();

	public var id(default, null):String;

	public function new()
	{
		id = "coverage";
	}

	public function initialize()
	{
		BuildMacro.registerParser(id, CoverageBuildMacro);
	}

	public function getClasses(?packages : Array<String>=null, ?classPaths : Array<String>=null, ?exclusions : Array<String>=null):Array<String>
	{
		if(packages ==  null || packages.length == 0) packages = [""];
		var helper = new PackageHelper();
		helper.ignoreClassMeta = "IgnoreCover";
		
		var classes = helper.include(classPaths, packages, exclusions);
		
		for(cp in classPaths)
		{
			classPathHash.set(Lambda.count(classPathHash), cp);
		}


		return classes;

	}

	/**
	* Inserts reference to all identified code coverage blocks into a haxe.Resource file called 'MCover'.
	* This resource is used by MCoverRunner to determine code coverage results
	*/
	public function onGenerate(types:Array<haxe.macro.Type>):Void
	{
		var serializedData = haxe.Serializer.run(CoverageMacro.coverage);
       	Context.addResource(MCoverage.RESOURCE_DATA, haxe.io.Bytes.ofString(serializedData));
	}
}

#end