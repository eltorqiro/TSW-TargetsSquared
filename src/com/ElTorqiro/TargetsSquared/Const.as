

/**
 * shared constants used throughout the app
 * 
 */
class com.ElTorqiro.TargetsSquared.Const {
	
	// static class only, cannot be instantiated
	private function Const() { }

	// app information
	public static var AppID:String = "ElTorqiro_TargetsSquared";
	public static var AppName:String = "TargetsSquared";
	public static var AppAuthor:String = "ElTorqiro";
	public static var AppVersion:String = "1.2.0";

	public static var DebugModeDV:String = "ElTorqiro_TargetsSquared_Debug";
	
	public static var PrefsName:String = "ElTorqiro_TargetsSquared_Preferences";
	public static var PrefsVersion:Number = 10020;
	
	public static var HudClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerMiddle;
	public static var HudClipSubDepth:Number = 2;
	public static var HudClipSubDepthGuiEditMode:Number = 50;
	
	public static var IconClipPath:String = "ElTorqiro_TargetsSquared\\Icon.swf";
	public static var IconClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerTop;
	public static var IconClipSubDepth:Number = 2;
	
	public static var ConfigWindowClipPath:String = "ElTorqiro_TargetsSquared\\ConfigWindow.swf";
	public static var ConfigWindowClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerTop;
	public static var ConfigWindowClipSubDepth:Number = 0;

	public static var ShowConfigWindowDV:String = "ElTorqiro_TargetsSquared_ShowConfigWindow";
	
	public static var MinHudScale:Number = 50;
	public static var MaxHudScale:Number = 200;
	
	public static var MinIconScale:Number = 30;
	public static var MaxIconScale:Number = 200;
	
	// highlight preferences
	public static var e_FxNever:Number = 0;
	public static var e_FxAlways:Number = 1;
	public static var e_FxWhenMe:Number = 2;
	public static var e_FxWhenNotMe:Number = 3;
	
	// background types
	public static var e_BackgroundTypeNone:String = "none";
	public static var e_BackgroundTypeFlat:String = "flat";
	public static var e_BackgroundTypeGradient:String = "gradient";
	
	// health bar text types
	public static var e_HealthBarTextNone:Number = 0;
	public static var e_HealthBarTextRaw:Number = 1;
	public static var e_HealthBarTextPercent:Number = 2;
	
	// width types for auto sizing
	public static var e_AutoSizeNone:Number = 0;
	public static var e_AutoSizeLeft:Number = 1;
	public static var e_AutoSizeRight:Number = 2;
	
}