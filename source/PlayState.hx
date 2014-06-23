package;

import flixel.util.FlxRect;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
    Main;
}

/**
 * メインゲーム
 */
class PlayState extends FlxState {

    // ゲームオブジェクト
    private var _player:Player;
    private var _follow:FlxSprite;
    private var _rings:FlxTypedGroup<Ring>;

    // HUD
    private var _hud:HUD;

    // 変数
    private var _state:State;
    private var _timer:Int;
    private var _speed:Float;

    // デバッグ用
    private var _cntRing:Int;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        // ゲームオブジェクト生成
        _player = new Player(32, FlxG.height/2);
        add(_player);
        _follow = new FlxSprite(_player.x+FlxG.width/2, _player.y);
        _follow.visible = false;
        add(_follow);

        _rings = new FlxTypedGroup<Ring>(8);
        for(i in 0..._rings.maxSize) {
            _rings.add(new Ring());
        }
        add(_rings);

        // 変数初期化
        _state = State.Main;
        _timer = 0;
        _speed = 10;

        _cntRing = 0;

        var width = 1280*100;
        var height = FlxG.height;
        FlxG.camera.follow(_follow, FlxCamera.STYLE_NO_DEAD_ZONE);
        FlxG.camera.bounds = new FlxRect(0, 0, width, height);
        FlxG.worldBounds.set(0, 0, width, height);

        // HUD
        _hud = new HUD(_player);
        add(_hud);

        // デバッグ用
        FlxG.debugger.toggleKeys = ["ALT"];
        FlxG.watch.add(this, "_cntRing");
        FlxG.watch.add(_player, "x");
    }

    /**
	 * 破棄
	 */
    override public function destroy():Void {
        super.destroy();
    }

    /**
	 * 更新
	 */
    override public function update():Void {
        super.update();
        _hud.updateAll();

        switch(_state) {
        case State.Main: _updateMain();
        }
        _updateDebug();
    }

    /**
     * 更新・メイン
     **/
    private function _updateMain():Void {

        _player.velocity.x = _speed;
        _follow.velocity.x = _speed;
        _follow.x = _player.x + FlxG.width/2;

        _timer++;
        if(_timer%60 == 1) {
            var v:Ring = _rings.recycle();
            if(v != null) {
                var px:Float = FlxRandom.intRanged(0, FlxG.width);
                var py:Float = FlxRandom.intRanged(0, FlxG.height);
                px += FlxG.camera.scroll.x;
                py += FlxG.camera.scroll.y;
                if(FlxRandom.chanceRoll()) {
                    v.init(Attribute.Red, px, py);
                }
                else {
                    v.init(Attribute.Blue, px, py);
                }
            }
        }
        // 当たり判定
        FlxG.overlap(_player, _rings, _vsPlayerVersiColor, _collideCircle);
        //FlxG.collide(_player, _rings, _vsPlayerVersiColor);
    }

    // プレイヤー vs 色変えアイテム
    private function _vsPlayerVersiColor(p:Player, v:Ring):Void {

        if(p.getAttribute() != v.getAttribute()) {
            // 色変え実行
            p.changeAttribute(v.getAttribute());
        }
        v.kill();

    }

    /**
     * 円同士で当たり判定をする
     **/
    private function _collideCircle(spr1:FlxSprite, spr2:FlxSprite):Bool {

        var r1 = spr1.width;
        var r2 = spr2.width;
        var dist = FlxMath.distanceBetween(spr2, spr1);
        if(r1*r1 + r2*r2 >= dist*dist) {
            return true;
        }
        return false;
    }

    /**
     * 更新・デバッグ
     **/
    private function _updateDebug():Void {
        if(FlxG.keys.justPressed.ESCAPE) {
            throw "Terminate.";
        }

        if(FlxG.keys.justPressed.SPACE) {
            _player.reverseAttribute();
        }

        _cntRing = _rings.countLiving();
    }
}