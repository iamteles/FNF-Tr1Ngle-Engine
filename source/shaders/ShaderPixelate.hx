package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderPixelate extends FlxShader
{
    @:glFragmentSource('
		#pragma header
		uniform float xV;
		uniform float yV;
		void main()
		{
            vec2 uv = openfl_TextureCoordv;
			uv.x = floor(uv.x * xV) / xV;
			uv.y = floor(uv.y * yV) / yV;
			gl_FragColor = flixel_texture2D(bitmap, fract(uv));
		}
    ')
	public function new()
	{
		super();
	}
}