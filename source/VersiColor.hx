package ;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 色変えアイテム
 **/
class VersiColor extends FlxSprite {

    // 属性
    private var _attr:Attribute;

    public function new() {
        super(-100, -100);
        makeGraphic(16, 16, FlxColor.RED);
        kill();
    }

    // 属性の取得
    public function getAttribute():Attribute { return _attr; }
    /**
     * 初期化
     * @param attr 属性
     * @param px   X座標
     * @param py   Y座標
     **/
    public function init(attr:Attribute, px:Float, py:Float):Void {
        x = px;
        y = py;
        if(attr == Attribute.Red) {
            makeGraphic(16, 16, FlxColor.RED);
        }
        else {
            makeGraphic(16, 16, FlxColor.BLUE);
        }
        _attr = attr;
    }
}
