package;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
import flixel.util.FlxSave;
import flixel.FlxG;
class Reg {

    // 初期タイム
    private static var TIME_INIT = (59 * 60 * 1000) + (59 * 1000) + 999;

    // BGM無効フラグ
    private static var _bBgmDisable = true;
//    private static var _bBgmDisable = false;

    // レベル
	public static var level:Int = 2;
    // スコア
	public static var score:Int = 0;

    // セーブデータ
    private static var _save:FlxSave = null;

    private static function _getSave():FlxSave {
        if(_save == null) {
            _save = new FlxSave();
            _save.bind("SAVEDATA");
        }
        if(_save.data == null) {
            // データがなければ初期化
            _save.data.scores = new Array<Int>();
            _save.data.times = new Array<Int>();
            for(i in 0...4) {
                _save.data.scores.push(0);
                _save.data.times.push(TIME_INIT);
            }
        }

        return _save;
    }

    public static function getHiScore(lv:Int = -1):Void {
        var s = _getSave();
        if(lv < 0) {
            lv = level;
        }

        return s.data.scores[lv];
    }

    public static function getTime(lv:Int = -1):Void {
        var s = _getSave();
        if(lv < 0) {
            lv = level;
        }

        return s.data.times[lv];
    }

    public static function save():Void {
        var s = _getSave();

    }

    /**
     * 難易度に対応する名前を取得する
     **/
    public static function getLevelName():String {
        switch(level) {
            case 1: return "Easy";
            case 2: return "Normal";
            case 3: return "Hard";
            default: return "None";
        }
    }

    /**
     * レベル数値を文字列に変換する
     **/
    public static function getLevelString():String {

        // 3桁の0埋めの数値
        return TextUtil.fillZero(level, 3);
    }

    public static function cacheMusic():Void {
        FlxG.sound.volume = 1;

        FlxG.sound.cache("001");
        FlxG.sound.cache("002");
        FlxG.sound.cache("003");
        FlxG.sound.cache("gameover");
    }

    public static function playMusic(name:String, bLoop:Bool=true):Void {

        if(_bBgmDisable) {
            // BGM無効
            return;
        }

        var sound = FlxG.sound.cache(name);
        if(sound != null) {
            FlxG.sound.playMusic(sound, 1, bLoop);
        }
        else {
            FlxG.sound.playMusic(name, 1, bLoop);
        }
    }
}