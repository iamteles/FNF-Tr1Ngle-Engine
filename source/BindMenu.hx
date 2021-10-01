package;

import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;


using StringTools;

class BindMenu extends MusicBeatState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var warningColorTween:FlxTween;
    var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    var defaultKeys:Array<String> = ["A", "S", "W", "D"];
    var curSelected:Int = 1;

    var keys:Array<String> = [FlxG.save.data.leftBind,
                              FlxG.save.data.downBind,
                              FlxG.save.data.upBind,
                              FlxG.save.data.rightBind];

    var tempKey:String = "";
    var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE"];

    var state:String = "select";

    var menuBG:FlxSprite;

    private var grpControls:FlxTypedGroup<Alphabet>;

	override function create()
	{	

        for (i in 0...keys.length)
        {
            var k = keys[i];
            if (k == null)
                keys[i] = defaultKeys[i];
        }
	
		

		persistentUpdate = persistentDraw = true;

		menuBG = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		

        /*keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(Paths.font("vcr.ttf"), 54, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 1;
		
        add(keyTextDisplay);*/

        grpControls = new FlxTypedGroup<Alphabet>();
        add(grpControls);
        for (i in 0...5)
        {
            var controlLabel:Alphabet = new Alphabet(0, (30 * i) + 30, "NOTES", true, false);
            controlLabel.isMenuItem = true;
            controlLabel.ID = i;
            controlLabel.screenCenter(X);
            controlLabel.targetY = i;
            grpControls.add(controlLabel);
            // DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
        }

        keyWarning = new FlxText(0, 580, 1280, "WARNING:TRY ANOTHER KEY", 42);
		keyWarning.scrollFactor.set(0, 0);
		keyWarning.setFormat(Paths.font("vcr.ttf"), 54, FlxColor.RED + FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        keyWarning.borderSize = 3;
		keyWarning.borderQuality = 1;
        keyWarning.screenCenter(X);
        keyWarning.alpha = 0;
        add(keyWarning);
        

		

        warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0);
        warningColorTween = FlxTween.tween(menuBG, {color: 0xFFea71fd}, 0);

        textUpdate();
        changeItem(0);

		super.create();
	}

	override function update(elapsed:Float)
	{

        for(i in 0...5)
        {
            grpControls.members[i].screenCenter(X);
        }

        switch(state){

            case "select":
                if (FlxG.keys.justPressed.UP)
				{
					
					changeItem(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					
					changeItem(1);
				}

                if (FlxG.keys.justPressed.ENTER){
                    FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
                    state = "input";
                }
                else if(FlxG.keys.justPressed.ESCAPE){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    quit();
                }
				else if (FlxG.keys.justPressed.BACKSPACE){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    reset();
                }

            case "input":
                tempKey = keys[curSelected - 1];
                keys[curSelected - 1] = "?";
                state = "waiting";

            case "waiting":
                if(FlxG.keys.justPressed.ESCAPE){
                    keys[curSelected - 1] = tempKey;
                    state = "select";
                    FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
                }
                else if(FlxG.keys.justPressed.ENTER){
                    addKey(defaultKeys[curSelected - 1]);
                    save();
                    state = "select";
                }
                else if(FlxG.keys.justPressed.ANY){
                    addKey(FlxG.keys.getIsDown()[0].ID.toString());
                    save();
                    state = "select";
                }


            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.UP && !FlxG.keys.justPressed.DOWN && !FlxG.keys.justPressed.LEFT && !FlxG.keys.justPressed.RIGHT){
			textUpdate();
             
        }

		super.update(elapsed);
		
	}

    public function textUpdate(){

        

        for(i in 1...5)
        {

            //keyTextDisplay.text += textStart + keyText[i];
            grpControls.remove(grpControls.members[i]);
            var ctrl:Alphabet = new Alphabet(0, (30 * i) + 30, keyText[i - 1] + ": " + (keys[i - 1] != null ? keys[i - 1] : "NOTHING"), false, false);
            ctrl.ID = i;
            ctrl.isMenuItem = true;
            ctrl.screenCenter(X);
            ctrl.targetY = curSelected;
            grpControls.add(ctrl);
            changeItem(0);
            
        }

        //keyTextDisplay.screenCenter();

        

    }

    public function save(){

        FlxG.save.data.upBind = keys[2];
        FlxG.save.data.downBind = keys[1];
        FlxG.save.data.leftBind = keys[0];
        FlxG.save.data.rightBind = keys[3];

        FlxG.save.flush();

        PlayerSettings.player1.controls.loadKeyBinds();

    }

    public function reset(){

        for(i in 0...5){
            keys[i] = defaultKeys[i];
        }
        quit();

    }

    public function quit(){

        state = "exiting";

        save();

        FlxG.switchState(new OptionsMenu());

    }

	function addKey(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];

        for(x in keys){
            if(x != tempKey){notAllowed.push(x);}
        }

        for(x in blacklist){notAllowed.push(x);}

        if(curSelected != 5){

            for(x in keyText){
                if(x != keyText[curSelected - 1]){notAllowed.push(x);}
            }
            
        }
        else {for(x in keyText){notAllowed.push(x);}}

        trace(notAllowed);

        for(x in 0...keys.length)
            {
                var oK = keys[x];
                if(oK == r)
                    keys[x] = null;
            }

        if(shouldReturn){
            keys[curSelected - 1] = r;
            FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
        }
        else{
            keys[curSelected - 1] = tempKey;
            FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
            keyWarning.alpha = 1;
            menuBG.color = FlxColor.RED + FlxColor.YELLOW;
            warningTween.cancel();
            warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
            warningColorTween.cancel();
            warningColorTween = FlxTween.tween(menuBG, {color: 0xFFea71fd}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
        }
        
        changeItem(0);
	} 

    public function changeItem(_amount:Int = 0)
    {
        FlxG.sound.play(Paths.sound("scrollMenu"), 0.4, false);

        curSelected += _amount;

        if (curSelected < 1)
            curSelected = grpControls.length - 1;
        if (curSelected >= grpControls.length)
            curSelected = 1;

        var bullShit:Int = 0;

        for (item in grpControls.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            if(item.ID != 0)
                item.alpha = 0.6;
            // item.setGraphicSize(Std.int(item.width * 0.8));

            if (item.targetY == 0)
            {
                item.alpha = 1;
                // item.setGraphicSize(Std.int(item.width));
            }
        }
    }
}