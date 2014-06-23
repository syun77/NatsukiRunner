package ;
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
}
