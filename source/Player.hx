package ;
import flixel.FlxSprite;

/**
 * プレイヤー
 **/
class Player extends FlxSprite {
    public function new(px:Float, py:Float) {
        super(px, py);

        loadGraphic("assets/images/player.png", true);

        animation.add("blue", [0]);
        animation.add("red", [1]);

        animation.play("blue");
    }
}
