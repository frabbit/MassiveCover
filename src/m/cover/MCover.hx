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

package m.cover;

#if macro
import haxe.macro.Context;

class MCover
{
	/**
	Depricated.
	Provides backwards compatibility with older version of munit.
	*/
	public static function coverage(?packages : Array<String>=null, ?classPaths : Array<String>=null, ?exclusions : Array<String>=null)	
	{
		deprecated("Please update to mcover.MCover.coverage()");
		mcover.MCover.coverage(packages, classPaths, exclusions);
	}

	public static function logger(?packages : Array<String>=null, ?classPaths : Array<String>=null, ?exclusions : Array<String>=null)
	{	
		deprecated("Please update to mcover.MCover.logger()");
		mcover.MCover.logger(packages, classPaths, exclusions);
	}
	

	/**
	Prints a compiler warning indicating a method or class is deprecated.
	*/
	@:macro static public function deprecated(message:String) 
	{
		var clazz:String = haxe.macro.Context.getLocalClass().get().name;
		var method:String = haxe.macro.Context.getLocalMethod();

		var location:String = clazz;

		if(method != "new") location += "." + method;

		haxe.macro.Context.warning(location + " is deprecated. " + message, haxe.macro.Context.currentPos());

		return haxe.macro.Context.makeExpr("@deprecated", haxe.macro.Context.currentPos());
	}
}
#end