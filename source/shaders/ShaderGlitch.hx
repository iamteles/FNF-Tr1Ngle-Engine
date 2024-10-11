package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderGlitch extends FlxShader
{
    @:glFragmentSource('
		#pragma header

		uniform float bot;
		uniform float top;
		uniform float xOff;
		uniform vec2 rgOffset;

		bool inRange(float v, float bottom, float top) 
		{
			return (step(bottom, v) - step(top, v)) == 1.0;
		}

		void main()
		{
            vec2 uv = clamp(openfl_TextureCoordv.st, 0.0, 1.0);

			if(inRange(uv.y, bot, top))
				uv.x += xOff;

			vec4 result = flixel_texture2D(bitmap, fract(uv));
			result.r = flixel_texture2D(bitmap, fract(uv + rgOffset)).r;
			result.g = flixel_texture2D(bitmap, fract(uv + rgOffset * 0.5)).g;

			gl_FragColor = result;
		}
    ')
	public function new()
	{
		super();
	}
}