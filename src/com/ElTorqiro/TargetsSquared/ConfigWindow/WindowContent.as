import flash.geom.Point;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.TargetsSquared.AddonUtils.UI.PanelBuilder;
import com.ElTorqiro.TargetsSquared.Const;
import com.ElTorqiro.TargetsSquared.App;

import com.ElTorqiro.TargetsSquared.AddonUtils.MovieClipHelper;

/**
 * 
 * 
 */
class com.ElTorqiro.TargetsSquared.ConfigWindow.WindowContent extends com.Components.WindowComponentContent {

	public function WindowContent() {
		
	}

	private function configUI() : Void {
		
		super.configUI();

		// define the config panel to be built
		var def:Object = {
			
			// panel default load/save handlers
			load: componentLoadHandler,
			save: componentSaveHandler,
			
			layout: [

				{	id: "hud.enabled",
					type: "checkbox",
					label: "HUD enabled",
					tooltip: "Enables the HUD.  Individual bars will become visible when they have targets assigned.",
					data: { pref: "hud.enabled" }
				},
				
				{ type: "group"
				},

				{	id: "hud.bars.enemyEnemy.enabled",
					type: "checkbox",
					label: "Show your enemy's offensive target",
					tooltip: "Shows the offensive target of your offensive target.",
					data: { pref: "hud.bars.enemyEnemy.enabled" }
				},
				
				{	id: "hud.bars.enemyAlly.enabled",
					type: "checkbox",
					label: "Show your enemy's defensive target",
					tooltip: "Shows the defensive target of your offensive target.",
					data: { pref: "hud.bars.enemyAlly.enabled" }
				},
				
				{	type: "group"
				},

				{	id: "hud.bar.clickToSelect",
					type: "checkbox",
					label: "Clicking box selects target",
					tooltip: "When you click a target box, this option will select the target as your own.",
					data: { pref: "hud.bar.clickToSelect" }
				},
				
				{	type: "section",
					label: "Width"
				},
				
				{	id: "hud.bar.size.x",
					type: "slider",
					min: 60,
					max: 100,
					valueFormat: "%i%%",
					label: "Box Width",
					tooltip: "The width scale of target boxes.",
					data: { pref: "hud.bar.size.x" }
				},

				{	type: "group"
				},
				
				{	id: "hud.bar.autosize",
					type: "dropdown",
					label: "AutoSize",
					tooltip: "The auto size type to use for horizontally sizing the box based on the length of the target name.",
					data: { pref: "hud.bar.autosize" },
					list: [
						{ label: "None (manual)", value: Const.e_AutoSizeNone },
						{ label: "Left Aligned", value: Const.e_AutoSizeLeft },
						{ label: "Right Aligned", value: Const.e_AutoSizeRight }
					]
				},

				{	type: "text",
					text: "AutoSize is only applied if the health bar is hidden, in which case Box Width defines the maximum available width before the target name is truncated."
				},
				
				{	type: "section",
					label: "Health Bar"
				},

				{	id: "hud.bar.healthbar.enable",
					type: "checkbox",
					label: "Show health bar",
					tooltip: "Shows a health bar inside each target box.",
					data: { pref: "hud.bar.healthbar.enable" }
				},
				
				{	id: "hud.bar.healthbar.text",
					type: "dropdown",
					label: "Health text type",
					tooltip: "The type of health values to show inside the health bar.",
					data: { pref: "hud.bar.healthbar.text" },
					list: [
						{ label: "None", value: Const.e_HealthBarTextNone },
						{ label: "Actual Values", value: Const.e_HealthBarTextRaw },
						{ label: "Percentages", value: Const.e_HealthBarTextPercent }
					]
				},

				{	type: "section",
					label: "Background"
				},
				
				{	id: "hud.bar.background.type",
					type: "dropdown",
					label: "Style",
					tooltip: "The type of background panel to show as part of each target box.",
					data: { pref: "hud.bar.background.type" },
					list: [
						{ label: "None", value: Const.e_BackgroundTypeNone },
						{ label: "Flat", value: Const.e_BackgroundTypeFlat },
						{ label: "Gradient", value: Const.e_BackgroundTypeGradient }
					]
				},

				{	id: "hud.bar.background.tint",
					type: "dropdown",
					label: "Apply tint",
					tooltip: "When to apply a non-default to the background box.",
					data: { pref: "hud.bar.background.tint" },
					list: [
						{ label: "Never", value: Const.e_FxNever },
						{ label: "Always", value: Const.e_FxAlways },
						{ label: "When target is me", value: Const.e_FxWhenMe },
						{ label: "When target is not me", value: Const.e_FxWhenNotMe }
					]
				},
				
				{	type: "group"
				},
				
				{	id: "hud.bar.background.padding",
					type: "slider",
					min: 0,
					max: 30,
					valueFormat: "%i",
					label: "Padding",
					tooltip: "The internal padding within the background panel.",
					data: { pref: "hud.bar.background.padding" }
				},

				{	id: "hud.bar.background.alpha",
					type: "slider",
					min: 0,
					max: 100,
					valueFormat: "%i%%",
					label: "Transparency",
					tooltip: "The transparency level of the background panel.",
					data: { pref: "hud.bar.background.alpha" }
				},
				
				{	type: "section",
					label: "Glow FX"
				},
				
				{	id: "hud.bar.glow",
					type: "dropdown",
					label: "Apply glow",
					tooltip: "When to apply a glow effect around the target box.",
					data: { pref: "hud.bar.glow" },
					list: [
						{ label: "Never", value: Const.e_FxNever },
						{ label: "Always", value: Const.e_FxAlways },
						{ label: "When target is me", value: Const.e_FxWhenMe },
						{ label: "When target is not me", value: Const.e_FxWhenNotMe }
					]
				},

				{	type: "group"
				},
				
				{	id: "hud.bar.glow.size",
					type: "slider",
					min: 1,
					max: 6,
					valueFormat: "%i",
					label: "Size",
					tooltip: "The size of the glow effect.",
					data: { pref: "hud.bar.glow.size" }
				},

				{	id: "hud.bar.glow.intensity",
					type: "slider",
					min: 1,
					max: 4,
					valueFormat: "%i",
					label: "Intensity",
					tooltip: "The intensity of the glow effect.",
					data: { pref: "hud.bar.glow.intensity" }
				},
				
				{	type: "column"
				},
				
				{	type: "section",
					label: "Tints"
				},
				
				{	id: "hud.tints.background.default",
					type: "colorInput",
					label: "Default Background",
					data: { pref: "hud.tints.background.default" }
				},

				{	type: "group"
				},
				
				{	id: "hud.tints.background.enemy",
					type: "colorInput",
					label: "Enemy's Enemy (background)",
					data: { pref: "hud.tints.background.enemy" }
				},
				
				{	id: "hud.tints.glow.enemy",
					type: "colorInput",
					label: "Enemy's Enemy (glow)",
					data: { pref: "hud.tints.glow.enemy" }
				},
				
				{	type: "group"
				},
				
				{	id: "hud.tints.background.ally",
					type: "colorInput",
					label: "Enemy's Ally (background)",
					data: { pref: "hud.tints.background.ally" }
				},
				
				{	id: "hud.tints.glow.ally",
					type: "colorInput",
					label: "Enemy's Ally (glow)",
					data: { pref: "hud.tints.glow.ally" }
				},
				
				{	type: "group"
				},
				
				{	type: "button",
					text: "Reset Tints",
					onClick: Delegate.create( this, resetTintDefaults )
				},
				
				{	type: "section",
					label: "Size & Position"
				},
				
				{	type: "text",
					text: "Use GUI edit mode to manipulate the HUD.  Left-button drags a single box, right-button drags all boxes together, and mouse wheel adjusts scale."
				},
				
				{	type: "group"
				},
				
				{	id: "hud.scale",
					type: "slider",
					min: Const.MinHudScale,
					max: Const.MaxHudScale,
					step: 5,
					valueFormat: "%i%%",
					label: "Target Box Scale",
					tooltip: "The scale of the target boxes.  You can also change this in GUI Edit Mode by scrolling the mouse wheel while hovering over any box.",
					data: { pref: "hud.scale" }
				},

				{	type: "group"
				},
				
				{	type: "button",
					text: "Reset Position",
					tooltip: "Reset position of the boxes to default.",
					onClick: function() {
						App.prefs.setVal( "hud.position.default", true );
					}
				}
				
			]
		};
		
		// only add icon related settings if not using VTIO
		if ( !App.isRegisteredWithVtio ) {
			
			def.layout = def.layout.concat( [
				
				{	type: "group"
				},

				{	id: "icon.scale",
					type: "slider",
					min: Const.MinIconScale,
					max: Const.MaxIconScale,
					step: 5,
					valueFormat: "%i%%",
					label: "Icon Scale",
					tooltip: "The scale of the addon icon.  You can also change this in GUI Edit Mode by scrolling the mouse wheel while hovering over the icon.",
					data: { pref: "icon.scale" }
				},

				{	type: "button",
					text: "Reset icon position",
					tooltip: "Reset icon to its default position.",
					onClick: function() {
						App.prefs.setVal( "icon.position", undefined );
					}
				}
			] );
			
		}
		
		def.layout = def.layout.concat( [
			{	type: "section",
				label: "Global Reset"
			},

			{	type: "button",
				text: "Reset All",
				onClick: Delegate.create( this, resetAllDefaults )
			}
		] );
		
		// build the panel based on definition
		var panel:PanelBuilder = PanelBuilder( MovieClipHelper.createMovieWithClass( PanelBuilder, "m_Panel", this, this.getNextHighestDepth() ) );
		panel.build( def );
		
		// set up listener for pref changes
		App.prefs.SignalValueChanged.Connect( prefListener, this );
		
		def = {
			layout: [
				{	type: "button",
					text: "Visit forum thread",
					tooltip: "Click to open the in-game browser and visit the forum thread for the addon.",
					onClick: function() {
						DistributedValue.SetDValue("web_browser", false);
						DistributedValue.SetDValue("WebBrowserStartURL", "https://forums.thesecretworld.com/showthread.php?94295-MOD-ElTorqiro_TargetsSquared");
						DistributedValue.SetDValue("web_browser", true);
					}
				}
			]
		};
		
		var panel:PanelBuilder = PanelBuilder( MovieClipHelper.createMovieWithClass( PanelBuilder, "m_TitleBarPanel", this, this.getNextHighestDepth() ) );
		panel.build( def );
		
		panel._x = Math.round( _parent.m_Title.textWidth + 10 );
		panel._y -= Math.round( _y - _parent.m_Title._y + 1);
		
		SignalSizeChanged.Emit();
	}

