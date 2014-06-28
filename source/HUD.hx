package ;
import flixel.ui.FlxBar;
import Math;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * Head up display.
 **/
class HUD extends FlxGroup {

    // 表示オブジェクト
    private var _txtSpeed:FlxText;
    private var _txtDistance:FlxText;
    private var _txtLevel:FlxText;
    private var _player:Player;
    private var _txtCombo:FlxText;
    private var _txtCombo2:FlxText;

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
        _txtLevel = new FlxText(-8, y2, width);
        _txtLevel.text = Reg.getLevelName();
        _txtLevel.alignment = "right";
        _txtCombo = new FlxText(FlxG.width-72, FlxG.height-56, 64);
        _txtCombo.alignment = "center";
        _txtCombo2 = new FlxText(FlxG.width-56, FlxG.height-32, 80);
        _txtCombo2.text = "combo";
        _txtCombo2.visible = false;

        _objs.push(_barSpeed);
        _objs.push(_barDistance);
        _objs.push(_txtSpeed);
        _objs.push(_txtDistance);
        _objs.push(_txtLevel);
        _objs.push(_txtCombo);
        _objs.push(_txtCombo2);

        for(o in _objs) {
            // スクロール無効
            o.scrollFactor.set(0, 0);
            add(o);
        }
    }

    /**
     * コンボ数の設定
     **/
    public function setCombo(v:Int):Void {
        if(v == 0) {
            _txtCombo.visible = false;
            _txtCombo2.visible = false;
        }
        else {
            _txtCombo.visible = true;
            _txtCombo.text = "" + v;
            _txtCombo.size = 24;
            _txtCombo2.visible = true;
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

        if(_txtCombo.size > 16) {
            _txtCombo.size--;
        }
    }
}
