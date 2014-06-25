package ;
import flixel.ui.FlxBar;
import Math;
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

    // 表示オブジェクト
    private var _txtSpeed:FlxText;
    private var _txtDistance:FlxText;
    private var _player:Player;

    // ゲージ
    private var _barSpeed:FlxBar;
    private var _barDistance:FlxBar;

    private var _objs:Array<FlxObject>;

    // ゴールまでの距離
    private var _goal:Int;
    private var _speedMax:Float;

    /**
     * コンストラクタ
     **/
    public function new(p:Player, goal:Int, speedMax:Float) {
        super();
        _player = p;
        _goal = goal;
        _speedMax = speedMax;

        _objs = new Array<FlxObject>();

        // テキスト
        var width = FlxG.width;
        var x = FlxG.width - 112;
        var y2 = 4;
        var y1 = FlxG.height-16;
        var dy = 12;
        _txtSpeed = new FlxText(x, y1, width);
        y1 += dy;
        _barSpeed = new FlxBar(x, y1-2, FlxBar.FILL_LEFT_TO_RIGHT, cast FlxG.width/3, 2);
        _txtDistance = new FlxText(x, y2, width);
        y2 += dy;
        _barDistance = new FlxBar(x, y2-2, FlxBar.FILL_LEFT_TO_RIGHT, cast FlxG.width/3, 2);
        _objs.push(_barSpeed);
        _objs.push(_barDistance);
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
        _txtSpeed.text = "Speed: " + Math.floor(_player.velocity.x);
        _txtDistance.text = "Distance: " + Math.floor(_player.x/10) + "/" + Math.floor(_goal/10);

        _barSpeed.percent = 100*_player.velocity.x / _speedMax;
        _barDistance.percent = 100*_player.x / _goal;
    }
}