	private function componentLoadHandler() : Void {
		this.setValue( App.prefs.getVal( this.data.pref ) );
	}

	private function componentSaveHandler() : Void {
		App.prefs.setVal( this.data.pref, this.getValue() );
	}

	/**
	 * listener for pref value changes, to update the config ui
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefListener( name:String, newValue, oldValue ) : Void {
		
		// only update controls that are using the pref shortcuts
		if ( m_Panel.components[ name ].api.data.pref ) {
			m_Panel.components[ name ].api.load();
		}
		
	}

	/**
	 * resets most settings to defaults, with a few exceptions
	 */
	private function resetAllDefaults() : Void {

		var prefs:Array = [

			"icon.position",
			"icon.scale",
			
			"hud.enabled",
			"hud.scale",
			"hud.position.default",
			
			"hud.bars.enemyEnemy.enabled",
			"hud.bars.enemyAlly.enabled",
			
			"hud.bars.enemyEnemy.position",
			"hud.bars.enemyAlly.position",
			
			"hud.bar.clickToSelect",
			
			"hud.bar.healthbar.enable",
			"hud.bar.healthbar.text",
			"hud.bar.size.x",
			"hud.bar.autosize",
			
			"hud.bar.background.type",
			"hud.bar.background.padding",
			"hud.bar.background.alpha",
			"hud.bar.background.tint",

			"hud.bar.glow",
			"hud.bar.glow.size",
			"hud.bar.glow.intensity"
		
		];
		
		for ( var s:String in prefs ) {
			App.prefs.reset( prefs[s] );
		}
		
		resetTintDefaults();
	}
	
	/**
	 * resets all tings to default values
	 */
	private function resetTintDefaults() : Void {
		
		for ( var s:String in App.prefs.list ) {
			
			if ( s.substr( 0, 10 ) == "hud.tints." ) {
				App.prefs.reset( s );
			}
			
		}
		
	}
	
	/**
	 * set the size of the content
	 * 
	 * @param	width
	 * @param	height
	 */
    public function SetSize(width:Number, height:Number) : Void {
		SignalSizeChanged.Emit();
    }

	/**
	 * return the dimensions of the content
	 * 
	 * @return dimensions of content size
	 */
    public function GetSize() : Point {
		return new Point( m_Panel.width, m_Panel.height );
    }
	
	/*
	 * internal variables
	 */
	
	public var m_Panel:MovieClip;
	public var m_TitleBarPanel:MovieClip;
	
	/*
	 * properties
	 */
	
}