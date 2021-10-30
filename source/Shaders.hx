package;

import openfl.display.Shader;
import openfl.filters.ShaderFilter;

class Shaders
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var vignette:ShaderFilter = new ShaderFilter(new VignetteShader());

	public static function setChrome(?chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}

	public static function setVignette(?radius:Float):Void
	{
		vignette.shader.data.radius.value = [radius];
	}

}