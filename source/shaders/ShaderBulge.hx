package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderBulge extends FlxShader
{
    @:glFragmentSource('
		#pragma header

		uniform float val;

		void main()
		{
            vec2 uv = clamp(openfl_TextureCoordv.st, 0.0, 1.0);
			

			vec2 og = uv - vec2(0.5);

			float radius = length(og);
			float a = atan(og.y, og.x);

			radius = pow(radius, val + 1.0);

			og = radius * vec2(cos(a), sin(a));

			og = clamp(og, -1.0, 1.0);

			uv = og + vec2(0.5);

			vec4 result = flixel_texture2D(bitmap, fract(uv));

			gl_FragColor = result;
		}
    ')
	public function new()
	{
		super();
	}
}