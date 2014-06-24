package ;

import openfl.Assets;
import Layer2D;

class TmxLoader {
    private var _layers:Array<Layer2D>;
    private var _properties:Map<String, String>;
    private var _width:Int;
    private var _height:Int;
    private var _tileWidth:Int;
    private var _tileHeight:Int;
    public var width(get_width, null):Int;
    public var height(get_height, null):Int;
    public var tileWidth(get_tileWidth, null):Int;
    public var tileHeight(get_tileHeight, null):Int;

    public function new() {
    }

    /**
     * Tiled Map Editorファイルをロードする
     * @param filepath *.tmxファイルのパス
     * @return Layer2D
     **/
    public function load(filepath:String): Void {
        _layers = new Array<Layer2D>();
        _properties = new Map<String, String>();

        var tmx:String = Assets.getText(filepath);
        // mapノード
        var map:Xml = Xml.parse(tmx).firstElement();
        _width = Std.parseInt(map.get("width"));
        _height = Std.parseInt(map.get("height"));
        _tileWidth = Std.parseInt(map.get("tilewidth"));
        _tileHeight = Std.parseInt(map.get("tileheight"));

        for (child in map.elements()) {
            if (child.nodeName != "layer") { continue; }
            // layerノード
            var layer:Layer2D = new Layer2D();
            var width = Std.parseInt(child.get("width"));
            var height = Std.parseInt(child.get("height"));
            layer.initialize(width, height);
            for(gchild in child.elements()) {

                switch(gchild.nodeName) {
                case "properties":
                    for(prop in gchild.elements()) {
                        var name = prop.get("name");
                        var value = prop.get("value");
                        _properties.set(name, value);
                    }
                case "data":
                    var data:Xml = gchild;
                    // CSVノード
                    var csv:Xml = data.firstChild();

                    var text:String = csv.nodeValue;
                    var y:Int = 0;
                    for(line in text.split("\n")) {
                        if(line == "") { continue; }
                        var x:Int = 0;
                        for(str in line.split(",")) {
                            var val = Std.parseInt(str);
                            if(val > 0) {
                                layer.set(x, y, val);
                            }
                            x += 1;
                        }
                        y += 1;
                    }
                }
            }
            _layers.push(layer);
        }
    }

    public function getLayerCount():Int {
        return _layers.length;
    }

    public function getLayer(idx:Int):Layer2D {
        return _layers[idx];
    }

    public function getProperty(name:String):String {
        return _properties.get(name);
    }

    private function get_width() {
        return _width;
    }
    private function get_height() {
        return _height;
    }
    private function get_tileWidth() {
        return _tileWidth;
    }
    private function get_tileHeight() {
        return _tileHeight;
    }
}
