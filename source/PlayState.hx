package;

import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.FlxObject;
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
    private var _rings:FlxTypedGroup<Ring>;

    // 変数
    private var _state:State;
    private var _timer:Int;

    // デバッグ用
    private var _cntRing:Int;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        // ゲームオブジェクト生成
        _player = new Player(FlxG.width/2, FlxG.height/2);
        add(_player);

        _rings = new FlxTypedGroup<Ring>(8);
        for(i in 0..._rings.maxSize) {
            _rings.add(new Ring());
        }
        add(_rings);

        // 変数初期化
        _state = State.Main;
        _timer = 0;

        _cntRing = 0;

        FlxG.debugger.toggleKeys = ["ALT"];
        FlxG.watch.add(this, "_cntVersiColor");
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

        switch(_state) {
        case State.Main: _updateMain();
        }
        _updateDebug();
    }

    /**
     * 更新・メイン
     **/
    private function _updateMain():Void {
        _timer++;
        if(_timer%60 == 1) {
            var v:Ring = _rings.recycle();
            if(v != null) {
                var px = FlxRandom.intRanged(0, FlxG.width);
                var py = FlxRandom.intRanged(0, FlxG.height);
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