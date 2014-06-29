package;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
import flixel.FlxG;
class Reg {
    // BGM無効フラグ
    private static var _bBgmDisable = true;
//    private static var _bBgmDisable = false;

    // レベル
	public static var level:Int = 2;
    // スコア
	public static var score:Int = 0;
    // ハイスコア
    public static var hiscore:Int = 0;

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