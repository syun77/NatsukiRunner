package;

import spinehx.SkeletonData;
import DefaultAssetLibrary;
import flixel.addons.editors.spine.FlxSpine;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAngle;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import Attribute;
import Attribute;
import flixel.util.FlxRect;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
    Start;          // 開始演出
    Main;           // メイン
    ChangeWait;     // 色変え演出中
    StageClearInit; // ステージクリア・初期化
    StageClearMain; // ステージクリア・メイン
    GameoverInit;   // ゲームオーバー・初期化
    GameoverMain;   // ゲームオーバー・メイン
}

/**
 * メインゲーム
 */
class PlayState extends FlxState {

    // 定数
    private static inline var BACK_SCROLL_SPEED:Float = 0.1; // 背景スクロールの速さ
    private static inline var SPEED_START:Float = 50; // 開始時の速さ
    private static inline var SPEED_ADD:Float = 1; // ブロック衝突による速度の上昇
    private static inline var SPEED_MISS:Float = 0.9; // 異なるブロック衝突による速度の低下
    private static inline var SPEED_ADD_DEFAULT:Float = 0.3; // デフォルトでの速度上昇
    private static inline var SPEED_DEFAULT_MAX:Float = 100; // デフォルトでの速度上昇制限
    private static inline var SPEED_MAX:Float = 384; // 最大速度
    private var POS_SPINE_START_X:Float;
    private var POS_SPINE_START_Y:Float;

    // タイマー
    private static inline var TIMER_STAGE_CLEAR_INIT = 30;
    private static inline var TIMER_GAMEOVER_INIT = 30;
    private static inline var TIMER_CHANGE_WAIT = 100;
    private static inline var TIMER_DAMAGE = 30;

    // ゲームオブジェクト
    private var _player:Player;
    private var _barHp:FlxBar;
    private var _follow:FlxSprite;
    private var _rings:FlxTypedGroup<Ring>;
    private var _blocks:FlxTypedGroup<Block>;

    // エフェクト
    private var _eftPlayer:FlxSprite;
    private var _emitterBlockBlue:EmitterBlockBlue;
    private var _emitterBlockRed:EmitterBlockRed;

    // Spine
    private var _spineStart:FlxSpine;

    // メッセージ
    private var _txtMessage:FlxText;

    // HUD
    private var _hud:HUD;

    // マップ
    private var _tmx:TmxLoader;

    // 背景
    private var _back:FlxSprite;
    private var _back2:FlxSprite;

    // 変数
    private var _state:State; // 状態
    private var _timer:Int;   // 汎用タイマー
    private var _speed:Float; // 速度
    private var _scrollX:Float = 0; // スクロール
    private var _tDamage:Int   = 0; // ダメージによるペナルティ時間
    private var _combo:Int     = 0; // コンボ数

    // デバッグ用
    private var _cntRing:Int;
    private var _cntBlock:Int;

    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();

        // 背景
        _back = new FlxSprite(0, 0);
        _back.loadGraphic("assets/images/back.png");
        _back.scrollFactor.set(0, 0);
        add(_back);
        _back2 = new FlxSprite(FlxG.width, 0);
        _back2.loadGraphic("assets/images/back.png");
        _back2.scrollFactor.set(0, 0);
        add(_back2);

        // マップ読み込み
        _tmx = new TmxLoader();
        var fTmx = "assets/levels/" + TextUtil.fillZero(Reg.level, 3) + ".tmx";
        _tmx.load(fTmx);

