package;

import flixel.FlxGame;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import shaders.*;
import flixel.FlxObject;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.FlxG;

class Shaders extends FlxObject
{
	public static var effects:Array<String> = 
	[
		"Glitch",
		"Chromatic",
		"LensCircle",
		"Bulge",
		"Grayscale",
		"Sepia",
		"Invert",
		"Hue",
		"SplitScreen",
		"Pixelate"
	];
	public static var easings:Array<String> =
	[
		"linear",
		"expoIn",
		"expoOut",
		"expoInOut",
		"elasticIn",
		"elasticOut",
		"elasticInOut",
		"circIn",
		"circOut",
		"circInOut",
		"bounceIn",
		"bounceOut",
		"bounceInOut",
		"backIn",
		"backOut",
		"backInOut"
	];
	public var glitch:ShaderFilter = new ShaderFilter(new ShaderGlitch());
	public var chromatic:ShaderFilter = new ShaderFilter(new ShaderChromatic());
	public var lensCircle:ShaderFilter = new ShaderFilter(new ShaderLensCircle());
	public var bulge:ShaderFilter = new ShaderFilter(new ShaderBulge());
	public var bulgeHUD:ShaderFilter = new ShaderFilter(new ShaderBulge());
	public var grayscale:ShaderFilter = new ShaderFilter(new ShaderGrayscale());
	public var sepia:ShaderFilter = new ShaderFilter(new ShaderSepia());
	public var invert:ShaderFilter = new ShaderFilter(new ShaderInvert());
	public var hue:ShaderFilter = new ShaderFilter(new ShaderHue());
	public var splitScreen:ShaderFilter = new ShaderFilter(new ShaderSplitScreen());
	public var pixelate:ShaderFilter = new ShaderFilter(new ShaderPixelate());
	public var pixelateHUD:ShaderFilter = new ShaderFilter(new ShaderPixelate());

	public var gameFilters:Array<BitmapFilter> = [];
	public var hudFilters:Array<BitmapFilter> = [];
	
	// chromatic
	var chromatic_rXOffset:Float = 0;
	var chromatic_rYOffset:Float = 0;
	var chromatic_rand:Bool = false;

	// bulge
	var bulge_val:Float = 0;

	// glitch
	var glitch_maxXOff:Float = 0;
	var glitch_maxColOff:Float = 0;
	var glitch_sliceHeight:Float = 0;
	var glitch_intervalSec:Float = 0;
	var glitch_timer:Float = 0;

	// grayscale
	var grayscale_tintR:Float = 1;
	var grayscale_tintG:Float = 1;
	var grayscale_tintB:Float = 1;
	var grayscale_val:Float = 0;
	var grayscale_useLum:Bool = false;

	// hue
	var hue_h:Float = 0;

	// invert
	var invert_val:Float = 0;
	var invert_valR:Float = 1;
	var invert_valG:Float = 1;
	var invert_valB:Float = 1;

	// lensCircle
	var lensCircle_originX:Float = 0.5;
	var lensCircle_originY:Float = 0.5;
	var lensCircle_start:Float = 1.0;
	var lensCircle_end:Float = 0.5;
	var lensCircle_strength:Float = 0.0;
	var lensCircle_tintR:Float = 0.0;
	var lensCircle_tintG:Float = 0.0;
	var lensCircle_tintB:Float = 0.0;
	var lensCircle_useRatio:Bool = true;

	// sepia
	var sepia_val:Float = 0.0;

	// splitScreen
	var splitScreen_colMod:Float = 1.0;
	var splitScreen_rowMod:Float = 1.0;

	// pixelate
	var pixelate_xV:Float = 1280.0;
	var pixelate_yV:Float = 720.0;

