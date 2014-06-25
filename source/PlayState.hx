package;

import flixel.util.FlxPoint;
import Attribute;
import Attribute;
import haxe.xml.Check.Attrib;
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
    Main;
}

/**
 * メインゲーム
 */
class PlayState extends FlxState {

    // 定数
    private static inline var SPEED_START:Float = 50;
    private static inline var BACK_SCROLL_SPEED:Float = 0.1;
    private static inline var SPEED_ADD:Float = 1;
    private static inline var SPEED_MISS:Float = 0.9;
    private static inline var SPEED_ADD_DEFAULT:Float = 0.01;

    // ゲームオブジェクト
    private var _player:Player;
    private var _follow:FlxSprite;
    private var _rings:FlxTypedGroup<Ring>;
    private var _blocks:FlxTypedGroup<Block>;

    // HUD
    private var _hud:HUD;

    // マップ
    private var _tmx:TmxLoader;

    // 背景
    private var _back:FlxSprite;
    private var _back2:FlxSprite;

    // 変数
    private var _state:State;
    private var _timer:Int;
    private var _speed:Float;
    private var _scrollX:Float = 0;

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
        _tmx.load("assets/levels/001.tmx");

        // ゲームオブジェクト生成
        _player = new Player(32, FlxG.height/2);
        add(_player);
        _follow = new FlxSprite(_player.x+FlxG.width/2, _player.y);
        _follow.visible = false;
        add(_follow);

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

        // 変数初期化
        _state = State.Main;
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
        _hud = new HUD(_player, width);
        add(_hud);

        // デバッグ用
        FlxG.debugger.toggleKeys = ["ALT"];
        FlxG.watch.add(this, "_cntRing");
        FlxG.watch.add(this, "_cntBlock");
        FlxG.watch.add(_player, "x");
        FlxG.watch.add(_player, "y");
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
        w += 8; // 広めに取る
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

    /**
     * 更新・メイン
     **/
    private function _updateMain():Void {

        _speed += SPEED_ADD_DEFAULT;

        _player.velocity.x = _speed;
        _follow.velocity.x = _speed;
        _follow.x = _player.x + FlxG.width/2-64;

        _scrollX -= BACK_SCROLL_SPEED;
        if(_scrollX < -FlxG.width) {
            _scrollX += FlxG.width;
        }
        _back.x = _scrollX;
        _back2.x = _scrollX + FlxG.width;

        // マップからオブジェクトを配置
        _putObjects();

        // 当たり判定
        FlxG.overlap(_player, _rings, _vsPlayerVersiColor, _collideCircle);
//        FlxG.collide(_player, _blocks, _vsPlayerBlock);
        FlxG.overlap(_player, _blocks, _vsPlayerBlock, _collideCircleBlock);
    }

    // プレイヤー vs 色変えアイテム
    private function _vsPlayerVersiColor(p:Player, v:Ring):Void {

        if(p.getAttribute() != v.getAttribute()) {
            // 色変え実行
            p.changeAttribute(v.getAttribute());
        }
        v.vanish();

    }

    // プレイヤー vs ブロック
    private function _vsPlayerBlock(p:Player, b:Block):Void {

        if(p.getAttribute() == b.getAttribute()) {
            _speed += 1;
        }
        else {
            _speed *= SPEED_MISS ;
            if(_speed < SPEED_START) {
                _speed = SPEED_START;
            }
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

        _cntRing = _rings.countLiving();
        _cntBlock = _blocks.countLiving();
    }
}