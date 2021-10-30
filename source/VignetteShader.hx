package;

import flixel.system.FlxAssets.FlxShader;

class VignetteShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float radius;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;

			vec4 col = texture2D(bitmap, uv);

			vec2 uv2 = uv;
			uv2 *= 1.0 - uv2.yx;
			float vig = uv2.x*uv2.y;
			vig = pow(vig, radius);

			gl_FragColor = col*vig;
		}')
	public function new()
	{
		super();
	}
}