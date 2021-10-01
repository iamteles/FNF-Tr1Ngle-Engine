package;

import lime.utils.Assets;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function smoothColorChange(from:FlxColor, to:FlxColor, speed:Float = 0.045):FlxColor
	{

	    var result:FlxColor = FlxColor.fromRGBFloat
	    (
	        CoolUtil.coolLerp(from.redFloat, to.redFloat, speed), //red

	        CoolUtil.coolLerp(from.greenFloat, to.greenFloat, speed), //green

	        CoolUtil.coolLerp(from.blueFloat, to.blueFloat, speed) //blue
	    );

	    return result;

	   

	}
	
	public static function camLerpShit(a:Float):Float
	{
		return FlxG.elapsed / 0.016666666666666666 * a;
	}
	public static function coolLerp(a:Float, b:Float, c:Float):Float
	{
		return a + CoolUtil.camLerpShit(c) * (b - a);
	}
}
