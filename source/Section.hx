package;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;

	var changeBFCharacter:Bool;
	var changeBFCharacterChar:String;

	var changeDadCharacter:Bool;
	var changeDadCharacterChar:String;


	var changeCameraBeat:Bool;
	var cameraBeatSpeed:Int;
	var cameraBeatZoom:Int;


	var chromaticAberrationsShader:Bool;
	
	var vignetteShader:Bool;
	var vignetteShaderRadius:Float;
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}
