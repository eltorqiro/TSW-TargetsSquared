import com.Utils.GlobalSignal;

import com.Utils.Signal;
import GUIFramework.ClipNode;
import GUIFramework.SFClipLoader;
import com.GameInterface.LoreBase;
import com.GameInterface.DistributedValue;

import com.GameInterface.UtilsBase;
import com.GameInterface.LogBase;

import com.ElTorqiro.TargetsSquared.Const;
import com.ElTorqiro.TargetsSquared.AddonUtils.Preferences;
import com.ElTorqiro.TargetsSquared.AddonUtils.VTIOConnector;
import com.ElTorqiro.TargetsSquared.AddonUtils.CommonUtils;
import com.ElTorqiro.TargetsSquared.AddonUtils.MovieClipHelper;
import com.ElTorqiro.TargetsSquared.HUD.HUD;


/**
 * 
 * 
 */
class com.ElTorqiro.TargetsSquared.App {
	
	// static class only
	private function App() { }
	
	// starts the app running
	public static function start( host:MovieClip ) {

		if ( running ) return;
		_running = true;
		
		debug( "App: start" );

		hostMovie = host;
		hostMovie._visible = false;
		
		// load preferences
		prefs = new Preferences( Const.PrefsName );
		createPrefs();
		prefs.load();

		// perform initial installation tasks
		install();
		
		// attach app icon
		iconClip = SFClipLoader.LoadClip( Const.IconClipPath, Const.AppID + "_Icon", false, Const.IconClipDepthLayer, Const.IconClipSubDepth, [] );
		iconClip.SignalLoaded.Connect( iconLoaded );
	
		// attach hud
		manageHud();
		
		// listen for GUI edit mode signal, to retain state so the HUD can use it even if the HUD is not enabled when the signal is emitted
		GlobalSignal.SignalSetGUIEditMode.Connect( guiEditModeChangeHandler );
		
		// listen for pref changes and route to appropriate behaviour
		prefs.SignalValueChanged.Connect( prefChangeHandler );
		
	}

	/**
	 * stop app running and clean up resources
	 */
	public static function stop() : Void {
		
		debug( "App: stop" );
		
		// stop listening for pref value changes
		prefs.SignalValueChanged.Disconnect( prefChangeHandler );

		// stop listening for gui edit mode signal
		GlobalSignal.SignalSetGUIEditMode.Disconnect( guiEditModeChangeHandler );
		
		// unload icon
		SFClipLoader.UnloadClip( Const.AppID + "_Icon" );
		iconClip = null;

		// unload hud
		hud.removeMovieClip();
		hud = null;
		
		// remove prefs
		prefs.dispose();
		prefs = null;
		
		_running = false;
	}
	
	/**
	 * make the app active
	 * - typically called by OnModuleActivated in the module
	 */
	public static function activate() : Void {
		
		debug( "App: activate" );
		
		_active = true;
		
		// component clip visibility
		iconClip.m_Movie._visible = true;
		manageVisibility();
		
		// manage config window
		showConfigWindowMonitor = DistributedValue.Create( Const.ShowConfigWindowDV );
		showConfigWindowMonitor.SetValue( false );
		showConfigWindowMonitor.SignalChanged.Connect( manageConfigWindow );

	}
	
	/**
	 * make the app inactive
	 * - typically called by OnModuleDeactivated in the module
	 */
	public static function deactivate() : Void {
		
		debug( "App: deactivate" );
		
		_active = false;

		// destroy config window
		showConfigWindowMonitor.SetValue ( false );
		showConfigWindowMonitor.SignalChanged.Disconnect( manageConfigWindow );
		showConfigWindowMonitor = null;

		// component clip visibility
		iconClip.m_Movie._visible = false;
		manageVisibility();
		
		// save settings
		prefs.save();
	}

	/**
	 * populate pref object with app entries
	 */
	private static function createPrefs() : Void  {
		
		prefs.add( "prefs.version", Const.PrefsVersion );
		
		prefs.add( "app.installed", false );
		
		prefs.add( "configWindow.position", undefined );
		prefs.add( "icon.position", undefined );
		prefs.add( "icon.scale", 100, { min: Const.MinIconScale, max: Const.MaxIconScale } );
		
		prefs.add( "hud.enabled", true );
		prefs.add( "hud.scale", 100, { min: Const.MinHudScale, max: Const.MaxHudScale } );
		prefs.add( "hud.position.default", true );
		
		prefs.add( "hud.bars.enemyEnemy.enabled", true );
		prefs.add( "hud.bars.enemyEnemy.position", undefined );

		prefs.add( "hud.bars.enemyAlly.enabled", true );
		prefs.add( "hud.bars.enemyAlly.position", undefined );

		prefs.add( "hud.bar.clickToSelect", true );
		
		prefs.add( "hud.bar.healthbar.enable", true );
		prefs.add( "hud.bar.healthbar.text", Const.e_HealthBarTextRaw );
		prefs.add( "hud.bar.size.x", 60, { min: 60, max: 100 } );
		
		prefs.add( "hud.bar.background.type", Const.e_BackgroundTypeFlat );
		prefs.add( "hud.bar.background.padding", 5, { min: 0, max: 30 } );
		prefs.add( "hud.bar.background.alpha", 50, { min: 0, max: 100 } );
		prefs.add( "hud.bar.background.tint", Const.e_FxWhenMe );

		prefs.add( "hud.bar.glow", Const.e_FxWhenMe );
		prefs.add( "hud.bar.glow.size", 3, { min: 1, max: 6 } );
		prefs.add( "hud.bar.glow.intensity", 1, { min: 1, max: 4 } );
		
		prefs.add( "hud.tints.background.default", 		0x181818 );
		prefs.add( "hud.tints.background.enemy",		0x880000 );
		prefs.add( "hud.tints.glow.enemy",				0xff0000 );
		prefs.add( "hud.tints.background.ally",			0x008800 );
		prefs.add( "hud.tints.glow.ally",				0x00ff00 );
		
	}

