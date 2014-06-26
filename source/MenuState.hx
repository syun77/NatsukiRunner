package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

/**
 * タイトル画面
 */
class MenuState extends FlxState {

    private var _txtPress:FlxText;
    private var _timer:Int = 0;
    /**
	 * 生成
	 */
    override public function create():Void {
        super.create();
        var _txtTitle = new FlxText(0, 64, FlxG.width);
        _txtTitle.size = 24;
        _txtTitle.alignment = "center";
        _txtTitle.text = "Natsuki Runner";
        _txtPress = new FlxText(0, FlxG.height/2+24, FlxG.width);
        _txtPress.size = 16;
        _txtPress.alignment = "center";
        _txtPress.text = "click to start";
        var _txtCopy = new FlxText(0, FlxG.height-16, FlxG.width);
        _txtCopy.text = "(c)2014 Alpha Secret Base / 2dgames.jp";
        _txtCopy.alignment = "center";

        add(_txtTitle);
        add(_txtPress);
        add(_txtCopy);
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

        _timer++;
        _txtPress.visible = _timer%64 < 48;

        if(FlxG.mouse.justPressed) {
            FlxG.switchState(new PlayState());
        }
    }
}