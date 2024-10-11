package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderChromatic extends FlxShader
{
    @:glFragmentSource('
		#pragma header

		uniform float rXOff;
		uniform float rYOff;

		void main()
		{
            vec2 uv = clamp(openfl_TextureCoordv.st, 0.0, 1.0);
			vec4 result = flixel_texture2D(bitmap, fract(uv));
			
			result.r = flixel_texture2D(bitmap, fract(uv + vec2(rXOff, rYOff))).r;
			result.g = flixel_texture2D(bitmap, fract(uv + vec2(rXOff, rYOff) * 0.5)).g;

			gl_FragColor = result;
		}
    ')
	public function new()
	{
		super();
	}
}