	/**
	 * handle pref value changes and route to appropriate behaviour
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private static function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		
		switch( name ) {
		
			case "hud.enabled":
				manageHud();
			break;
			
		}
		
	}
	
	/**
	 * triggers updates that need to occur after the icon clip has been loaded
	 * 
	 * @param	clipNode
	 * @param	success
	 */
	private static function iconLoaded( clipNode:ClipNode, success:Boolean ) : Void {
		debug("App: icon loaded: " + success);
		
		vtio = new VTIOConnector( Const.AppID, Const.AppAuthor, Const.AppVersion, Const.ShowConfigWindowDV, iconClip.m_Movie.m_Icon, registeredWithVTIO );
	}

	/**
	 * triggers updates that need to occur after the app has been registered with VTIO
	 * e.g. updating the state of the icon copy that VTIO creates
	 */
	private static function registeredWithVTIO() : Void {

		debug( "App: registered with VTIO" );
		
		// move clip to the depth required by VTIO icons
		SFClipLoader.SetClipLayer( SFClipLoader.GetClipIndex( iconClip.m_Movie ), VTIOConnector.e_VtioDepthLayer, VTIOConnector.e_VtioSubDepth );
		
		_isRegisteredWithVtio = true;
		vtio = null;
		
	}
	
	/**
	 * creates or destroys the hud, based on enabled setting
	 */
	public static function manageHud() : Void {
		
		var hudEnabled:Boolean = prefs.getVal( "hud.enabled" );
		
		// attach hud
		if ( hudEnabled && hud == undefined ) {
			hud = HUD( MovieClipHelper.createMovieWithClass( HUD, "hud", hostMovie, hostMovie.getNextHighestDepth() ) );
		}
		
		else if ( !hudEnabled ) {
			hud.removeMovieClip();
			hud = undefined;
		}

	}
	 
	/**
	 * shows or hides the config window
	 * 
	 * @param	show
	 */
	public static function manageConfigWindow() : Void {
		debug( "App: manageConfigWindow" );

		var clipName:String = Const.AppID + "_ConfigWindow";
		
		if ( active && showConfigWindowMonitor.GetValue() ) {
			
			if ( !configWindowClip ) {
				debug("App: loading config window");
				configWindowClip = SFClipLoader.LoadClip( Const.ConfigWindowClipPath, clipName, false, Const.ConfigWindowClipDepthLayer, Const.ConfigWindowClipSubDepth, [] );
			}
		}
		
		else if ( configWindowClip ) {
			SFClipLoader.UnloadClip( clipName );
			configWindowClip = null;
			
			debug("App: config window clip unloaded");

		}
	}

	/**
	 * control the visibility of the HUD
	 */
	private static function manageVisibility() : Void {
		hostMovie._visible = Boolean( active || guiEditMode );
	}

	/**
	 * performs initial installation tasks
	 */
	private static function install() : Void {
		
		// only "install" once ever
		if ( !prefs.getVal( "app.installed" ) ) {;
		
			prefs.setVal( "app.installed", true );
		}
		
		// handle upgrades from one version to the next
		var prefsVersion:Number = prefs.getVal( "prefs.version" );
		
		// set prefs version to current version
		prefs.reset( "prefs.version" );
	}

	/**
	 * handles gui edit mode signal, to keep a constant track of edit mode state
	 * 
	 * @param	value
	 */
	private static function guiEditModeChangeHandler( edit:Boolean ) : Void {
		
		if ( guiEditMode == edit ) return;
		
		var hudClipIndex:Number = SFClipLoader.GetClipIndex( hostMovie );
		var subDepth:Number = edit ? Const.HudClipSubDepthGuiEditMode : Const.HudClipSubDepth;
		
		SFClipLoader.SetClipLayer( hudClipIndex, Const.HudClipDepthLayer, subDepth );

		_guiEditMode = edit;
	
		manageVisibility();
	}
	
	/**
	 * prints a message to the chat window if debug is enabled
	 * 
	 * @param	msg
	 */
	public static function debug( msg:String ) : Void {
		if ( !debugEnabled ) return;
		
		var message:String = Const.AppID + ": " + msg;
		
		UtilsBase.PrintChatText( message );
		LogBase.Print( 3, Const.AppID, message );
	}
	
	/*
	 * internal variables
	 */
	
	private static var hostMovie:MovieClip;
	private static var hud:HUD;
	private static var iconClip:ClipNode;
	private static var configWindowClip:ClipNode;
	
	private static var showConfigWindowMonitor:DistributedValue;
	
	private static var vtio:VTIOConnector;
	
	/*
	 * properties
	 */
	
	public static function get debugEnabled() : Boolean {
		return Boolean(DistributedValue.GetDValue( Const.DebugModeDV ));
	};
	 
	public static var prefs:Preferences;

	private static var _active:Boolean;
	public static function get active() : Boolean { return _active; }

	private static var _running:Boolean;
	public static function get running() : Boolean { return Boolean(_running); }
	
	private static var _guiEditMode:Boolean;
	public static function get guiEditMode() : Boolean { return _guiEditMode; }
	
	private static var _isRegisteredWithVtio:Boolean;
	public static function get isRegisteredWithVtio() : Boolean { return _isRegisteredWithVtio; }
	
}