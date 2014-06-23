package ;
import haxe.xml.Check.Attrib;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * プレイヤー
 **/
class Player extends FlxSprite {

    // 定数
    private static inline var MOVE_DECAY = 0.9;
    private static inline var MOVE_REVISE = 5;

    // 変数
    private var _attr:Attribute; // 属性

    /**
     * 生成
     **/
    public function new(px:Float, py:Float) {
        super(px, py);

        loadGraphic("assets/images/player.png", true);

        animation.add("blue", [0]);
        animation.add("red", [1]);

        animation.play("blue");
        _attr = Attribute.Blue;
    }

    // 属性の取得
    public function getAttribute():Attribute { return _attr; }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        // マウスの座標に向かって移動する
        var mx = FlxG.mouse.x;
        var my = FlxG.mouse.y;

        var dx = mx - (x + width/2);
        var dy = my - (y + height/2);
        dx *= MOVE_DECAY * MOVE_REVISE;
        dy *= MOVE_DECAY * MOVE_REVISE;
        velocity.set(dx, dy);
    }


    /**
     * 属性チェンジ
     * @param 属性
     **/
    public function changeAttribute(attr:Attribute):Void {
        _attr = attr;
        var name:String = "blue";
        if(_attr == Attribute.Red) {
            name = "red";
        }
        animation.play(name);
    }

    /**
     * 属性を反転させる
     **/
    public function reverseAttribute():Void {

        if(_attr == Attribute.Blue) {
            changeAttribute(Attribute.Red);
        }
        else {
            changeAttribute(Attribute.Blue);
        }
    }
}
