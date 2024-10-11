package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderHue extends FlxShader
{
    @:glFragmentSource('
		#pragma header

		uniform float angle;

		vec4 hue(vec4 col)
		{
			const vec3 k = vec3(0.57735, 0.57735, 0.57735);
    		vec3 color = col.rgb;
    		return vec4(color * cos(angle) + cross(k, color) * sin(angle) + k * dot(k, color) * (1.0 - cos(angle)), col.a);
		}
		void main()
		{
            vec2 uv = openfl_TextureCoordv.st;
			vec4 col = flixel_texture2D(bitmap, uv);

			gl_FragColor = hue(col);
		}
    ')
	public function new()
	{
		super();
	}
}