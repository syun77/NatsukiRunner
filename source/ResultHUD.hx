package ;
import flixel.tweens.FlxEase;
import flixel.util.FlxAngle;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * リザルトメニュー
 **/
class ResultHUD extends FlxGroup {

    // 表示オブジェクト
    private var _back:FlxSprite;
    private var _txtTitle:FlxText;
    private var _txtBlock:FlxText;
    private var _txtRing:FlxText;
    private var _txtSpeed:FlxText;
    private var _txtCombo:FlxText;
    private var _txtTime:FlxText;
    private var _txtHp:FlxText;

    private var _objs:Array<FlxObject>;

    /**
     * コンストラクタ
     * @param cntRing リング獲得数
     * @param cntBlock ブロック破壊数
     * @param comboMax コンボ最大数
     * @parma hp 残りHP(0〜100)
     * @param pasttime 経過時間
     **/
    public function new(
        cntRing:Int,
        cntBlock:Int,
        comboMax:Int,
        hp:Int,
        pasttime:Int,
        speedMax:Float
    ) {
        super();
        _objs = new Array<FlxObject>();

        // 背景
        _back = new FlxSprite();
        _back.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        FlxTween.color(_back, 1, FlxColor.WHITE, FlxColor.WHITE, 0, 0.5);
        _objs.push(_back);

        // テキスト
        _txtTitle = new FlxText(0, -32, FlxG.width);
        _txtTitle.alignment = "center";
        _txtTitle.size = 24;
        _txtTitle.text = "Result";
        FlxTween.tween(_txtTitle, {y:8}, 1, {ease:FlxEase.expoOut});

        var x = FlxG.width;
        var y = FlxG.height/4;
        var dy = 16;
        var w = FlxG.width;
        _txtBlock = new FlxText(x, y, w, "Break Blocks: " + cntBlock);
        y += dy;
        _txtRing = new FlxText(x, y, w,  "Get Rings: " + cntRing);
        y += dy;
        _txtSpeed = new FlxText(x, y, w, "Max Speed: " + speedMax);
        y += dy;
        _txtCombo = new FlxText(x, y, w, "Max Combo: " + comboMax);
        y += dy;
        _txtTime = new FlxText(x, y, w,  "Time: " + pasttime);
        y += dy;
        _txtHp = new FlxText(x, y, w,    "HP: " + hp);
        y += dy;

        _objs.push(_txtTitle);
        _objs.push(_txtBlock);
        _objs.push(_txtRing);
        _objs.push(_txtSpeed);
        _objs.push(_txtCombo);
        _objs.push(_txtTime);
        _objs.push(_txtHp);

        var cnt:Int = 0;
        for(o in _objs) {
            if(Std.is(o, FlxText)) {
                var txt:FlxText = cast(o, FlxText);
                if(txt.text != "Result") {
                    cnt++;
                    var delay = 0.7 + 0.1 * cnt;
                    FlxTween.tween(txt, {x:FlxG.width/3 }, 0.7, {ease:FlxEase.expoOut, startDelay:delay});
                }
            }
            o.scrollFactor.set(0, 0);
            this.add(o);
        }
    }
}
