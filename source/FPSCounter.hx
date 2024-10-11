package;
import flixel.FlxG;
import flixel.math.FlxMath;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
class FPSCounter extends TextField
{
	private var times:Array<Float>;

	public function new(x:Float = 10.0, y:Float = 10.0) 
	{
		super();
		this.x = x;
		this.y = y;
		selectable = false;
		defaultTextFormat = new TextFormat("_sans", 14, FlxColor.WHITE);

		times = [];
		addEventListener(Event.ENTER_FRAME, onEnter);
		autoSize = LEFT;
		multiline = true;
		mouseEnabled = false;
	}

	private function onEnter(_)
	{	
		var now = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		var fps:Int = times.length;
		if (fps > FlxG.updateFramerate)
			fps = FlxG.updateFramerate;
		var mem:Float = Math.abs(Math.round(System.totalMemory / 1024 / 1024 * 100) / 100);
		var memInfo = (FlxG.save.data.mem ? "RAM: " + formatMemory(mem) : "");
		if (visible)
		{	
			text = 
			"FPS: " + fps + "\n"
			+ memInfo + "\n";
		}
	}

	// author @DiogoTVV
	function formatMemory(memory:Float):String
	{
		var unit:String = "MB";
		if(memory >= 1024)
		{
			unit = "GB";
			memory /= 1024;
		}
		memory = Math.floor(memory * 100) / 100;
		
		return '$memory $unit';
	}
}