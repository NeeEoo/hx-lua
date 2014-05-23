#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

class Lua
{

	public static function run(script:String, ?context:Dynamic):Dynamic
	{
		return lua_execute(script, context);
	}

	private static function load(func:String, numArgs:Int)
	{
		#if neko
		loadNekoAPI();
		#end

		return Lib.load("lua", func, numArgs);
	}

	#if neko
	public static function loadNekoAPI()
	{
		var init = Lib.load("lua", "neko_init", 5);
		if (init != null)
		{
			init(function(s) return new String(s), function(len:Int) { var r = []; if (len > 0) r[len - 1] = null; return r; }, null, true, false);
		}
		else
			throw("Could not find NekoAPI interface.");
	}
	#end

	private static var lua_execute = load("lua_execute", 2);

}
