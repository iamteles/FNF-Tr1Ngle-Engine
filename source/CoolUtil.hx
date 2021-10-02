package;

import lime.utils.Assets;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxSprite;

using StringTools;

class CoolUtil
{
	public static var images = [];
	public static var imagesPaths = [];
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

	public static function preloadImages(state:MusicBeatState)
	{
		FlxGraphic.defaultPersist = FlxG.save.data.preloadCharacters;
		#if cpp
		if (FlxG.save.data.preloadCharacters)
		{
			trace("caching images...");

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/images")))
			{
				//trace(i);
				if (!i.endsWith(".png"))
					continue;
				if(i.split(".")[1] == "png")
				{
					imagesPaths.push("assets/images/" + i);
					images.push(i.split(".")[0]);
				}
			}
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images")))
			{
				//trace(i);
				if (!i.endsWith(".png"))
					continue;
				if(i.split(".")[1] == "png")
				{
					imagesPaths.push("assets/shared/images/" + i);
					images.push(i.split(".")[0]);
				}
			}
			if(FileSystem.exists("assets/week" + PlayState.storyWeek + "/images"))
			{
				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/week" + PlayState.storyWeek + "/images")))
				{
					//trace(i);
					if (!i.endsWith(".png"))
						continue;
					if(i.split(".")[1] == "png")
					{
						imagesPaths.push("assets/week" + PlayState.storyWeek + "/images/" + i);
						images.push(i.split(".")[0]);
					}
				}
			}
			
		}
		#end

		//trace(images);
		if (FlxG.save.data.preloadCharacters)
		{

			for (i in 0 ... images.length) 
			{
				var sprite:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image(images[i]));
				sprite.visible = false;
		 	    state.add(sprite);
		 	    sprite.visible = false;
				if (!OpenFlAssets.cache.hasBitmapData(imagesPaths[i]))
				{
					OpenFlAssets.loadBitmapData(imagesPaths[i]);
				}
				//remove(sprite);
				sprite.visible = false;
			}

		}
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
