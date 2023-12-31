import haxe.crypto.Md5;
import lime.utils.AssetLibrary;
import lime.utils.Assets as LimeAssets;
import funkin.backend.assets.ModsFolder;

import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.text.Font;
import haxe.io.Path;
import Reflect;
import lime.text.Font;
//import lime.utils.Bytes;

//import sys.FileStat;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesBuffer;

var replace = StringTools.replace;

if(!hasLibFunction) {
	__script__.variables.set("modName", "");
}

var template = "";
var _luaAsset = "";

function create() {
	this.prefix = "assets/";
	this.folderPath = ModsFolder.modsPath + ModsFolder.currentModFolder;
	modName = "lua-support";
	this.libName = "lua-support";

	template = File.getContent(this.folderPath + "/" + "template.hx");
}

function _getEditedTime(path) {
	return FileSystem.stat(path).mtime.getTime();
}

function __parseAsset(asset:String):Bool {
	if (!StringTools.startsWith(asset, prefix)) return false;
	_parsedAsset = asset.substr(prefix.length);

	if(hasLibFunction && ModsFolder.useLibFile) {
		var file = new Path(_parsedAsset);
		if(StringTools.startsWith(file.file, "LIB_")) {
			var library = file.file.substr(4);
			if(library != modName) return false;

			_parsedAsset = file.dir + "." + file.ext;
		}
	}

	_parsedAsset = replace(_parsedAsset, "//", "/");

	var file = new Path(_parsedAsset);
	if(file.ext == "lua") {
		file.ext = "hx";
		_luaAsset = _parsedAsset;
		_parsedAsset = file.dir + "/" + file.file + "." + file.ext;
		if(FileSystem.exists(getAssetPath())) {
			return true;
		}
	}

	return false;
}

function exists(asset, type) {
	return __parseAsset(asset);
}

function getBytes(id:String):Bytes {
	if (!exists(id, "BINARY"))
		return NULL;
	var path = getAssetPath();
	editedTimes[path] = _getEditedTime(path);
	//var e = Bytes.fromFile(path);

	var str = replace(template, "SCRIPT_PATH_TO_REPLACE", _luaAsset);

	return Bytes.ofString(str);
}

function __getFiles(folder:String, folders:Bool = false) {
	if (!StringTools.endsWith(folder, "/")) folder = folder + "/";
	if (__parseAsset(folder)) {
		var path = getAssetPath();
		try {
			var result:Array<String> = [];
			for(e in FileSystem.readDirectory(path))
				if (FileSystem.isDirectory('$path$e') == folders) {
					if(!folders) {
						var file = new Path(e);
						if(file.ext == "lua") {
							file.ext = "hx";
						}
						result.push(file.dir + "/" + file.file + "." + file.ext);
					} else {
						result.push(file);
					}
				}
			return result;
		} catch(e) {
			// woops!!
		}
	}
	return [];
}
