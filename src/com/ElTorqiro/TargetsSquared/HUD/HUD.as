import gfx.core.UIComponent;

import com.GameInterface.DistributedValue;
import flash.geom.Point;
import com.Utils.GlobalSignal;
import com.Utils.Signal;
import gfx.utils.Delegate;

import com.GameInterface.Game.Character;
import com.Utils.ID32

import com.ElTorqiro.TargetsSquared.App;
import com.ElTorqiro.TargetsSquared.Const;
import com.ElTorqiro.TargetsSquared.AddonUtils.MovieClipHelper;
import com.ElTorqiro.TargetsSquared.AddonUtils.GuiEditMode.GemController;
import com.ElTorqiro.TargetsSquared.AddonUtils.WaitFor;
import com.ElTorqiro.TargetsSquared.HUD.TargetBox;


import com.GameInterface.UtilsBase;


/**
 * 
 * 
 */
class com.ElTorqiro.TargetsSquared.HUD.HUD extends UIComponent {
	
	public static var __className:String = "com.ElTorqiro.TargetsSquared.HUD.HUD";

	/**
	 * constructor
	 */
	public function HUD() {
		
		// start up invisible
		visible = false;
		
	}

	private function configUI() : Void {
		
		// listen for pref changes and route to appropriate behaviour
		App.prefs.SignalValueChanged.Connect( prefChangeHandler, this );
		
		// gui edit mode listener
		GlobalSignal.SignalSetGUIEditMode.Connect( manageGuiEditMode, this );

		// create bars
		bars = {
			enemyEnemy: { type: "enemy" },
			enemyAlly: { type: "ally" }
		};
		
		manageBars();
		
		// listen for offensive target changes
		Character.GetClientCharacter().SignalOffensiveTargetChanged.Connect( attachTarget, this );
		attachTarget();
		
		// check for initial state of gui edit mode on startup
		manageGuiEditMode( App.guiEditMode );
		
		visible = true;
	}

	private function manageBars() : Void {
			
		for ( var s:String in bars ) {
			
			var bar:Object = bars[s];
			var shouldExist:Boolean = App.prefs.getVal( "hud.bars." + s + ".enabled" );
			
			if ( shouldExist && !bar.clip ) {
				bar.clip = MovieClipHelper.attachMovieWithRegister( "eltorqiro.targetssquared.targetbox", TargetBox, s, this, this.getNextHighestDepth(), { type: bar.type } );
			}
			
			else if ( !shouldExist && bar.clip ) {
				bar.clip.removeMovieClip();
				delete bar.clip;
			}
			
		}

		layout();
		setGemTargets();
	}
	
	public function attachTarget() : Void {

		// detach from previous targets
		target.SignalOffensiveTargetChanged.Disconnect( enemyChanged, this );
		target.SignalDefensiveTargetChanged.Disconnect( allyChanged, this );

		var newTargetId:ID32 = Character.GetClientCharacter().GetOffensiveTarget();
		
		// only apply if dynel is a character (i.e. not doors/ladders etc)
		target = newTargetId.GetType() == _global.Enums.TypeID.e_Type_GC_Character ? Character.GetCharacter( newTargetId ) : undefined;

		// attach to new targets
		target.SignalOffensiveTargetChanged.Connect( enemyChanged, this );
		target.SignalDefensiveTargetChanged.Connect( allyChanged, this );
		
		App.debug( "HUD: new offensive target: " + target.GetName() );
		
		// trigger initial update
		enemyChanged();
		allyChanged();
	}

	private function enemyChanged() : Void {
		enemyEnemy.target = getGemCompatibleTarget( target.GetOffensiveTarget() );
	}
	
	private function allyChanged() : Void {
		enemyAlly.target = getGemCompatibleTarget( target.GetDefensiveTarget() );
	}

	private function getGemCompatibleTarget( targetId:ID32 ) : ID32 {
		return gemController && (targetId.IsNull() || targetId == undefined) ? Character.GetClientCharacter().GetID() : targetId;
	}
	
	private function layout() : Void {
		
		// set default position initially
		var pos:Point = new Point( Stage.visibleRect.width * 0.66, Stage.visibleRect.height / 2 );
		enemyEnemy.position = pos;
		enemyAlly.position = new Point( pos.x, pos.y + enemyEnemy._height + 30 );
		
		// override with restored positions
		if ( !App.prefs.getVal( "hud.position.default" ) ) {
			
			for ( var s:String in bars ) {
				pos = App.prefs.getVal( "hud.bars." + s + ".position" );
				if ( pos != undefined ) {
					bars[s].clip.position = pos;
				}
			}
			
		}
		
		// update saved positions
		saveBarPositions();
	}
	
	/**
	 * manages the GUI Edit Mode state
	 * 
	 * @param	edit
	 */
	public function manageGuiEditMode( edit:Boolean ) : Void {
	
		if ( edit ) {
			if ( !gemController ) {
				gemController = GemController.create( "m_GuiEditModeController", this, this.getNextHighestDepth() );
				gemController.addEventListener( "scrollWheel", this, "gemScrollWheelHandler" );
				gemController.addEventListener( "endDrag", this, "gemEndDragHandler" );
			}
		}
		
		else {
			gemController.removeMovieClip();
			gemController = null;
		}
		
		setGemTargets();
	}

	private function setGemTargets() : Void {
		gemController.targets = [ enemyEnemy, enemyAlly ];
		
		// ensure there is a target in the box when gem is up
		enemyChanged();
		allyChanged();
	}
	
	private function gemScrollWheelHandler( event:Object ) : Void {
		App.prefs.setVal( "hud.scale", App.prefs.getVal( "hud.scale" ) + event.delta * 5 );
	}
	
	private function gemEndDragHandler( event:Object ) : Void {
		App.prefs.setVal( "hud.position.default", false );
		saveBarPositions();
	}

	/**
	 * saves the positions of all active bars to the prefs
	 */
	private function saveBarPositions() : Void {
		for ( var s:String in bars ) {
			var clip:MovieClip = bars[s].clip;
			
			if ( clip ) {
				App.prefs.setVal( "hud.bars." + s + ".position", new Point( clip._x, clip._y ) );
			}
		}
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
			
			case "hud.position.default":
				if ( newValue ) layout();
			break;
			
			case "hud.bars.enemyEnemy.enabled":
			case "hud.bars.enemyAlly.enabled":
				manageBars();
			break;
			
		}
		
	}

	/**
	 * internal variables
	 */

	public var gemController:GemController;
    private var guiResolutionScale:DistributedValue;
	
	private var target:Character;
	
	private var enemyEnemy:TargetBox;
	private var enemyAlly:TargetBox;

	private var bars:Object;
	
	/**
	 * properties
	 */
	
}