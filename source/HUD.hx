package ;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * Head up display.
 **/
class HUD extends FlxGroup {

    private var _txtSpeed:FlxText;
    private var _txtDistance:FlxText;
    private var _player:Player;

    private var _objs:Array<FlxObject>;

    /**
     * コンストラクタ
     **/
    public function new(p:Player) {
        super();
        _player = p;

        _objs = new Array<FlxObject>();

        var width = FlxG.width;
        var x = 4;
        var y = 4;
        var dy = 12;
        _txtSpeed = new FlxText(x, y, width);
        y += dy;
        _txtDistance = new FlxText(x, y, width);
        _objs.push(_txtSpeed);
        _objs.push(_txtDistance);

        for(o in _objs) {
            // スクロール無効
            o.scrollFactor.set(0, 0);
            add(o);
        }
    }

    /**
     * 更新
     **/
    public function updateAll():Void {

        _txtSpeed.text = "Speed: " + _player.velocity.x;
        _txtDistance.text = "Distance: 0";
    }
}