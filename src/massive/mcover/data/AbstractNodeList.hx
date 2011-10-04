package massive.mcover.data;

import massive.mcover.data.AbstractNode;
import massive.mcover.data.CoverageResult;

@:keep class AbstractNodeList extends AbstractNode
{
	var itemsById:IntHash<AbstractNode>;
	var items:Hash<Int>;
	var itemCount:Int;

	public function new()
	{
		super();
		itemCount = 0;
		itemsById = new IntHash();
		items = new Hash();
	}

	public function getItemByName(name:String, cls:Class<AbstractNode>):AbstractNode
	{
		if(!items.exists(name))
		{
			var item = Type.createInstance(cls, []);
			item.id = itemCount ++;
			item.name = name;
			items.set(name, item.id);
			itemsById.set(item.id, item);
		}
		return itemsById.get(items.get(name));
	}

	override public function lookupBranch(path:Array<Int>):Branch
	{
		var itemId = path.shift();
		if(itemId == null || !itemsById.exists(itemId)) return null;
		return itemsById.get(itemId).lookupBranch(path);
	}

	override public function lookupStatement(path:Array<Int>):Statement
	{
		var itemId = path.shift();
		if(itemId == null|| !itemsById.exists(itemId)) return null;
		return itemsById.get(itemId).lookupStatement(path);
	}


	override public function getMissingBranches():Array<Branch>
	{
		var a:Array<Branch> = [];
		for(node in itemsById)
		{
			var tmp = node.getMissingBranches();
			a = a.concat(tmp);
		}
		return a;
	}

	override public function getMissingStatements():Array<Statement>
	{
		var a:Array<Statement> = [];
		for(node in itemsById)
		{
			var tmp = node.getMissingStatements();
			a = a.concat(tmp);
		}
		return a;
	}

	override public function getClasses():Array<Clazz>
	{
		var a:Array<Clazz> = [];
		for(node in itemsById)
		{
			var tmp = node.getClasses();
			a = a.concat(tmp);
		}
		return a;
	}


	override public function getResults(?cache:Bool=true):CoverageResult
	{
		if(resultCache == null || !cache)
		{
			resultCache = emptyResult();
			for(node in itemsById)
			{
				var tmp = node.getResults();
				resultCache = appendResults(resultCache, tmp);
			}
		}

		return resultCache;
	}



	function appendResults(to:CoverageResult, from:CoverageResult):CoverageResult
	{
		to.sc += from.sc;
		to.s += from.s;
		to.bt += from.bt;
		to.bf += from.bf;
		to.bc += from.bc;
		to.b += from.b;
		to.mc += from.mc;
		to.m += from.m;
		to.cc += from.cc;
		to.c += from.c;	
		to.fc += from.fc;
		to.f += from.f;	
		to.pc += from.pc;
		to.p += from.p;	
		return to;
	}

	function hxSerialize( s : haxe.Serializer )
	{
        s.serialize(id);
        s.serialize(name);
        s.serialize(itemsById);
        s.serialize(items);
        s.serialize(itemCount);
     } 

    function hxUnserialize( s : haxe.Unserializer )
    {

 		id = s.unserialize();
        name = s.unserialize();
        itemsById = s.unserialize();
        items = s.unserialize();
        itemCount = s.unserialize();
    }

	
}