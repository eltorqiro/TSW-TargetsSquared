ElTorqiro_TargetsSquared
========================
A target tracking UI mod for the MMORPG "The Secret World"
   
   
What is this?
-------------
ElTorqiro_TargetsSquared is a target tracking module, which allows you to see what your offensive target is focusing on. Feature highlights:

* track your enemy's offensive target - useful in dungeons to know definitively what is happening with agro
* track your enemy's defensive target - useful in PvP to know who an enemy healer is focusing on
* fully customisable visuals, including highlight effects that are applied when you want (e.g. when you lose/gain agro!)
* option to select target as your own when clicking a target box

Join the conversation with feedback, bug reports, and update information on the official TSW forums at https://forums.thesecretworld.com/showthread.php?94295-MOD-ElTorqiro_TargetsSquared
   
   
Important Notes
---------------
* Remember that this shows you your offensive target's targets, so unless you are targeting a mob or player that has targeted something, there won't be anything on your screen.
  
  
Donations
---------
I don't accept real-money donations for my mods.  If you would like to show your support, you can do so by sending in-game pax to my character Tufenuf.  I will use it to buy the in-game items I would otherwise have been able to grind out myself, if I weren't spending time writing mods.
  
  
Configuration
-------------
The mod includes an on-screen icon which can be clicked to bring up a comprehensive configuration panel.  If you have Viper's Topbar Information Overload (VTIO) installed, or an equivalent handler, the icon will be available in a VTIO slot.
   
Manipulating the HUD boxes and the icon is done via TSW's Gui Edit Mode, which is toggled in the game by clicking the padlock symbol in the top right corner of the screen. Left-button drags a single box, right-button drags all boxes together, and mouse wheel adjusts scale. These instructions are repeated in the config window.  
  
  
Installation
------------
The mod is released with CurseMod support, so you can use the Curse client to handle adding and removing it from the game.  Manual installation can also be done, as follows:
  
Manual Installation
Ensure the game is closed, then extract only the Flash folder from the zip file into TSW_GAME_FOLDER\Data\Gui\Customized
  
Manual Uninstallation
Ensure the game is closed, then delete the folder TSW_GAME_FOLDER\Data\Gui\Customized\Flash\ElTorqiro_TargetsSquared
  
  
Source Code
-----------
You can get the source from GitHub at https://github.com/eltorqiro/TSW-TargetsSquared
	
   
Derivation
----------
TargetsSquared was inspired by an original idea by The009, and was originally co-implemented by us as a plugin for my UITweaks mod, called _Target of Target_. It contained base functionality for viewing enemy offensive & defensive targets.

Since the 1.x UITweaks rewrite changed the way plugins were incorporated into the framework, I also had to rewrite all the plugins. As a result, I started adding several new requested features to _Target of Target_, until it reached a point where I decided it had become complex enough that it didn't really fit into the UITweaks mission statement and deserved to be its own mod. So I have gone back and implemented this mod from scratch, which is inspired by The009's original idea, but uses none of the original code we produced together.