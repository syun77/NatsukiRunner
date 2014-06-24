package ;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * ブロック
 **/
class Block extends FlxSprite {

    private var _attr:Attribute;

    /**
     * コンストラクタ
     **/
    public function new() {
        super();
        kill();
    }

    // 属性を取得
    public function getAttribute():Attribute { return _attr; }

    /**
     * 初期化
     **/
    public function init(attr:Attribute, px:Float, py:Float) {
        x = px;
        y = py;
        _attr = attr;
        var size = 8;
        if(attr == Attribute.Blue) {
            makeGraphic(size, size, FlxColor.BLUE);
        }
        else {
            makeGraphic(size, size, FlxColor.RED);
        }
    }

    /**
     * 消滅
     **/
    public function vanish():Void {
        kill();
    }

    /**
     * 更新
     **/
    override public function update():Void {

        if(isOnScreen() == false) {
            // 画面外に出た
            kill();
        }
    }
}
