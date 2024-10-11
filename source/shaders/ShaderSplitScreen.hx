package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderSplitScreen extends FlxShader
{
    @:glFragmentSource('
		#pragma header
		uniform float col;
		uniform float row;
		void main()
		{
            vec2 uv = openfl_TextureCoordv.st;

			uv.x *= col;
    		uv.y *= row;
			
			uv = fract(uv);

			vec4 result = flixel_texture2D(bitmap, uv);

			gl_FragColor = result;
		}
    ')
	public function new()
	{
		super();
	}
}