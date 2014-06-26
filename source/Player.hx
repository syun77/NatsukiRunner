package ;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.addons.effects.FlxTrail;
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
    private static inline var HP_MAX = 100;
    private static inline var HP_RECOVER = 1; // デフォルトのHP回復量
    private static inline var TIMER_DAMAGE = 60;
    private static inline var DAMAGE_INIT = 2; // 初期ダメージ
    private static inline var DAMAGE_MAX = 40; // 最大ダメージ
    private static inline var DAMAGE_CNT = 32; // 最大ダメージに到達するまでの連続ヒット数
    private static inline var DANGER_RATIO = 0.3; // 危険状態とするHPの残量

    // 変数
    private var _attr:Attribute; // 属性
    private var _trailBlue:FlxTrail; // ブラー(青)
    private var _trailRed:FlxTrail; // ブラー(赤)
    private var _hp:Float; // 体力
    private var _tDamage:Int; // ダメージタイマー
    private var _barHp:FlxBar; // 体力バー
    private var _cntHit:Int; // 蓄積ダメージ数
    private var _tAnime:Int; // アニメ用タイマー

    /**
     * 生成
     **/
    public function new(px:Float, py:Float) {
        super(px, py);

        loadGraphic("assets/images/player.png", true);

        animation.add("blue", [0]);
        animation.add("red", [1]);

        _attr = Attribute.Blue;
        immovable = true;

        animation.play("red");
        _trailRed = new FlxTrail(this);
        FlxG.state.add(_trailRed);
        _trailRed.kill();

        animation.play("blue");
        _trailBlue = new FlxTrail(this);
        FlxG.state.add(_trailBlue);

        _hp = HP_MAX;
        _tDamage = 0;
        _cntHit = 0;
        _tAnime = 0;
    }

    // 属性の取得
    public function getAttribute():Attribute { return _attr; }
    // HPの割合の取得
    public function getHpRatio():Float { return 1.0 * _hp / HP_MAX; }
    // 死亡しているかどうか
    public function isDead():Bool { return _hp <= 0; }
    // HPバー
    public function setHpBar(bar:FlxBar) { _barHp = bar; }

    /**
     * 更新
     **/
    override public function update():Void {
        super.update();

        // マウスの座標に向かって移動する
        var p = FlxG.mouse.getWorldPosition();

        var dx = p.x - (x + width/2);
        var dy = p.y - (y + height/2);
        dx *= MOVE_DECAY * MOVE_REVISE;
        dy *= MOVE_DECAY * MOVE_REVISE;
//        velocity.set(dx, dy);
        velocity.y = dy;

        // ダメージタイマー
        if(_tDamage > 0) {
            visible = _tDamage%4 < 2;
            _tDamage--;
        }

        _tAnime++;
        // ピンチ状態の更新
        if(color != FlxColor.WHITE) {
            color = FlxColor.WHITE;
        }
        if(getHpRatio() < DANGER_RATIO) {
            if(_tAnime%24 < 12) {
                color = FlxColor.RED;
            }
        }

        // 体力バーの更新
        if(_hp == HP_MAX) {
            _barHp.visible = false;
        }
        else {
            _barHp.visible = true;
            _barHp.percent = getHpRatio() * 100;
            _barHp.x = x;
            _barHp.y = y + 24;
        }
    }

    /**
     * HP回復
     **/
    public function addHp(v:Float=HP_RECOVER):Void {
        _hp += v;
        _hp = if(_hp > HP_MAX) HP_MAX else _hp;
    }

    /**
     * ダメージ処理
     * @param v ダメージ量
     **/
    public function damage(v:Int=DAMAGE_INIT):Void {

        if(_tDamage > 0) {
            // 連続ダメージなのでペナルティ
            var diff:Float = (DAMAGE_MAX - DAMAGE_INIT) / DAMAGE_CNT;
            var val = v + diff * _cntHit;
            _hp -= val;
            _cntHit++;
        }
        else {
            // 初期ダメージ
            _hp -= v;
            _tDamage = TIMER_DAMAGE;
            _cntHit = 1;
        }
        _hp = if(_hp < 0) 0 else _hp;
    }


    /**
     * 属性チェンジ
     * @param 属性
     **/
    public function changeAttribute(attr:Attribute):Void {
        _attr = attr;
        var name:String = "blue";
        _trailBlue.kill();
        _trailRed.kill();
        if(_attr == Attribute.Red) {
            name = "red";
            _trailRed.revive();
        }
        else {
            _trailBlue.revive();
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
