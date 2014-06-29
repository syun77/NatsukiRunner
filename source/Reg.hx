package;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg {
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
}