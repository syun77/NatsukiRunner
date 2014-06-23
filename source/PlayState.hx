package;

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
    private var _versiColors:FlxTypedGroup<VersiColor>;

    // 変数
    private var _state:State;
    private var _timer:Int;

    // デバッグ用
    private var _cntVersiColor:Int;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        // ゲームオブジェクト生成
        _player = new Player(FlxG.width/2, FlxG.height/2);
        add(_player);

        _versiColors = new FlxTypedGroup<VersiColor>(8);
        for(i in 0..._versiColors.maxSize) {
            _versiColors.add(new VersiColor());
        }
        add(_versiColors);

        // 変数初期化
        _state = State.Main;
        _timer = 0;

        _cntVersiColor = 0;

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
            var v:VersiColor = _versiColors.recycle();
            if(v != null) {
                var px = FlxRandom.intRanged(0, FlxG.width);
                var py = FlxRandom.intRanged(0, FlxG.height);
                trace(px + "," + py);
                if(FlxRandom.chanceRoll()) {
                    v.init(Attribute.Red, px, py);
                }
                else {
                    v.init(Attribute.Blue, px, py);
                }
            }
        }
        // 当たり判定
        FlxG.collide(_player, _versiColors, _vsPlayerVersiColor);
    }

    // プレイヤー vs 色変えアイテム
    private function _vsPlayerVersiColor(p:Player, v:VersiColor):Void {

        if(p.getAttribute() != v.getAttribute()) {
            // 色変え実行
            p.changeAttribute(v.getAttribute());
        }
        v.kill();

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

        _cntVersiColor = _versiColors.countLiving();
    }
}