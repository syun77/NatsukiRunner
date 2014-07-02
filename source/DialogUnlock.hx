package ;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * アンロックダイアログ
 **/
class DialogUnlock extends FlxGroup {

    private var _frame:FlxSprite;
    private var _window:FlxSprite;
    private var _txt:FlxText;
    private var _btn:FlxButton;
    private var _objs:Array<FlxObject>;
    private var _bClose:Bool = false; // 閉じたかどうか

    /**
     * コンストラクタ
     * @param lv アンロックしたレベル
     **/
    public function new(lv:Int) {
        super();

        _objs = new Array<FlxObject>();

        var w = 120;
        var h = 60;
        var x = FlxG.width/2 - w/2;
        var y = FlxG.height/2 - h/2;
        _frame = new FlxSprite(x-2, y-2);
        _frame.makeGraphic(w+4, h+4, FlxColor.SILVER);
        _window = new FlxSprite(x, y);
        _window.makeGraphic(w, h, FlxColor.NAVY_BLUE);
        _txt = new FlxText(0, y + 20, FlxG.width);
        _txt.alignment = "center";
        _txt.text = "Unlock " + Reg.getLevelName(lv) + " mode.";
        _btn = new FlxButton(FlxG.width/2-40, y + 40, _cbOk);
        _btn.text = "OK";

        _objs.push(_frame);
        _objs.push(_window);
        _objs.push(_txt);
        _objs.push(_btn);

        for(o in _objs) {
            o.scrollFactor.set(0, 0);
            this.add(o);
        }
    }

    /**
     * ウィンドウを閉じたかどうか
     * @return 閉じたのであればtrue
     **/
    public function isClose():Bool {
        return _bClose;
    }

    /**
     * OKボタンを押した
     **/
    private function _cbOk():Void {
        _bClose = true;
    }
}
