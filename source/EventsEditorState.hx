package;

import haxe.Constraints.Function;
import Conductor.BPMChangeEvent;
import EventsSystemSection.SwagEventsSystemSection;
import EventSystemChart.SwagEventSystemChart;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flash.geom.Rectangle;
import lime.media.AudioBuffer;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.net.FileFilter;

using StringTools;

class EventsEditorState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;


	var bpmTxt:FlxText;

	var strumLine:Sprite;
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:Sprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:Sprite;

	var curRenderedNotes:FlxTypedGroup<Note>;

	var gridBG:FlxSprite;

	var _song:SwagEventSystemChart;

	var typingShit:FlxInputText;


	var tempBpm:Int = 0;

	var vocals1:FlxSound;
	var vocals2:FlxSound;

	var scrollBar:Sprite;
	var scrollBarLine:Sprite;

	var waveform:WaveformVisual;
	var waveformStatic:WaveformVisual;
	override function create()
	{
		FlxG.camera.zoom -= 0.05;
		var menuBG:Sprite = new Sprite().loadGraphics(Paths.image("menuDesat"));
		menuBG.color = 0xFF303030;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.3));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		menuBG.alpha = 0.7;
		add(menuBG);

		scrollBar = new Sprite(0, 0).makeGraphics(20, 600, FlxColor.GRAY);
		add(scrollBar);
		scrollBar.screenCenter(Y);
		scrollBarLine = new Sprite(0, 0).makeGraphics(20, 1, FlxColor.BLUE);
		add(scrollBarLine);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 6, GRID_SIZE * 16);
		add(gridBG);
		gridBG.screenCenter();

		dummyArrow = new Sprite(gridBG.x, gridBG.y).makeGraphics(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		curRenderedNotes = new FlxTypedGroup<Note>();

		if (PlayState.EVENTS != null)
			_song = PlayState.EVENTS;
		else
		{
			_song = {
				notes: []
			};
		}

		FlxG.mouse.visible = true;
		FlxG.save.bind('tr1ngle-engine', 'teles');

		tempBpm = PlayState.SONG.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(PlayState.SONG.song);
		Conductor.changeBPM(PlayState.SONG.bpm);
		Conductor.mapBPMChanges(PlayState.SONG);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new Sprite(0, 50).makeGraphics(GRID_SIZE * 6, 4, FlxColor.BLUE);
		strumLine.screenCenter(X);
		add(strumLine);

		

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width - 275;
		UI_box.y = gridBG.y;
		add(UI_box);
		bpmTxt.y = gridBG.y + gridBG.height - bpmTxt.height;
		bpmTxt.x = UI_box.x;

		addSongUI();
		addNoteUI();
		addSectionUI();

		add(curRenderedNotes);

		noteInfoBG = new Sprite(0, 0).makeGraphics(0, 0, FlxColor.BLACK);
		noteInfoBG.scrollFactor.set();
		noteInfoBG.alpha = 0;
		add(noteInfoBG);

		noteInfoText = new FlxText(0, 0, 0, "", 16);
		noteInfoText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noteInfoText.borderSize = 1.25;
		add(noteInfoText);
		super.create();
		updateScrollBar();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, PlayState.SONG.song, 8);
		typingShit = UI_songTitle;


		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var check_mute_v1 = new FlxUICheckBox(10, 230, null, null, "Mute Voices1 (in editor)", 100);
		check_mute_v1.checked = false;
		check_mute_v1.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_v1.checked)
				vol = 0;

			vocals1.volume = vol;
		};

		var check_mute_v2 = new FlxUICheckBox(10, 260, null, null, "Mute Voices2 (in editor)", 100);
		check_mute_v2.checked = false;
		check_mute_v2.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_v2.checked)
				vol = 0;

			vocals2.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(PlayState.SONG.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(PlayState.SONG.song.toLowerCase());
		});
		
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);
		var startHereButton:FlxButton = new FlxButton(reloadSongJson.x, loadAutosaveBtn.y + 30, "Playtest here", function()
		{

			PlayState.EVENTS = _song;
			var timeA:Float = (FlxG.sound.music.time);
			FlxG.sound.music.stop();
			vocals1.stop();
			vocals2.stop();
			
			PlayState.StartFromTime(timeA);
		});
		var openFileChart:FlxButton = new FlxButton(110, 38, "Open", function()
		{
			openFileChart();
		});
		var restart = new FlxButton(10,140,"Reset", function()
            {
                for (ii in 0..._song.notes.length)
                {
                    for (i in 0..._song.notes[ii].sectionNotes.length)
                        {
                            _song.notes[ii].sectionNotes = [];
                        }
                }
                resetSection(true);
            });

		var restartCam = new FlxButton(10,170,"To Begin", function()
            {
                resetSection(true);
            });

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_v1);
		tab_group_song.add(check_mute_v2);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(restart);
		tab_group_song.add(restartCam);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(startHereButton);
		tab_group_song.add(openFileChart);
		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

	}
	function openFileChart()
	{
		var fr:FileReference = new FileReference();
		fr.addEventListener(Event.SELECT, _onSelect, false, 0, true);
		var filters:Array<FileFilter> = new Array<FileFilter>();
		filters.push(new FileFilter("JSON Files", "*.json"));
		fr.browse(filters);
		//var result:Array<String> = Dialogs.openFile("Select a file please!", "Please select chart file", filters);
		//var result:Array<String> = fr.openFile("Select a file please!", "Please select chart file", filters);
		//_onSelect(result);
	}
	function _onSelect(E:Event):Void
	{
		var fr:FileReference = cast(E.target, FileReference);
		fr.load();
		PlayState.EVENTS = Song.parseJSONshit(fr.data.toString());
		FlxG.resetState();
		updateGrid();
	}	

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);


		UI_box.addGroup(tab_group_section);
	}

	var noteInfoText:FlxText;
	var noteInfoBG:Sprite;

	var curSelectedEvent:String = "changeCharacter";
	var curEventArgs:Array<Dynamic> = [];
	public static var eventTypes:Array<String> = 
	[
		"ChangeChar",
		"PlayCharAnim",
		"Shader",
		"Camera",
		"Countdown",
		"WavyStrumLine",
		"ChangeScrollSpeed",
		"CameraBeat",
		"CallFunc"
	];

	public static var oldEventTypes:Array<String> =  // DO NOT CHANGE (thats from 1.7.0 beta)
	[
		"changeDadCharacter", 
		"changeBFCharacter", 
		"chromaticAberrations", 
		"vignette", 
		"changeCameraBeat", 
		"changeZoom", 
		"playBFAnim", 
		"playDadAnim", 
		"playGFAnim", 
		"shakeCamera", 
		"pointAtGF", 
		"grayScale", 
		"invertColor", 
		"pixelate", 
		"zoomCam", 
		"rotateCam", 
		"wavyStrumLine", 
		"countdown", 
		"callFunction"
	];

	var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
	var boolA:Array<String> = ["DISABLE", "ENABLE"];
	var eventsDropDown:FlxUIDropDownMenu;
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';
		
		eventsDropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(eventTypes, true), function(event:String)
		{
			curSelectedEvent = eventTypes[Std.parseInt(event)];
			updateNoteUI();
		});
		
		eventsDropDown.selectedLabel = curSelectedEvent;
		
		UI_box.addGroup(tab_group_note);
		
		updateNoteUI();
		
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		if(instAudioBuffer != null) 
		{
			instAudioBuffer.dispose();
		}
		FlxG.sound.playMusic((PlayState.storyDifficulty != 3 ? Paths.inst(daSong) : Paths.instFunky(daSong)), 0.6);
		FlxG.sound.music.pause();
		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals1 = new FlxSound().loadEmbedded((PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[0] : Paths.voicesFunky(daSong)[0]));
		FlxG.sound.list.add(vocals1);
		vocals2 = new FlxSound().loadEmbedded((PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[1] : Paths.voicesFunky(daSong)[1]));
		FlxG.sound.list.add(vocals2);
		instAudioBuffer = AudioBuffer.fromFile("./" + (PlayState.storyDifficulty != 3 ? Paths.inst(daSong) : Paths.instFunky(daSong)).substr(6));

		if(waveform != null)
			remove(waveform);
		waveform = new WaveformVisual(102, 0, 300, 600, FlxColor.RED, instAudioBuffer);
		add(waveform);
		waveform.screenCenter(Y);
		waveform.alpha = 0.7;
		if(waveformStatic != null)
			remove(waveformStatic);
		waveformStatic = new WaveformVisual(gridBG.x + gridBG.width + 10, 0, 200, gridBG.height, FlxColor.CYAN, instAudioBuffer, true);
		add(waveformStatic);
		waveformStatic.screenCenter(Y);
		waveformStatic.alpha = 0.7;
		

		FlxG.sound.music.pause();
		vocals1.pause();
		vocals2.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals1.pause();
			vocals2.time = 0;
			vocals1.pause();
			vocals2.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				
				
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			if (wname.startsWith('arg'))
			{
				var ind = Std.parseInt(wname.replace("arg", ""));
				resizeArgs(ind + 1);
				curEventArgs[ind] = nums.value;
				updateGrid();
			}
			FlxG.log.add(wname);
		}
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Int = Conductor.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			daPos += 4 * Conductor.crochet;
		}
		return daPos;
	}
	function sectionEndTime():Float
	{
		var daBPM:Int = Conductor.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			daPos += 4 * Conductor.crochet;
		}
		return daPos + 15 * Conductor.stepCrochet;
	}

	override function update(elapsed:Float)
	{
		scrollBarLine.y = scrollBar.y + FlxG.sound.music.time / FlxG.sound.music.length * 600;
		curStep = recalculateSteps();
		bpmTxt.y = gridBG.y + gridBG.height - bpmTxt.height;
		Conductor.songPosition = FlxG.sound.music.time;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * 16));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((16) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}
		else if(curStep <= 16 * curSection - 1)
		{
			changeSection(curSection - 1, false, true);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);
		if(FlxG.mouse.overlaps(scrollBar) && FlxG.mouse.pressed)
		{
			var timetogoxd = (FlxG.mouse.y - scrollBar.y) / 600 * FlxG.sound.music.length;
			
			changeSectionAndTime(Math.floor(timetogoxd / (4 * Conductor.crochet)), Math.round(timetogoxd));
		}
		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						trace('tryin to delete note...');
						deleteNote(note);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 16))
				{
					FlxG.log.add('added note');
					addNote(Reflect.copy(curEventArgs));
				}
			}
		}
		if (FlxG.mouse.overlaps(curRenderedNotes))
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (FlxG.mouse.overlaps(note))
				{
					noteInfoBG.visible = true;
					noteInfoText.visible = true;
					noteInfoText.text = "Event Type: " + note.eventType;
					for( argI in 0...note.eventArgs.length )
					{
						noteInfoText.text += "\nArg" + argI + ":" + note.eventArgs[argI];
					}
					noteInfoText.text += "\n";
					noteInfoText.y = FlxG.mouse.y - noteInfoText.height;
					noteInfoText.x = FlxG.mouse.x;
					noteInfoBG.x = noteInfoText.x - 5;
					noteInfoBG.y = noteInfoText.y - 5;
					noteInfoBG.width = noteInfoText.fieldWidth + 5;
					noteInfoBG.height = noteInfoText.height + 5;
				}
				
			});
		}
		else
		{
			noteInfoText.visible = false;
			noteInfoBG.visible = false;
		}
			
		

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 16))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			
			PlayState.EVENTS = _song;
			FlxG.sound.music.stop();
			vocals1.stop();
			vocals2.stop();
			if(instAudioBuffer != null)
				instAudioBuffer.dispose();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals1.pause();
					vocals2.pause();
				}
				else
				{
					vocals1.play();
					vocals2.play();
					FlxG.sound.music.play();
				}
				vocals1.time = Conductor.songPosition;
				vocals2.time = Conductor.songPosition;
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals1.pause();
				vocals2.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				
			}
			
			if (!FlxG.keys.pressed.SHIFT)
			{
				if ((FlxG.keys.pressed.UP || FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN))
				{
					FlxG.sound.music.pause();
					vocals1.pause();
					vocals2.pause();

					var daTime:Float = (FlxG.keys.pressed.CONTROL ? 100 : 700) * FlxG.elapsed;

					if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals1.time = FlxG.sound.music.time;
					vocals2.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();
					vocals1.pause();
					vocals2.pause();

					var daTime:Float = Conductor.stepCrochet * (FlxG.keys.pressed.CONTROL ? 1 : 2);

					if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals1.time = FlxG.sound.music.time;
					vocals2.time = FlxG.sound.music.time;
				}
			}
		}

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = 
			PlayState.SONG.song + "\n"
			+ Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nStep: "
			+ curStep
			+ "\nBeat: "
			+ curBeat
			+ "\nBPM: "
			+ Conductor.bpm;
		super.update(elapsed);
	}




	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals1.pause();
		vocals2.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals1.time = FlxG.sound.music.time;
		vocals2.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}


	

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true, ?endOfSection:Bool = false):Void
	{
		trace('changing section' + sec);
		
		var sectionA = _song.notes[curSection];

		if (_song.notes[sec] != null)
		{

			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals2.pause();
				vocals1.pause();
				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = !endOfSection ? sectionStartTime() : sectionEndTime();
				vocals2.time = FlxG.sound.music.time;
				vocals1.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		waveformStatic.curSection = curSection;
		waveformStatic.updateWaveform();
	}
	function changeSectionAndTime(sec:Int = 0, time:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);
		
		var sectionA = _song.notes[curSection];

		if (_song.notes[sec] != null)
		{

			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals1.pause();
				vocals2.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = time;
				vocals1.time = FlxG.sound.music.time;
				vocals2.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		waveformStatic.curSection = curSection;
		waveformStatic.updateWaveform();
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (16 * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];
	}

	

	function resizeArgs(len:Int = 1)
	{
		if(curEventArgs.length <= len)
			curEventArgs.resize(len);
	}
	var cameraEventsHud:Array<String> = 
	[
		"Change Zoom",
		"Change Rotation",
		"Zoom",
		"Rotate",
		"Flash",
		"Shake"
	];
	var cameraEventsGame:Array<String> = 
	[
		"Change Zoom",
		"Change Rotation",
		"Zoom",
		"Rotate",
		"Flash",
		"Point At GF",
		"Point",
		"Shake"
	];
	var cameraEventsBoth:Array<String> = 
	[
		"Change Zoom",
		"Change Rotation",
		"Zoom",
		"Rotate",
		"Flash",
		"Point At GF [Game]",
		"Point [Game]",
		"Shake"
	];
	
	var cDD:FlxUIDropDownMenu;
	var cEDD:FlxUIDropDownMenu;

	var fxType:FlxUIDropDownMenu;
	var easeDur:FlxUINumericStepper;
	var easeType:FlxUIDropDownMenu;
	function updateNoteUI():Void
	{
		curEventArgs = [];
		UI_box.getTabGroup("Note").clear();
		
		switch(curSelectedEvent)
		{
			case "CameraBeat":
				resizeArgs(2);
				var arg0Label = new FlxText(75, 50, 0, "Camera Beat Zoom");
				var arg1Label = new FlxText(75, 70, 0, "Camera Beat Speed");
				UI_box.getTabGroup("Note").add(arg0Label);
				UI_box.getTabGroup("Note").add(arg1Label);

				var arg0NS = new FlxUINumericStepper(10, 50, 1, 1, 1, 8, 0);
				arg0NS.value = 1;
				arg0NS.name = 'arg0';
				curEventArgs[0] = arg0NS.value;
				UI_box.getTabGroup("Note").add(arg0NS);

				var arg1NS = new FlxUINumericStepper(10, 70, 1, 4, 1, 16, 0);
				arg1NS.value = 4;
				arg1NS.name = 'arg1';
				curEventArgs[1] = arg1NS.value;
				UI_box.getTabGroup("Note").add(arg1NS);
			case "Shader":
				resizeArgs(4); // 0 - effect; 1 - easing duration; 2 - easing type; 3+ - effect args
				easeDur = new FlxUINumericStepper(10, UI_box.height - 40, 0.1, 0.5, 0, 99999, 2);
				easeDur.value = 0.5;
				easeDur.name = 'arg1';
				curEventArgs[1] = easeDur.value;

				UI_box.getTabGroup("Note").add(easeDur);
				easeType = new FlxUIDropDownMenu(140, UI_box.height - 60, FlxUIDropDownMenu.makeStrIdLabelArray(Shaders.easings, false), function(value:String)
				{
					curEventArgs[2] = value;
				});
				curEventArgs[2] = "linear";
				easeType.selectedLabel = curEventArgs[2];
				UI_box.getTabGroup("Note").add(easeType);

				fxType = new FlxUIDropDownMenu(140, 90, FlxUIDropDownMenu.makeStrIdLabelArray(Shaders.effects, false), function(value:String)
				{
					var fx:String = value;
					
					curEventArgs = [];
					resizeArgs(4); // 0 - effect; 1 - easing duration; 2 - easing type; 3+ - effect args
					curEventArgs[0] = fx;
					curEventArgs[1] = easeDur.value;
					curEventArgs[2] = easeType.selectedLabel;
					UI_box.getTabGroup("Note").forEach(function(a:FlxSprite){if(a != fxType && a != easeDur && a != easeType && a != eventsDropDown) UI_box.getTabGroup("Note").remove(a, false);});
					
					switch(fx)
					{
						case "Chromatic":
							resizeArgs(3 + 3); // offset 3 because shader global args

							var arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(["Not Random", "Random"], false), function(value:String)
							{
								curEventArgs[3] = value;
							});
							curEventArgs[3] = "Not Random";
							arg0DD.selectedLabel = curEventArgs[3];
							UI_box.getTabGroup("Note").add(arg0DD);

							var label = new FlxText(75, 50, 0, "X");
							UI_box.getTabGroup("Note").add(label);

							var label2 = new FlxText(75, 70, 0, "Y");
							UI_box.getTabGroup("Note").add(label2);

							var arg0NS = new FlxUINumericStepper(10, 50, 0.1, 0, -10, 10, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg4';
							curEventArgs[4] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);
							var arg1NS = new FlxUINumericStepper(10, 70, 0.1, 0, -10, 10, 2);
							arg1NS.value = 0;
							arg1NS.name = 'arg5';
							curEventArgs[5] = arg1NS.value;
							UI_box.getTabGroup("Note").add(arg1NS);
						case "Bulge":
							resizeArgs(1 + 3);
							var label = new FlxText(75, 50, 0, "Value");
							UI_box.getTabGroup("Note").add(label);
							var arg0NS = new FlxUINumericStepper(10, 50, 0.01, 0, -1, 1, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

						case "Glitch":
							resizeArgs(4 + 3);

							var label = new FlxText(75, 50, 0, "Max X Offset");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 0.01, 0, 0, 1, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

							var label2 = new FlxText(75, 70, 0, "Max Col Offset");
							UI_box.getTabGroup("Note").add(label2);

							var arg1NS = new FlxUINumericStepper(10, 70, 0.01, 0, 0, 1, 2);
							arg1NS.value = 0;
							arg1NS.name = 'arg4';
							curEventArgs[4] = arg1NS.value;
							UI_box.getTabGroup("Note").add(arg1NS);

							var label3 = new FlxText(75, 90, 0, "Slice Height");
							UI_box.getTabGroup("Note").add(label3);

							var arg2NS = new FlxUINumericStepper(10, 90, 0.01, 0, 0, 1, 2);
							arg2NS.value = 0;
							arg2NS.name = 'arg5';
							curEventArgs[5] = arg2NS.value;
							UI_box.getTabGroup("Note").add(arg2NS);

							var label4 = new FlxText(75, 110, 0, "Interval (seconds)");
							UI_box.getTabGroup("Note").add(label4);

							var arg3NS = new FlxUINumericStepper(10, 110, 0.01, 0.1, 0, 5, 2);
							arg3NS.value = 0.1;
							arg3NS.name = 'arg6';
							curEventArgs[6] = arg3NS.value;
							UI_box.getTabGroup("Note").add(arg3NS);

						case "Grayscale":
							resizeArgs(5 + 3);
							
							var label = new FlxText(75, 50, 0, "Value");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 0.01, 0, 0, 1, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

							var label2 = new FlxText(75, 70, 0, "Tint R");
							UI_box.getTabGroup("Note").add(label2);

							var arg1NS = new FlxUINumericStepper(10, 70, 1, 255, 0, 255, 0);
							arg1NS.value = 255;
							arg1NS.name = 'arg4';
							curEventArgs[4] = arg1NS.value;
							UI_box.getTabGroup("Note").add(arg1NS);

							var label3 = new FlxText(75, 90, 0, "Tint G");
							UI_box.getTabGroup("Note").add(label3);

							var arg2NS = new FlxUINumericStepper(10, 90, 1, 255, 0, 255, 0);
							arg2NS.value = 255;
							arg2NS.name = 'arg5';
							curEventArgs[5] = arg2NS.value;
							UI_box.getTabGroup("Note").add(arg2NS);

							var label4 = new FlxText(75, 110, 0, "Tint B");
							UI_box.getTabGroup("Note").add(label4);

							var arg3NS = new FlxUINumericStepper(10, 110, 1, 255, 0, 255, 0);
							arg3NS.value = 255;
							arg3NS.name = 'arg6';
							curEventArgs[6] = arg3NS.value;
							UI_box.getTabGroup("Note").add(arg3NS);

							var useLum = new FlxUICheckBox(10, 130, null, null, "Use Lum");
							useLum.callback = function()
							{
								curEventArgs[7] = useLum.checked;
							};
							curEventArgs[7] = false;
							UI_box.getTabGroup("Note").add(useLum);

						case "Hue":
							resizeArgs(1 + 3);

							var label = new FlxText(75, 50, 0, "HUE Angle");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -360, 360, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

						case "Invert":
							resizeArgs(4 + 3);

							var label = new FlxText(75, 50, 0, "Value");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 0.01, 0, 0, 1, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

							var label2 = new FlxText(75, 70, 0, "Tint R");
							UI_box.getTabGroup("Note").add(label2);

							var arg1NS = new FlxUINumericStepper(10, 70, 0.01, 1, 0, 1, 2);
							arg1NS.value = 1;
							arg1NS.name = 'arg4';
							curEventArgs[4] = arg1NS.value;
							UI_box.getTabGroup("Note").add(arg1NS);

							var label3 = new FlxText(75, 90, 0, "Tint G");
							UI_box.getTabGroup("Note").add(label3);

							var arg2NS = new FlxUINumericStepper(10, 90, 0.01, 1, 0, 1, 2);
							arg2NS.value = 1;
							arg2NS.name = 'arg5';
							curEventArgs[5] = arg2NS.value;
							UI_box.getTabGroup("Note").add(arg2NS);

							var label4 = new FlxText(75, 110, 0, "Tint B");
							UI_box.getTabGroup("Note").add(label4);

							var arg3NS = new FlxUINumericStepper(10, 110, 0.01, 1, 0, 1, 2);
							arg3NS.value = 1;
							arg3NS.name = 'arg6';
							curEventArgs[6] = arg3NS.value;
							UI_box.getTabGroup("Note").add(arg3NS);

						case "LensCircle":
							resizeArgs(9 + 3);
							// strength
							var label = new FlxText(75, 50, 0, "Strength");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 0.01, 0, 0, 1, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

							// x y
							var label1 = new FlxText(75, 70, 0, "Origin X");
							UI_box.getTabGroup("Note").add(label1);

							var arg1NS = new FlxUINumericStepper(10, 70, 0.01, 0, -1, 1, 2);
							arg1NS.value = 0;
							arg1NS.name = 'arg4';
							curEventArgs[4] = arg1NS.value;
							UI_box.getTabGroup("Note").add(arg1NS);

							var label2 = new FlxText(75, 90, 0, "Origin Y");
							UI_box.getTabGroup("Note").add(label2);

							var arg2NS = new FlxUINumericStepper(10, 90, 0.01, 0, -1, 1, 2);
							arg2NS.value = 0;
							arg2NS.name = 'arg5';
							curEventArgs[5] = arg2NS.value;
							UI_box.getTabGroup("Note").add(arg2NS);

							// start end

							var label3 = new FlxText(75, 110, 0, "Start");
							UI_box.getTabGroup("Note").add(label3);

							var argsNS = new FlxUINumericStepper(10, 110, 0.01, 0, 0, 1, 2);
							argsNS.value = 0;
							argsNS.name = 'arg6';
							curEventArgs[6] = argsNS.value;
							UI_box.getTabGroup("Note").add(argsNS);

							var label4 = new FlxText(75, 130, 0, "End");
							UI_box.getTabGroup("Note").add(label4);

							var argeNS = new FlxUINumericStepper(10, 130, 0.01, 0, 0, 1, 2);
							argeNS.value = 0;
							argeNS.name = 'arg7';
							curEventArgs[7] = argeNS.value;
							UI_box.getTabGroup("Note").add(argeNS);

							// rgb

							var label5 = new FlxText(75, 150, 0, "R");
							UI_box.getTabGroup("Note").add(label5);

							var argrNS = new FlxUINumericStepper(10, 150, 1, 0, 0, 255, 0);
							argrNS.value = 0;
							argrNS.name = 'arg8';
							curEventArgs[8] = argrNS.value;
							UI_box.getTabGroup("Note").add(argrNS);

							var label6 = new FlxText(75, 170, 0, "G");
							UI_box.getTabGroup("Note").add(label6);

							var arggNS = new FlxUINumericStepper(10, 170, 1, 0, 0, 255, 0);
							arggNS.value = 0;
							arggNS.name = 'arg9';
							curEventArgs[9] = arggNS.value;
							UI_box.getTabGroup("Note").add(arggNS);

							var label7 = new FlxText(75, 190, 0, "B");
							UI_box.getTabGroup("Note").add(label7);

							var argbNS = new FlxUINumericStepper(10, 190, 1, 0, 0, 255, 0);
							argbNS.value = 0;
							argbNS.name = 'arg10';
							curEventArgs[10] = argbNS.value;
							UI_box.getTabGroup("Note").add(argbNS);

							var useR = new FlxUICheckBox(10, 210, null, null, "Use Ratio");
							useR.callback = function()
							{
								curEventArgs[11] = useR.checked;
							};
							curEventArgs[11] = true;
							useR.checked = true;
							UI_box.getTabGroup("Note").add(useR);

						case "Sepia":
							resizeArgs(1 + 3);

							var label = new FlxText(75, 50, 0, "Value");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 0.1, 0, 0, 1, 2);
							arg0NS.value = 0;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);
						case "SplitScreen":
							resizeArgs(2 + 3);
							
							var label = new FlxText(75, 50, 0, "Col");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 0.1, 1, -16, 16, 2);
							arg0NS.value = 1;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

							var label2 = new FlxText(75, 70, 0, "Row");
							UI_box.getTabGroup("Note").add(label2);

							var arg1NS = new FlxUINumericStepper(10, 70, 0.1, 1, -16, 16, 2);
							arg1NS.value = 1;
							arg1NS.name = 'arg4';
							curEventArgs[4] = arg1NS.value;
							UI_box.getTabGroup("Note").add(arg1NS);
						case "Pixelate":
							resizeArgs(2 + 3);
							
							var label = new FlxText(75, 50, 0, "Width");
							UI_box.getTabGroup("Note").add(label);

							var arg0NS = new FlxUINumericStepper(10, 50, 1, 1, 16, 1280, 0);
							arg0NS.value = 1280;
							arg0NS.name = 'arg3';
							curEventArgs[3] = arg0NS.value;
							UI_box.getTabGroup("Note").add(arg0NS);

							var label2 = new FlxText(75, 70, 0, "Height");
							UI_box.getTabGroup("Note").add(label2);
	
							var arg1NS = new FlxUINumericStepper(10, 70, 1, 1, 9, 720, 0);
							arg1NS.value = 720;
							arg1NS.name = 'arg4';
							curEventArgs[4] = arg1NS.value;
							UI_box.getTabGroup("Note").add(arg1NS);
					}
					
				});
				UI_box.getTabGroup("Note").add(fxType);
			case "Camera":
				resizeArgs(3); // 0 - camera; 1 - camera event; 2+ - camera event args
				// camera selection
				
				cDD = new FlxUIDropDownMenu(140, 90, FlxUIDropDownMenu.makeStrIdLabelArray(["Game", "HUD", "Both"], false), function(value:String)
				{
					UI_box.getTabGroup("Note").forEach(function(a:FlxSprite){if(a != cDD && a != eventsDropDown) UI_box.getTabGroup("Note").remove(a, false);});
					var cam:String = value;

					// camera event selection
					var cameraEvents:Array<String> = [];
					switch(cam)
					{
						case "Game":
							cameraEvents = cameraEventsGame;
						case "HUD":
							cameraEvents = cameraEventsHud;
						case "Both":
							cameraEvents = cameraEventsBoth;
					}
					
					cEDD = new FlxUIDropDownMenu(140, 170, FlxUIDropDownMenu.makeStrIdLabelArray(cameraEvents, false), function(value2:String)
					{
						UI_box.getTabGroup("Note").forEach(function(a:FlxSprite){if(a != cDD && a != eventsDropDown) UI_box.getTabGroup("Note").remove(a, false);});
						curEventArgs[0] = cam;
						curEventArgs[1] = value2;
						switch(value2)
						{
							case "Change Zoom":
								resizeArgs(1 + 2); // offset 2 because camera and camera event indexes
								var arg0Label = new FlxText(75, 50, 0, "New Zoom Value");
								UI_box.getTabGroup("Note").add(arg0Label);
								
								var arg0NS = new FlxUINumericStepper(10, 50, 0.05, 0.9, 0, 2, 2);
								arg0NS.value = 0.9;
								arg0NS.name = 'arg2';
								curEventArgs[2] = arg0NS.value;
								
								UI_box.getTabGroup("Note").add(arg0NS);
							case "Change Rotation":
								resizeArgs(1 + 2);
								var arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -360, 360, 1);
								arg0NS.value = 0;
								arg0NS.name = 'arg2';
								curEventArgs[2] = arg0NS.value;
								
								UI_box.getTabGroup("Note").add(arg0NS);
							case "Zoom":
								resizeArgs(1 + 2);
								var arg0Label = new FlxText(75, 50, 0, "Zoom Value");
								UI_box.getTabGroup("Note").add(arg0Label);

								var arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -16, 16, 0);
								arg0NS.value = 0;
								arg0NS.name = 'arg2';
								curEventArgs[2] = arg0NS.value;
								
								UI_box.getTabGroup("Note").add(arg0NS);
							case "Rotate":
								resizeArgs(1 + 2);
								var arg0Label = new FlxText(75, 50, 0, "Rotation Angle");
								UI_box.getTabGroup("Note").add(arg0Label);

								var arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -360, 360, 0);
								arg0NS.value = 0;
								arg0NS.name = 'arg2';
								curEventArgs[2] = arg0NS.value;
								
								UI_box.getTabGroup("Note").add(arg0NS);

							case "Flash":
								resizeArgs(4 + 2);

								var arg0Label = new FlxText(75, 50, 0, "Duration");
								UI_box.getTabGroup("Note").add(arg0Label);

								var arg1Label = new FlxText(75, 70, 0, "R");
								UI_box.getTabGroup("Note").add(arg1Label);
								var arg2Label = new FlxText(75, 90, 0, "G");
								UI_box.getTabGroup("Note").add(arg2Label);
								var arg3Label = new FlxText(75, 110, 0, "B");
								UI_box.getTabGroup("Note").add(arg3Label);

								var arg0NS = new FlxUINumericStepper(10, 50, 0.1, 0.5, 0, 10, 2);
								arg0NS.value = 0.5;
								arg0NS.name = 'arg2';
								curEventArgs[2] = arg0NS.value;
								UI_box.getTabGroup("Note").add(arg0NS);

								var argrNS = new FlxUINumericStepper(10, 70, 1, 255, 0, 255, 0);
								argrNS.value = 255;
								argrNS.name = 'arg3';
								curEventArgs[3] = argrNS.value;
								UI_box.getTabGroup("Note").add(argrNS);

								var arggNS = new FlxUINumericStepper(10, 90, 1, 255, 0, 255, 0);
								arggNS.value = 255;
								arggNS.name = 'arg4';
								curEventArgs[4] = arggNS.value;
								UI_box.getTabGroup("Note").add(arggNS);

								var argbNS = new FlxUINumericStepper(10, 110, 1, 255, 0, 255, 0);
								argbNS.value = 255;
								argbNS.name = 'arg5';
								curEventArgs[5] = argbNS.value;
								UI_box.getTabGroup("Note").add(argbNS);
							case "Shake":
								resizeArgs(2 + 2);

								var arg0Label = new FlxText(75, 50, 0, "Intensity");
								var arg1Label = new FlxText(75, 70, 0, "Time");
								UI_box.getTabGroup("Note").add(arg0Label);
								UI_box.getTabGroup("Note").add(arg1Label);

								var arg0NS = new FlxUINumericStepper(10, 50, 0.05, 1, 0, 10, 2); // intensity
								arg0NS.value = 1;
								arg0NS.name = 'arg2';
								curEventArgs[2] = arg0NS.value;
								UI_box.getTabGroup("Note").add(arg0NS);
				
								var arg1NS = new FlxUINumericStepper(10, 70, 0.05, 1, 0, 10, 2); // time
								arg1NS.value = 1;
								arg1NS.name = 'arg3';
								curEventArgs[3] = arg1NS.value;
								UI_box.getTabGroup("Note").add(arg1NS);

							case "Point" | "Point [Game]":
								resizeArgs(3 + 2);
								var arg1Label = new FlxText(75, 70, 0, "X");
								var arg2Label = new FlxText(75, 90, 0, "Y");
								UI_box.getTabGroup("Note").add(arg1Label);
								UI_box.getTabGroup("Note").add(arg2Label);
								var arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
								{
									curEventArgs[2] = value;
								});
								curEventArgs[2] = boolA[0];
								arg0DD.selectedLabel = curEventArgs[2];
								UI_box.getTabGroup("Note").add(arg0DD);

								var arg1NS = new FlxUINumericStepper(10, 70, 0.5, 0, -2000, 2000, 2); // X
								arg1NS.value = 1;
								arg1NS.name = 'arg3';
								curEventArgs[3] = arg1NS.value;
								UI_box.getTabGroup("Note").add(arg1NS);

								var arg2NS = new FlxUINumericStepper(10, 90, 0.5, 0, -2000, 2000, 2); // Y
								arg2NS.value = 1;
								arg2NS.name = 'arg4';
								curEventArgs[4] = arg2NS.value;
								UI_box.getTabGroup("Note").add(arg2NS);

							case "Point At GF" | "Point At GF [Game]":
								resizeArgs(1 + 2);
								var arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
								{
									curEventArgs[2] = value;
								});
								curEventArgs[2] = boolA[0];
								arg0DD.selectedLabel = curEventArgs[2];
								UI_box.getTabGroup("Note").add(arg0DD);
						}
						UI_box.getTabGroup("Note").add(cEDD);

					});
					UI_box.getTabGroup("Note").add(cEDD);


				});
				UI_box.getTabGroup("Note").add(cDD);
			case "Countdown":
				resizeArgs(1);
				var arg0DD:FlxUIDropDownMenu = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(["Without Sound", "With Sound"], false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = "Without Sound";
				UI_box.getTabGroup("Note").add(arg0DD);
			case "WavyStrumLine":
				resizeArgs(1);
				var arg0DD:FlxUIDropDownMenu = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = boolA[0];
				UI_box.getTabGroup("Note").add(arg0DD);
			case "ChangeScrollSpeed":
				resizeArgs(1);
				var arg0NS:FlxUINumericStepper = new FlxUINumericStepper(10, 50, 0.1, FlxMath.roundDecimal(PlayState.SONG.speed, 2), 0.1, 100, 2);
				arg0NS.value = FlxMath.roundDecimal(PlayState.SONG.speed, 2);
				arg0NS.name = 'arg0';
				curEventArgs[0] = arg0NS.value;
				UI_box.getTabGroup("Note").add(arg0NS);
			case "CallFunc":
				resizeArgs(1);
				var theh = new FlxText(75, 80, 0, "This event basically calls |public static function| from PlayState.hx\nExample is `testFunction`\n You have to create `public static function`\n and add its name to `functionsList` array.");
				var arg0DD:FlxUIDropDownMenu = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(PlayState.functionsList, false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				curEventArgs[0] = PlayState.functionsList[0];
				UI_box.getTabGroup("Note").add(arg0DD);
				UI_box.getTabGroup("Note").add(theh);
		}
		eventsDropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(eventTypes, true), function(event:String)
		{
			curSelectedEvent = eventTypes[Std.parseInt(event)];
			updateNoteUI();
		});
		
		eventsDropDown.selectedLabel = curSelectedEvent;
		UI_box.getTabGroup("Note").add(eventsDropDown);
	}
	function updateScrollBar():Void
	{
		scrollBar.makeGraphics(20, 600, FlxColor.WHITE);
		scrollBar.pixels.fillRect(new Rectangle(0, 0, 20, 600), FlxColor.WHITE);
		for(a in _song.notes)
		{
			var sectionInfo:Array<Dynamic> = a.sectionNotes;
			for (i in sectionInfo)
			{
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				scrollBar.pixels.fillRect(new Rectangle(daNoteInfo * 5, daStrumTime / (FlxG.sound.music.length) * 600, 5, 5), FlxColor.GREEN);
			}
		}
		
	}
	var instAudioBuffer:AudioBuffer;
	
	function updateGrid():Void
	{
		updateScrollBar();
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}



		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;


			var daBPM:Int = PlayState.SONG.bpm;

			Conductor.changeBPM(daBPM);


		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			if(cast(i[2], String).startsWith("0") || cast(i[2], String).startsWith("1") || cast(i[2], String).startsWith("2"))
				i[2] = EventsEditorState.eventTypes[Std.parseInt(cast(i[2], String))];
			var daNoteEventTypeA = i[2];
			var daNoteEventArgsA = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % 6, true);
			note.setGraphicSize(GRID_SIZE + 5, GRID_SIZE + 5);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE) + gridBG.x;
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * 16)));
			note.eventArgs = daNoteEventArgsA;
			note.eventType = daNoteEventTypeA;
			curRenderedNotes.add(note);

		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagEventsSystemSection = {
			sectionNotes: []
		};

		_song.notes.push(sec);
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (FlxMath.roundDecimal(i[0] + Conductor.offset, 2) == note.strumTime && i[1] % 6 == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(eventArgs:Array<Dynamic>):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, curSelectedEvent, eventArgs]);

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		//updateNoteUI();
		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;
 

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.EVENTS = EventSystemChart.loadFromJson(song.toLowerCase() + "-events", song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.EVENTS = EventSystemChart.parseJSONshit(FlxG.save.data.autosaveEvents);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosaveEvents = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), PlayState.SONG.song.toLowerCase() + "-events.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
