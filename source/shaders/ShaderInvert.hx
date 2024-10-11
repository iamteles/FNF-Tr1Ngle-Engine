package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderInvert extends FlxShader
{
    @:glFragmentSource('
		#pragma header
		uniform vec4 val;
		void main()
		{
            vec2 uv = openfl_TextureCoordv.st;
			vec4 col = flixel_texture2D(bitmap, uv);

			vec3 color = col.rgb;

			color.r = val.r - color.r;
			color.g = val.g - color.g;
			color.b = val.b - color.b;

			gl_FragColor = vec4(mix(col.rgb, color, val.a), col.a);
		}
    ')
	public function new()
	{
		super();
	}
}