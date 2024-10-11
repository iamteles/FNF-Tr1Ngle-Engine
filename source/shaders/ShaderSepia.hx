package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderSepia extends FlxShader
{
    @:glFragmentSource('
		#pragma header
		uniform float val;
		vec4 sepia(vec4 col)
		{
			const vec3 sepiaCol = vec3(1.0, 0.95, 0.82);
			float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));

			vec3 sepiaA = vec3(grey);
			sepiaA *= sepiaCol;

			return vec4(mix(col.rgb, sepiaA, val), col.a);
		}
		void main()
		{
            vec2 uv = openfl_TextureCoordv.st;
			vec4 result = flixel_texture2D(bitmap, uv);

			gl_FragColor = sepia(result);
		}
    ')
	public function new()
	{
		super();
	}
}