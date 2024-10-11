package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderLensCircle extends FlxShader
{
    @:glFragmentSource('
		#pragma header
		uniform float ratio;
		uniform vec2 origin;
		uniform float start;
		uniform float end;
		uniform float strength;
		uniform vec3 tint;
		uniform bool useRatio;

		float lensCircleCircle() // lol. made for debug but idc lol
		{
			vec2 uv = openfl_TextureCoordv.st;
			if(useRatio)
				uv.x *= ratio;
			float dist = distance(uv, origin * (useRatio ? vec2(ratio, 1.0) : vec2(1.0)));
			float lensStart = start;
			float lensEnd = end;
			if(end >= start)
			{
				lensStart = end + 0.001;
				lensEnd = start;
			}
			float circle = 1.0 - smoothstep(lensStart, lensEnd, dist);
			return circle;
		}

		vec4 lensCircle(vec4 col)
		{
			float circle = lensCircleCircle();
			col.rgb = mix(col.rgb, tint, circle * strength);
			col.a = mix(col.a, circle, circle * strength);
			return col;
		}
		
		void main()
		{
            vec2 uv = openfl_TextureCoordv.st;
			vec4 result = flixel_texture2D(bitmap, uv);

			gl_FragColor = lensCircle(result);
		}
    ')
	public function new()
	{
		super();
	}
}