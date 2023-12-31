import funkin.backend.utils.NdllUtil;

var lua_create = NdllUtil.getFunction("lua", "lua_create", 0);
var lua_get_version = NdllUtil.getFunction("lua", "lua_get_version", 0);
var lua_call_function = NdllUtil.getFunction("lua", "lua_call_function", 3);
var lua_execute = NdllUtil.getFunction("lua", "lua_execute", 2);
var lua_load_context = NdllUtil.getFunction("lua", "lua_load_context", 2);
var lua_load_libs = NdllUtil.getFunction("lua", "lua_load_libs", 2);

function postCreate() {
	trace("Lua Version " + lua_get_version());

	trace(lua_run("return null"));
	trace(lua_run("return true"));
	trace(lua_run("return false"));
	trace(lua_run('return {"foo", true, 8.3, 6}'));
	trace(lua_run('return {foo = true, bar = 95}'));
	trace(lua_run('return {foo = {bar = {baz = 30}, foo = 99}, bar = {14, 52, 25, 1, 7}}'));
	trace(lua_run("return num", {num: 15, bar: 55}));
	trace(lua_run("return num", {num: 15.5}));
	trace(lua_run('return foo.bar', {foo: {bar: true}}));
	trace(lua_run("if arr[2] then return 1 else return 2 end", {
		arr: [false, true, false]
	}));
	trace(lua_run("return numfunc()", {numfunc: function() {
		return true;
	}}));
	trace(lua_run("return numfunc2(true, 1)", {
		numfunc2: function(a:Bool, b:Int) { return 15; }
	}));
	trace(lua_run('return greet(message)', {
		message: "hello world",
		greet: function(greeting:String) { return greeting; }
	}));

	trace("Testing Math");
	var lua = create_lua();
	lua.loadLibs(["math"]);
	trace(3, lua.execute("return math.floor(3.6)"));

	trace("testMultipleInstances");
	var l1 = create_lua(),
		l2 = create_lua();

	var context = {foo: 1};
	l1.setVars(context);

	trace(1, l1.execute("return foo"));

	// change the context for l2
	context.foo = 2;
	l2.setVars(context);

	trace(1, l1.execute("return foo"));
	trace(2, l2.execute("return foo"));

	// change foo on l1 but not l2
	context.foo = 3;
	l1.setVars(context);

	trace(3, l1.execute("return foo"));
	trace(2, l2.execute("return foo"));

	trace("testCallLuaFunction");
	var lua = create_lua();
		lua.execute("-- comment line
function add(a, b)
	return a + b
end

function sub(a, b)
	return a - b
end");

	trace(8, lua.call("add", [2, 6]));
	trace(29, lua.call("sub", [36, 7]));

	trace(null, lua.call("fail", 3)); // fails due to missing function
	trace(null, lua.call("sub", { fail: 3 })); // fails due to wrong number of arguments

	trace(lua.handle);
}

function create_lua() {
	var lua = new Lua();
	lua.self = lua;
	lua.create();
	return lua;
}

function lua_run(script:String, ?vars:Dynamic):Dynamic
{
	var lua = create_lua();
	lua.setVars(vars);
	return lua.execute(script);
}

class Lua
{
	var handle = null;
	var self = null;
	/**
	 * Creates a new lua vm state
	 */
	var create = function()
	{
		self.handle = lua_create();
	}

	/**
	 * Get the version string from Lua
	 */
	/*var version:String;
	private inline function get_version():String
	{
		return lua_get_version();
	}*/

	/**
	 * Loads lua libraries (base, debug, io, math, os, package, string, table)
	 * @param libs An array of library names to load
	 */
	var loadLibs = function(libs:Array<String>):Void
	{
		lua_load_libs(self.handle, libs);
	}

	/**
	 * Defines variables in the lua vars
	 * @param vars An object defining the lua variables to create
	 */
	var setVars = function(vars:Dynamic):Void
	{
		lua_load_context(self.handle, vars);
	}

	/**
	 * Runs a lua script
	 * @param script The lua script to run in a string
	 * @return The result from the lua script in Haxe
	 */
	var execute = function(script:String):Dynamic
	{
		return lua_execute(self.handle, script);
	}

	/**
	 * Calls a previously loaded lua function
	 * @param func The lua function name (globals only)
	 * @param args A single argument or array of arguments
	 */
	var call = function(func:String, args:Dynamic):Dynamic
	{
		return lua_call_function(self.handle, func, args);
	}
}

0;