	public function new()
	{
		super();
		applyEffects();
	}
	function applyEffects()
	{
		gameFilters.push(chromatic);
		hudFilters.push(chromatic);

		gameFilters.push(bulge);
		hudFilters.push(bulgeHUD);

		gameFilters.push(glitch);
		hudFilters.push(glitch);

		gameFilters.push(grayscale);
		hudFilters.push(grayscale);

		gameFilters.push(hue);
		hudFilters.push(hue);

		gameFilters.push(invert);

		//gameFilters.push(lensCircle); // no need to
		hudFilters.push(lensCircle);

		gameFilters.push(sepia);
		hudFilters.push(sepia);

		gameFilters.push(splitScreen);
		hudFilters.push(splitScreen);

		gameFilters.push(pixelate);
		hudFilters.push(pixelateHUD);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Chromatic
		if(chromatic_rand)
		{
			chromatic_rXOffset = FlxG.random.int(1,5) / 1000;
			chromatic_rYOffset = FlxG.random.int(1,5) / 1000;
			chromatic.shader.data.rXOff.value = [chromatic_rXOffset];
			chromatic.shader.data.rYOff.value = [chromatic_rYOffset];
		}
		else
		{
			chromatic.shader.data.rXOff.value = [chromatic_rXOffset / 250.0];
			chromatic.shader.data.rYOff.value = [chromatic_rYOffset / 250.0];
		}
		
		// Bulge
		bulge.shader.data.val.value = [bulge_val];
		bulgeHUD.shader.data.val.value = [bulge_val / 2.5];


		// Glitch
		glitch_timer += elapsed;
		if(glitch_timer > glitch_intervalSec)
		{
			glitch_timer = 0;
			var h:Float = FlxG.random.float(0, 1);
			glitch.shader.data.xOff.value = [FlxG.random.float(-glitch_maxXOff, glitch_maxXOff)];
			glitch.shader.data.rgOffset.value = [FlxG.random.float(-glitch_maxColOff, glitch_maxColOff) / 50.0, FlxG.random.float(-glitch_maxColOff, glitch_maxColOff) / 50.0];
			glitch.shader.data.bot.value = [h - glitch_sliceHeight];
			glitch.shader.data.top.value = [h];
		}

		// Grayscale
		grayscale.shader.data.val.value = [grayscale_val];
		grayscale.shader.data.useLum.value = [grayscale_useLum];
		grayscale.shader.data.tint.value = [grayscale_tintR, grayscale_tintG, grayscale_tintB];

		// Hue
		hue.shader.data.angle.value = [hue_h * 0.0174533];

		// Invert
		invert.shader.data.val.value = [invert_valR, invert_valG, invert_valB, invert_val];

		// Lens Circle
		lensCircle.shader.data.ratio.value = [FlxG.width / FlxG.height];
		lensCircle.shader.data.origin.value = [lensCircle_originX, lensCircle_originY];
		lensCircle.shader.data.start.value = [lensCircle_start];
		lensCircle.shader.data.end.value = [lensCircle_end];
		lensCircle.shader.data.strength.value = [lensCircle_strength];
		lensCircle.shader.data.tint.value = [lensCircle_tintR / 255.0, lensCircle_tintG / 255.0, lensCircle_tintB / 255.0];
		lensCircle.shader.data.useRatio.value = [lensCircle_useRatio];

		// Sepia
		sepia.shader.data.val.value = [sepia_val];

		// Split Screen
		splitScreen.shader.data.col.value = [splitScreen_colMod];
		splitScreen.shader.data.row.value = [splitScreen_rowMod];

		// Pixelate
		pixelate.shader.data.xV.value = [pixelate_xV];
		pixelate.shader.data.yV.value = [pixelate_yV];

		pixelateHUD.shader.data.xV.value = [pixelate_xV];
		pixelateHUD.shader.data.yV.value = [pixelate_yV];
	}
	public function triggerChromatic(rand:Bool = true, ?xOff:Float = 0, ?yOff:Float = 0, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		chromatic_rand = rand;
		if(!rand){
			if(duration != 0)
				FlxTween.tween(this, {chromatic_rXOffset: xOff, chromatic_rYOffset: yOff}, duration, {ease: Reflect.field(FlxEase, easing)});
			else
			{
				chromatic_rXOffset = xOff;
				chromatic_rYOffset = yOff;
			}
				
		}
	}
	public function triggerBulge(val:Float = 0, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {bulge_val: val}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			bulge_val = val;
		}
	}
	public function triggerGlitch(maxXOff:Float = 0, maxColOff:Float = 0, sliceHeight:Float = 0, intervalS:Float = 0.1, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {glitch_maxXOff: maxXOff, glitch_maxColOff: maxColOff, glitch_sliceHeight: sliceHeight, glitch_intervalSec: intervalS}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			glitch_maxXOff = maxXOff;
			glitch_maxColOff = maxColOff;
			glitch_sliceHeight = sliceHeight;
			glitch_intervalSec = intervalS;
		}
	}
	public function triggerGrayscale(val:Float = 0, useLum:Bool = false, tintR:Float = 1, tintG:Float = 1, tintB:Float = 1, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {grayscale_val: val, grayscale_tintR: tintR, grayscale_tintG: tintG, grayscale_tintB: tintB}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			grayscale_val = val; 
			grayscale_tintR = tintR;
			grayscale_tintG = tintG;
			grayscale_tintB = tintB;
		}
		grayscale_useLum = useLum;
	}
	public function triggerHue(h:Float = 0, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {hue_h: h}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			hue_h = h;
		}
	}
	public function triggerInvert(r:Float = 1, g:Float = 1, b:Float = 1, v:Float = 0, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {invert_valR: r, invert_valG: g, invert_valB: b, invert_val: v}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			invert_valR = r;
			invert_valG = g;
			invert_valB = b;
			invert_val = v;
		}
	}
	public function triggerLensCircle(uR:Bool = true, r:Float = 0, g:Float = 0, b:Float = 0, s:Float = 0, oX:Float = 0, oY:Float = 0, start:Float = 1, end:Float = 0.5, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {lensCircle_tintR: r, lensCircle_tintG: g, lensCircle_tintB: b, lensCircle_strength: s, lensCircle_originX: oX*0.5+0.5, lensCircle_originY: oY*0.5+0.5, lensCircle_start: start, lensCircle_end: end}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			lensCircle_tintR=r;
			lensCircle_tintG=g;
			lensCircle_tintB=b;
			lensCircle_strength=s;
			lensCircle_originX=oX*0.5+0.5;
			lensCircle_originY=oY*0.5+0.5;
			lensCircle_start=start;
			lensCircle_end=end;
		}
		lensCircle_useRatio = uR;
	}
	public function triggerSepia(val:Float = 0, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {sepia_val: val}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			sepia_val = val;
		}
	}
	public function triggerSplitScreen(col:Float = 1, row:Float = 1, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {splitScreen_colMod: col, splitScreen_rowMod: row}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			splitScreen_colMod = col;
			splitScreen_rowMod = row;
		}
	}
	public function triggerPixelate(xv:Float = 1280, yv:Float = 720, ?duration:Float = 0.5, ?easing:String = "linear") 
	{
		if(duration != 0)
			FlxTween.tween(this, {pixelate_xV: xv, pixelate_yV: yv}, duration, {ease: Reflect.field(FlxEase, easing)});
		else
		{
			pixelate_xV = xv;
			pixelate_yV = yv;
		}
	}
}