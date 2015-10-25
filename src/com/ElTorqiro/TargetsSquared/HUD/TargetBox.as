import flash.filters.DropShadowFilter;
import gfx.core.UIComponent;

import flash.filters.GlowFilter;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import com.Components.HealthBar;
import com.GameInterface.Utils;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import flash.geom.Point;
import com.GameInterface.Game.TargetingInterface;

import com.ElTorqiro.TargetsSquared.App;
import com.ElTorqiro.TargetsSquared.Const;
import com.ElTorqiro.TargetsSquared.AddonUtils.MovieClipHelper;
import com.ElTorqiro.TargetsSquared.AddonUtils.CommonUtils;


/**
 * 
 * 
 */
class com.ElTorqiro.TargetsSquared.HUD.TargetBox extends UIComponent {
	
	public function TargetBox() {

		// start hidden
		_visible = false;
		
		MovieClipHelper.attachMovieWithRegister( "eltorqiro.targetssquared.healthBar", HealthBar, "healthBar", this, this.getNextHighestDepth() );

		SignalGeometryChanged = new Signal();
		
	}
		
	public function configUI() : Void {

		// position "next shield" icons above the health bar rather than to the right of it
		healthBar.SetShieldsOnTop( true );
		
		// remove aegis damage type icon from healthbar
		var aegis:MovieClip = healthBar["m_AegisDamageType"];
		aegis.swapDepths( aegis._parent.getNextHighestDepth() );
		aegis.removeMovieClip();

		// place healthbar below the name field, so any dropshadow from the text or icon will overlap the healthbar
		healthBar.swapDepths( nameField );
		
		// allow/deny interaction with the bars
		setClickable();

		// listen for resolution changes
		guiResolutionScale = DistributedValue.Create("GUIResolutionScale");
		guiResolutionScale.SignalChanged.Connect( loadScale, this );
		loadScale();
		
		// listen for pref changes
		App.prefs.SignalValueChanged.Connect( prefChangeHandler, this );
		
		layoutIsInvalid = true;
	}

	private function layout() : Void {

		var showHealthBar:Boolean = App.prefs.getVal( "hud.bar.healthbar.enable" );
		showHealthBar ? healthBar.Show() : healthBar.Hide();

		var xSize:Number = App.prefs.getVal( "hud.bar.size.x" )
		healthBar.SetBarScale( xSize, 70, 58, 50 );

		var textType:Number = App.prefs.getVal( "hud.bar.healthbar.text" );
		switch( textType ) {
			case Const.e_HealthBarTextRaw:
				healthBar.SetTextType( HealthBar.STATTEXT_NUMBER );
			break;
			
			case Const.e_HealthBarTextPercent:
				healthBar.SetTextType( HealthBar.STATTEXT_PERCENT );
			break;
		}
		
		healthBar.SetShowText( Boolean(textType) );

		var padding:Number = App.prefs.getVal( "hud.bar.background.padding" );
		
		icon._width = icon._height = 12;
		icon._x = padding + 1;
		icon._y = padding;
		
		nameField._x = icon._x + icon._width + 6;
		nameField._y = padding - 3.5;

		var healthBarOffset:Number = Math.floor( Math.max(xSize - 1 - 60, 0) / 20 );
		healthBar._x = padding + healthBarOffset;

		background._width = Math.round( healthBar._x + healthBar["m_Bar"]._width + padding ) + healthBarOffset + (xSize > 65 ? 1 : 0);
		
		if ( showHealthBar ) {
			healthBar._xscale = healthBar._yscale = 100;
			healthBar._y = Math.round( icon._y + icon._height + 5 );

			background._height = Math.ceil( healthBar._y + healthBar["m_ShieldBar"]._height - 2 + padding );
		}
		
		else {
			healthBar._xscale = healthBar._yscale = 0;
			healthBar._y = icon._y;
			
			background._height = Math.round( icon._y + icon._height + padding + 1 );
		}
		
		glow._width = background._width;
		glow._height = background._height;
		
		nameField._width = background._width - nameField._x - padding;
		
		SignalGeometryChanged.Emit();
		
	}
	
