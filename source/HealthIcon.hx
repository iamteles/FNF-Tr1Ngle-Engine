package;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.util.FlxColor;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var isPlayer:Bool;
	public var isOldIcon:Bool;
	public var character:String;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = this.isOldIcon = false;
		this.character = "";
		this.isPlayer = isPlayer;
		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		this.isOldIcon = !this.isOldIcon;
		this.isOldIcon ? changeIcon("bf-old") : changeIcon("bf");
	}

	public function changeIcon(char:String)
	{
		if("bf-pixel" != char)
		{
			if("bf-old" != char)
			{
				char = char.split("-")[0];
			} 
		} 
		if(char != this.character){
			loadGraphic(Paths.image("icons/icon-" + char), true, 150, 150);
			animation.add(char, [0, 1], 0, false, this.isPlayer);
			animation.play(char);
			this.character = char;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
