var path = "SCRIPT_PATH_TO_REPLACE";

var lua_create = NdllUtil.getFunction("lua", "lua_create", 0);
var lua_get_version = NdllUtil.getFunction("lua", "lua_get_version", 0);
var lua_call_function = NdllUtil.getFunction("lua", "lua_call_function", 3);
var lua_execute = NdllUtil.getFunction("lua", "lua_execute", 2);
var lua_load_context = NdllUtil.getFunction("lua", "lua_load_context", 2);
var lua_load_libs = NdllUtil.getFunction("lua", "lua_load_libs", 2);
var register_hxtrace_func = NdllUtil.getFunction("lua", "register_hxtrace_func", 1);
var register_hxtrace_lib = NdllUtil.getFunction("lua", "register_hxtrace_lib", 1);

trace("Lua Version: " + lua_get_version());

var lastStackID:Int = 0;
var stack:Map<Int, Dynamic> = [];
var luaCallbacks:Map<String, Dynamic> = [];

var lua = null;

//lua_load_libs(lua, ["base", "debug", "io", "math", "os", "package", "string", "table"]);
function new() {
	lua = lua_create();
	register_hxtrace_func((st) -> trace(st));
	register_hxtrace_lib(lua);
	lua_load_context(lua, {

	});

	luaCallbacks["__onPointerIndex"] = onPointerIndex;
	luaCallbacks["__onPointerNewIndex"] = onPointerNewIndex;
	luaCallbacks["__onPointerCall"] = onPointerCall;
	luaCallbacks["__gc"] = onGarbageCollection;

	/*state.newmetatable("__funkinMetaTable");

	state.pushstring('__index');
	state.pushcfunction(cpp.Callable.fromStaticFunction(__index));
	state.settable(-3);

	state.pushstring('__newindex');
	state.pushcfunction(cpp.Callable.fromStaticFunction(__newindex));
	state.settable(-3);

	state.pushstring('__call');
	state.pushcfunction(cpp.Callable.fromStaticFunction(__call));
	state.settable(-3);

	state.setglobal("__funkinMetaTable");*/

	lua_execute(lua, Assets.getText(path));
}

var callbackReturnVariables = [];

function call(name:String, args:Dynamic) {
	lua_call_function(lua, name, args);
}

/*function onCall(funcName:String, args:Array<Dynamic>):Dynamic {
	state.settop(0);
	state.getglobal(funcName);

	if (state.type(-1) != Lua.LUA_TFUNCTION)
		return null;

	for (k=>val in args)
		pushArg(val);

	if (state.pcall(args.length, 1, 0) != 0) {
		this.error('${state.tostring(-1)}');
		return null;
	}

	var v = fromLua(state.gettop());
	state.settop(0);
	return v;
}*/

/*
public override function set(variable:String, value:Dynamic) {
	pushArg(value);
	state.setglobal(variable);
}

https://github.com/FNF-CNE-Devs/CodenameEngine/blob/lua-test/source/funkin/scripting/LuaScript.hx
*/

function create() {
	call("create", []);
}

function postCreate() {
	call("postCreate", []);
}

function update(elapsed) {
	call("update", [elapsed]);
}

function postCreate(elapsed) {
	call("postCreate", [elapsed]);
}