	private function draw() : Void {

		healthBar.SetCharacter( _character );
		
		if ( layoutIsInvalid ) {
			layout();
			layoutIsInvalid = false;
		}
		
		if ( !_character ) {
			_visible = false;
			return;
		}

		// update namefield text
		nameField.text = _character.GetName();
		Utils.TruncateText( nameField );

		// decorate background
		var backgroundType:String = App.prefs.getVal( "hud.bar.background.type" );
		background.gotoAndStop( backgroundType );

		var backgroundAlpha:Number = App.prefs.getVal( "hud.bar.background.alpha" );
		background._alpha = backgroundAlpha;
		background._visible = backgroundAlpha > 0 && backgroundType != "none";
		
		// tint background
		if ( background._visible ) {
			CommonUtils.colorize( background, checkFxPref( App.prefs.getVal( "hud.bar.background.tint" ) )
									? App.prefs.getVal( "hud.tints.background." + _type )
									: App.prefs.getVal( "hud.tints.background.default" ) );
		}

		/*
		// shadow
		
		var showShadow:Boolean = true;
		if ( showShadow ) {
			shadow.filters = [ new DropShadowFilter( 0, 0, 0, 1, 8, 8, 1, 3, false, true, false ) ];
		}
		*/
		
		// glow
		if ( checkFxPref( App.prefs.getVal( "hud.bar.glow" ) ) ) {

			var glowTint:Number = App.prefs.getVal( "hud.tints.glow." + _type );
			var glowSize:Number = Math.pow( 2, App.prefs.getVal( "hud.bar.glow.size" ) );
			var glowIntensity:Number = App.prefs.getVal( "hud.bar.glow.intensity" );
			
			glow.filters = [ new GlowFilter( glowTint, 0.8, glowSize, glowSize, glowIntensity, 3, false, true ) ];
			glow._visible = true;
		}
		
		else {
			glow._visible = false;
		}

		_visible = true;
	}

	private function checkFxPref( pref:Number ) : Boolean {
		
		var isTargetMe:Boolean = _character.IsClientChar();
		
		return	pref == Const.e_FxAlways
				|| ( isTargetMe && pref == Const.e_FxWhenMe )
				|| ( !isTargetMe && pref == Const.e_FxWhenNotMe )
		;
	}

	private function setClickable() : Void {
		hitTestDisable = !App.prefs.getVal( "hud.bar.clickToSelect" );
	}
	
	private function onPress() : Void {
		TargetingInterface.SetTarget( target.GetID() );
	}
	
	private function targetDestructed() : Void {
		target = undefined;
	}
	
	/**
	 * handles updates based on pref changes
	 * 
	 * @param	pref
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( pref:String, newValue, oldValue ) : Void {
		
		switch ( pref ) {

			case "hud.scale":
				loadScale();
			break;
			
			case "hud.bar.healthbar.enable":
			case "hud.bar.healthbar.text":
			case "hud.bar.size.x":
			
			case "hud.bar.background.type":
			case "hud.bar.background.padding":
			
				layoutIsInvalid = true;
			
			case "hud.bar.background.alpha":
			case "hud.bar.background.tint":

			case "hud.bar.glow":
			case "hud.bar.glow.size":
			case "hud.bar.glow.intensity":
			
				invalidate();
				
			break;
			
			case "hud.bar.clickToSelect":
				setClickable();
			break;
			
		}
		
	}

	/**
	 * loads scale
	 */
	private function loadScale() : Void {
		scale = App.prefs.getVal( "hud.scale" );
	}
	
	/**
	 * internal variables
	 */
	
	private var layoutIsInvalid:Boolean;
	
	private var icon:MovieClip;
	private var nameField:TextField;
	private var healthBar:HealthBar;
	private var background:MovieClip;
	private var glow:MovieClip;

    private var guiResolutionScale:DistributedValue;

	/**
	 * properties
	 */
	
	private var _type:String;
	public function get type() : String { return _type; }
	public function set type( value:String ) {
		if ( _type != value ) {
			_type = value;
			icon.gotoAndStop( _type );
			
			invalidate();
		}
	}

	private var _character:Character;
	public function get target() : Character { return _character; }
	public function set target( value ) {

		var newTargetId:ID32;
		
		if ( value instanceof ID32 ) {
			newTargetId = value;
		}
		
		else if ( value instanceof Character ) {
			newTargetId = value.GetID();
		}

		// disconnect existing destruct signal listener
		if ( _character ) _character.SignalCharacterDestructed.Disconnect( targetDestructed, this );
		
		_character = newTargetId.GetType() == _global.Enums.TypeID.e_Type_GC_Character ? Character.GetCharacter( newTargetId ) : undefined;
		if ( _character.GetName().length == 0 ) _character = undefined;

		// connect destruct signal listener to new target
		if ( _character ) _character.SignalCharacterDestructed.Connect( targetDestructed, this );
		
		invalidate();
	}

	public var SignalGeometryChanged:Signal;
	 
	// the position of the hud
	public function get position() : Point { return new Point( this._x, this._y ); }
	public function set position( value:Point ) : Void {
		this._x = value.x;
		this._y = value.y;
		
		SignalGeometryChanged.Emit();
	}

	// the scale of the hud
	public function get scale() : Number { return App.prefs.getVal( "hud.scale" ); }
	public function set scale( value:Number ) : Void {
				
		// the default game GUI scale, based on screen resolution
		var resolutionScale:Number = guiResolutionScale.GetValue();
		if ( resolutionScale == undefined ) resolutionScale = 1;
		
		this._xscale = this._yscale = value; // resolutionScale * value;

		SignalGeometryChanged.Emit();
	}
	
}