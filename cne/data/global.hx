
import funkin.backend.assets.ScriptedAssetLibrary;
import funkin.backend.assets.ModsFolder;

static var hasLibFunction = Reflect.hasField(ModsFolder, "useLibFile");

Paths.assetsTree.addLibrary(new ScriptedAssetLibrary("lua-support", []));