        // ゲームオブジェクト生成
        _player = new Player(32, FlxG.height/2);
        add(_player);
        _follow = new FlxSprite(_player.x+FlxG.width/2, _player.y);
        _follow.visible = false;
        add(_follow);
        _barHp = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, 32, 2);
        _barHp.visible = false;
        add(_barHp);
        _player.setHpBar(_barHp);

        // リング
        _rings = new FlxTypedGroup<Ring>(8);
        for(i in 0..._rings.maxSize) {
            _rings.add(new Ring());
        }
        add(_rings);

        // ブロック
        _blocks = new FlxTypedGroup<Block>(512);
        for(i in 0..._blocks.maxSize) {
            _blocks.add(new Block());
        }
        add(_blocks);

        // エフェクト
        _eftPlayer = new FlxSprite();
        _eftPlayer.loadGraphic("assets/images/player.png", true);
        _eftPlayer.animation.add("blue", [0]);
        _eftPlayer.animation.add("red", [1]);
        _eftPlayer.kill();
        add(_eftPlayer);

        // Spine
        var data = FlxSpine.readSkeletonData("skeleton", "assets/spine/start/");
        POS_SPINE_START_X = FlxG.width/2+16;
        POS_SPINE_START_Y = FlxG.height/2;
        _spineStart = new FlxSpine(data, POS_SPINE_START_X-20, POS_SPINE_START_Y);
        _spineStart.flipY = true;
        _spineStart.scrollFactor.set(0, 0);
        add(_spineStart);
        _spineStart.state.setAnimationByName("3", false);

        // パーティクル
        _emitterBlockBlue = new EmitterBlockBlue();
        _emitterBlockRed = new EmitterBlockRed();
        add(_emitterBlockBlue);
        add(_emitterBlockRed);

        // テキスト
        _txtMessage = new FlxText(0, FlxG.height/2-12, FlxG.width);
        _txtMessage.size = 24;
        _txtMessage.alignment = "center";
        _txtMessage.visible = false;
        _txtMessage.scrollFactor.set(0, 0);
        add(_txtMessage);

        // 変数初期化
        _state = State.Start;
        _timer = 0;
        _speed = SPEED_START;

        _cntRing = 0;
        _cntBlock = 0;

        var width = _tmx.width * _tmx.tileWidth;
        var height = _tmx.height * _tmx.tileHeight;
        FlxG.camera.follow(_follow, FlxCamera.STYLE_NO_DEAD_ZONE);
        FlxG.camera.bounds = new FlxRect(0, 0, width, height);
        FlxG.worldBounds.set(0, 0, width, height);

        // HUD
        _hud = new HUD(_player, width, SPEED_MAX);
        add(_hud);

        // デバッグ用
        FlxG.debugger.toggleKeys = ["ALT"];
        FlxG.watch.add(this, "_cntRing");
        FlxG.watch.add(this, "_cntBlock");
        FlxG.watch.add(_player, "x");
        FlxG.watch.add(_player, "y");
        FlxG.watch.add(_player, "_hp");
        FlxG.watch.add(FlxG.camera.scroll, "x");
        FlxG.watch.add(this, "_state");
        FlxG.watch.add(this, "_timer");
    }

    /**
     * コンポ数を増やす
     **/
    private function _addCombo():Void {
        _combo++;
        _hud.setCombo(_combo);
    }

    /**
     * コンボ数をリセット
     **/
    private function _resetCombo():Void {
        _combo = 0;
        _hud.setCombo(_combo);
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
            case State.Start: _updateStart();
            case State.Main: _updateMain();
            case State.ChangeWait: _updateChangeWait();
            case State.StageClearInit: _updateStageClearInit();
            case State.StageClearMain: _updateStageClearMain();
            case State.GameoverInit: _updateGameoverInit();
            case State.GameoverMain: _updateGameoverMain();
        }

        // デバッグ処理
        _updateDebug();
    }

    private function _setActiveAll(b:Bool):Void {
        _follow.active = b;
        _player.active = b;
        _blocks.active = b;
        _rings.active = b;
    }

    /**
     * 色変えエフェクト再生開始
     **/
    private function _startChangeWait():Void {
        _state = State.ChangeWait;
        _timer = TIMER_CHANGE_WAIT;
        _eftPlayer.revive();
        _eftPlayer.x = _player.x;
        _eftPlayer.y = _player.y;
        _eftPlayer.alpha = 1;
        _eftPlayer.scale.set(1, 1);

        _setActiveAll(false);
    }

    /**
     * 現在の視界に対応するオブジェクトを配置する
     **/
    private function _putObjects():Void {

        // ブロックの生成
        var createBlock = function(i, j, type:Attribute) {
            var x = i * _tmx.tileWidth;
            var y = j * _tmx.tileHeight;
            var b:Block = _blocks.recycle();
            b.init(type, x, y);
        }
        // リングの生成
        var createRing = function(i, j, type:Attribute) {
            var x = i * _tmx.tileWidth - (32/2) - (_tmx.tileWidth/2);
            var y = j * _tmx.tileHeight - (32/2) - (_tmx.tileHeight/2);
            var r:Ring = _rings.recycle();
            r.init(type, x, y);
        }

        var layer:Layer2D = _tmx.getLayer(0);
        var px = Math.floor(FlxG.camera.scroll.x / _tmx.tileWidth);
        var w = Math.floor(FlxG.width / _tmx.tileWidth);
        w += 8; // 検索範囲を広めに取る
        for(j in 0..._tmx.height) {
            for(i in px...(px+w)) {
                switch(layer.get(i, j)) {
                    case 1: // 青ブロック
                        createBlock(i, j, Attribute.Blue);
                        layer.set(i, j, 0);
                    case 2: // 赤ブロック
                        createBlock(i, j, Attribute.Red);
                        layer.set(i, j, 0);
                    case 3: // 青リング
                        createRing(i, j, Attribute.Blue);
                        layer.set(i, j, 0);
                    case 4: // 赤リング
                        createRing(i, j, Attribute.Red);
                        layer.set(i, j, 0);
                }
            }
        }
    }

    private function _setFolloPosition():Void {

        // カメラがフォローするオブジェクトの位置を調整
        var diffSpeed = SPEED_MAX - _speed;
        var dx:Float = 0;
        if(diffSpeed > 0) {
            diffSpeed = SPEED_MAX - diffSpeed;
            dx = 64 * Math.cos(FlxAngle.TO_RAD * 90 * diffSpeed / SPEED_MAX);
        }
        _follow.x = _player.x + FlxG.width/2 - dx;
    }

    /**
     * 各種スクロール処理
     **/
    private function _updateScroll():Void {
        if(_tDamage > 0) {
            // ダメージペナルティ
            _tDamage--;
        }
        else {
            if(_speed < SPEED_DEFAULT_MAX) {
                // デフォルトのスクロール速度上昇
                _speed += SPEED_ADD_DEFAULT;
            }
        }

        // プレイヤーをスクロールする
        _player.velocity.x = _speed;
        _follow.velocity.x = _speed;

        _setFolloPosition();

        // 背景をスクロールする
        _scrollX -= BACK_SCROLL_SPEED;
        if(_scrollX < -FlxG.width) {
            // 折り返す
            _scrollX += FlxG.width;
        }
        _back.x = _scrollX;
        _back2.x = _scrollX + FlxG.width;

        // ピンチチェック
        if(_back.color != FlxColor.WHITE) {
            _back.color = FlxColor.WHITE;
            _back2.color = FlxColor.WHITE;
        }
        if(_player.isDanger()) {
            // 背景を赤くする
            _back.color = FlxColor.RED;
            _back2.color = FlxColor.RED;
        }

    }

    /**
     * 更新・スタート
     **/
    private function _updateStart():Void {
        _setFolloPosition();
        if(_spineStart.state.isComplete()) {
            switch(_timer) {
                case 0:
                    _spineStart.state.setAnimationByName("2", false);
                    _timer++;
                case 1:
                    _spineStart.state.setAnimationByName("1", false);
                    _timer++;
                case 2:
                    _spineStart.state.setAnimationByName("go", false);
                    _state = State.Main;
            }
        }
    }

    /**
     * 更新・メイン
     **/
    private function _updateMain():Void {

        if(_spineStart.exists) {
            _spineStart.x = POS_SPINE_START_X + FlxG.camera.scroll.x;
            _spineStart.y = POS_SPINE_START_Y + FlxG.camera.scroll.y;
            if(_spineStart.state.isComplete()) {
                _spineStart.kill();
            }
        }

        // スクロール処理
        _updateScroll();

        // クリア判定
        if(FlxG.camera.scroll.x >= _tmx.width * _tmx.tileWidth - FlxG.width) {
            // クリア
            _state = State.StageClearInit;
            _timer = TIMER_STAGE_CLEAR_INIT;
            _txtMessage.text = "Stage Clear!";
            _txtMessage.visible = true;
            return;
        }
        if(_player.isDead()) {
            // プレイヤー死亡
            _player.vanish();
            _barHp.kill();
            _follow.kill();
            _state = State.GameoverInit;
            _timer = TIMER_GAMEOVER_INIT;
            // 画面を1秒間、白フラッシュします
            FlxG.camera.flash(0xffFFFFFF, 1);
            // 画面を5%の揺れ幅で0.35秒間、揺らします
            FlxG.camera.shake(0.05, 0.35);
            _txtMessage.text = "Game Over...";
            _txtMessage.visible = true;
            return;
        }

        // マップからオブジェクトを配置
        _putObjects();

        // 当たり判定
        FlxG.overlap(_player, _rings, _vsPlayerRing, _collideCircle);
        FlxG.overlap(_player, _blocks, _vsPlayerBlock, _collideCircleBlock);
    }

    private function _updateChangeWait():Void {
        _timer = cast(_timer * 0.9);
        _eftPlayer.alpha = 1.0 * _timer / TIMER_CHANGE_WAIT;
        var sc:Float = 1.0 + 2.0 * (TIMER_CHANGE_WAIT - _timer) / TIMER_CHANGE_WAIT;
        _eftPlayer.scale.set(sc, sc);
        if(_timer < 1) {
            _setActiveAll(true);
            _eftPlayer.kill();
            _state = State.Main;
        }
    }
    /**
     * ステージクリア
     **/
    private function _updateStageClearInit():Void {
        _timer--;
        if(_timer < 1) {
            _state = State.StageClearMain;
        }
    }
    private function _updateStageClearMain():Void {
        if(_player.x > _tmx.width * _tmx.tileWidth) {
            _player.active = false;
        }
        if(FlxG.mouse.justPressed) {
            FlxG.switchState(new MenuState());
        }
    }

    /**
     * ゲームオーバー
     **/
    private function _updateGameoverInit():Void {
        _timer--;
        if(_timer < 1) {
            _state = State.GameoverMain;
        }
    }
    private function _updateGameoverMain():Void {
        if(FlxG.mouse.justPressed) {
            FlxG.switchState(new MenuState());
        }
    }

    // プレイヤー vs 色変えアイテム
    private function _vsPlayerRing(p:Player, v:Ring):Void {

        if(p.getAttribute() != v.getAttribute()) {
            // 色変え実行
            p.changeAttribute(v.getAttribute());
        }
        v.vanish();

        _startChangeWait();

    }

    // プレイヤー vs ブロック
    private function _vsPlayerBlock(p:Player, b:Block):Void {

        if(p.getAttribute() == b.getAttribute()) {
            // スピードアップ
            _speed += SPEED_ADD;
            // HP回復
            _player.addHp();
            // コンボ数アップ
            _addCombo();
        }
        else {
            // ペナルティ
            _speed *= SPEED_MISS ;
            if(_speed < SPEED_START) {
                _speed = SPEED_START;
            }
            _tDamage = TIMER_DAMAGE;

            // ダメージ処理
            _player.damage();
            // コンボ終了
            _resetCombo();
        }

        if(b.getAttribute() == Attribute.Red) {
            _emitterBlockRed.explode(b.x, b.y);
        }
        else {
            _emitterBlockBlue.explode(b.x, b.y);
        }
        b.vanish();
    }

    /**
     * 円同士で当たり判定をする
     **/
    private function _collideCircle(spr1:FlxSprite, spr2:FlxSprite):Bool {

        var r1 = spr1.width/2;
        var r2 = spr2.width/2;
        var px1 = spr1.x + r1;
        var py1 = spr1.y + r1;
        var px2 = spr2.x + r2;
        var py2 = spr2.y + r2;
        var p1 = FlxPoint.get(px1, py1);
        var p2 = FlxPoint.get(px2, py2);
        var dist = FlxMath.getDistance(p1, p2);
        if(r1*r1 + r2*r2 >= dist*dist) {
            return true;
        }
        return false;
    }

    /**
     * プレイヤーとブロックの当たり判定
     **/
    private function _collideCircleBlock(p:Player, b:Block):Bool {

        var r1 = p.width/2;
        if(p.getAttribute() == b.getAttribute()) {
            // 同じ属性なら大きめに取る
            r1 = p.width * 0.6;
        }
        var r2 = b.width/2;
        var px1 = p.x + r1;
        var py1 = p.y + r1;
        var px2 = b.x + r2;
        var py2 = b.y + r2;
        var p1 = FlxPoint.get(px1, py1);
        var p2 = FlxPoint.get(px2, py2);
        var dist = FlxMath.getDistance(p1, p2);
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

        if(FlxG.keys.justPressed.R) {
            FlxG.resetState();
        }

        if(FlxG.keys.pressed.RIGHT) {
            // 右キーでスピードアップ
            _speed += 10;
        }
        if(FlxG.keys.pressed.LEFT) {
            // 左キーでスピードダウン
            _speed -= 10;
            if(_speed < SPEED_START) {
                _speed = SPEED_START;
            }
        }
        if(FlxG.keys.justPressed.D) {
            // 自爆
            _player.damage(99999);
        }

        _cntRing = _rings.countLiving();
        _cntBlock = _blocks.countLiving();
    }
}