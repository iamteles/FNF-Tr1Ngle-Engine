package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderGrayscale extends FlxShader
{
    @:glFragmentSource('
		#pragma header

		uniform float val;
		uniform bool useLum;
		uniform vec3 tint;

		void main()
		{
            vec2 uv = openfl_TextureCoordv.st;
			vec4 col = flixel_texture2D(bitmap, uv);

			float grayscaleIntensity = (col.r + col.g + col.b) / 3.0;
			if(useLum)
				grayscaleIntensity = 0.21 * col.r + 0.71 * col.g + 0.07 * col.b;

			gl_FragColor = vec4(mix(col.rgb, vec3(grayscaleIntensity) * tint, val), col.a);
		}
    ')
	public function new()
	{
		super();
	}
}