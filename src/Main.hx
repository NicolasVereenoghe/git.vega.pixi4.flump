package;

import flump.library.FlumpLibrary;
import flump.pixi.Sprite;
import flump.pixi.Movie;
import flump.pixi.Parser;
import js.Browser;
import pixi.core.display.Container;
import pixi.loaders.Loader;

//import vega.shell.ApplicationMatchSize;
import pixi.plugins.app.Application;

/**
 * ...
 * @author nico
 */
class Main extends Application {
//class Main extends ApplicationMatchSize {
	var loader	: Loader;
	
	static function main() { new Main(); }
	
	public function new() {
		super();
		
		start();
		
		loader	= new Loader();
		loader.add( "assets/assetsTest/library.json?v=7");
		loader.after( Parser.parse( 1, "?v=7"));
		loader.load( onLoadComplete);
		
	}
	
	function onLoadComplete() : Void {
		loader.removeAllListeners();
		
		//for ( iLib in FlumpLibrary.libraries) iLib.destroy();
		//for ( iRes in Resource.resources) iRes.destroy();
		stage.addChild( new Movie( "test"));
		//stage.addChild( new Sprite( "rot_motif"));
		
		/*onUpdate = doUpdate;*/
	}
	
	function doUpdate( pT : Float) : Void {
		/*var lCont	: Container	= cast( getContent().getChildAt( 0), Movie).getLayer( "cube");
		
		lCont.y = 150 * Math.cos( Math.PI * 2 * pT / 1000) + 100;*/
	}
}