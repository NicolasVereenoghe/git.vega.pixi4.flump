package flump.pixi;

import flump.library.FlumpLibrary;
import flump.library.Keyframe;
import flump.library.Layer;
import flump.library.MovieSymbol;
import flump.library.Symbol;

import pixi.interaction.InteractionEvent;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.ticker.Ticker;

import haxe.extern.EitherType;

/**
 * Movie implementation of the Flump model
 */
class Movie extends Container implements ISymbol {
	/** @inheritDoc */
	public var symbol( default, null)					: Symbol;
	
	/** true (default) to automaticaly loop the movie timeline ; when set to false, if the timeline is played, it will stops at its last frame */
	public var loop( default, set)						: Bool;
	
	/** number of frames of the movie */
	public var totalFrames( get, null)					: UInt;
	
	/** the current rendered frame index : [ 0 .. totalFrames - 1] */
	public var currentFrame( get, set)					: Int;
	var _currentFrame									: Int;
	
	/** progression rate into the current rendered frame (interpolation to the next frame) : [ 0 .. 1 [ */
	public var currentRate( default, null)				: Float;
	
	/** running state layers datas, indexed by layer name */
	var layersDatas										: Map<String,LayerDatas>;
	
	/**
	 * contructor
	 * @param	pSymbolId	the symbol link identifier
	 * @param	pLibId		library identifier of the symbol ; let null for "global domain"
	 * @param	pOnLayer	if the symbol is created on a movie layer, we use this reference to setup initial rendered frame ; null to dont manage synchronisation on a layer
	 */
	public function new( pSymbolId : String, pLibId : String = null, pOnLayer : LayerDatas = null) {
		super(); // TODO !!
		
		if ( pLibId != null){
			symbol = FlumpLibrary.libraries.get( pLibId).symbols.get( pSymbolId);
		}else{
			symbol = FlumpLibrary.findLibraySymbolFromId( pSymbolId);
		}
		
		if ( symbol == null) throw( "Flump movie does not exist: " + pSymbolId + " : " + pLibId);
		if( ! Std.is( symbol, MovieSymbol)) throw( "Wrong symbol type for Flump movie : " + pSymbolId + " : " + pLibId);
		
		loop			= true;
		
		if( pOnLayer == null){
			_currentFrame	= 0;
			currentRate		= 0;
		}else{
			_currentFrame	= ( pOnLayer.movie.currentFrame - pOnLayer.curKFr.index) % totalFrames; // WARNING : don't resolve discontinuous timeline if the player skips some frames
			
			if ( totalFrames > 1) currentRate = pOnLayer.movie.currentRate;
			else currentRate = 0;
		}
		
		initLayers();
		
		render();
		
		// if( totalFrames > 1)
		//once( "added", onAdded);
		
		// TODO !!
	}
	
	/** @inheritDoc */
	override public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		// TODO !!
		
		freeLayers();
		
		symbol = null;
		
		super.destroy( options);
	}
	
	/**
	 * initialize the layer structure of the movie
	 */
	function initLayers() : Void {
		var lNb		: Int		= cast( symbol, MovieSymbol).getNbLayers();
		var lI		: Int		= 0;
		var lCont	: Container;
		var lLayer	: Layer;
		
		layersDatas = new Map<String,LayerDatas>();
		
		while ( lI < lNb){
			lCont		= cast addChild( new Container());
			lLayer		= cast( symbol, MovieSymbol).getLayerAt( lI);
			lCont.name	= lLayer.name;
			
			layersDatas.set( lLayer.name, new LayerDatas( this, lLayer, lCont));
			
			lI++;
		}
	}
	
	/**
	 * remove the layers and its content in order to destroy the movie
	 */
	function freeLayers() : Void {
		for ( iData in layersDatas) iData.destroy();
	}
	
	/**
	 * do render the movie content at the current frame & rate progression
	 */
	function render() : Void {
		var lNb		: Int			= cast( symbol, MovieSymbol).getNbLayers();
		var lI		: Int			= 0;
		var lDatas	: LayerDatas;
		
		while ( lI < lNb){
			lDatas = layersDatas.get( cast( symbol, MovieSymbol).movieSpec.layers[ lI].name);
			
			lDatas.render();
			
			lI++;
		}
	}
	
	/**
	 * catch "added" event
	 * @param	pE	event
	 */
	/*function onAdded( pE : InteractionEvent) : Void {
		once( "removed", onRemoved);
		
		Ticker.shared.add( tick);
	}*/
	
	/**
	 * catch "removed" event
	 * @param	pE	event
	 */
	/*function onRemoved( pE : InteractionEvent) : Void {
		once( "added", onAdded);
		
		Ticker.shared.remove( tick);
	}*/
	
	/**
	 * catch the ticker "tick"
	 */
	/*function tick() : Void {
		// TODO : Ticker.shared.deltaTime
	}*/
	
	// getters
	
	function get_totalFrames() : UInt { return cast( symbol, MovieSymbol).totalFrames; }
	
	function get_currentFrame() : Int { return _currentFrame; }
	
	// setters
	
	function set_loop( pIsLoop : Bool) : Bool {
		// TODO !!
		
		return loop = pIsLoop;
	}
	
	function set_currentFrame( pFr : Int) : Int {
		// TODO !!
		
		// chech valid datas
		
		// currentRate = 0; ?
		
		return _currentFrame = pFr;
	}
}

class LayerDatas {
	public var cont( default, null)		: Container;
	
	public var content( default, null)	: DisplayObject					= null;
	
	public var movie( default, null)	: Movie;
	public var layer( default, null)	: Layer;
	
	public var curKFr( default, null)	: Keyframe						= null;
	
	public function new( pMovie : Movie, pLayer : Layer, pCont : Container) {
		movie	= pMovie;
		layer	= pLayer;
		cont	= pCont;
	}
	
	public function destroy() : Void {
		freeContent();
		
		cont.parent.removeChild( cont).destroy();
		cont = null;
		
		movie = null;
		layer = null;
		curKFr = null;
	}
	
	function freeContent() : Void {
		if ( content != null){
			cont.removeChild( content).destroy();
			content = null;
		}
	}
	
	public function render() : Void {
		var lKeyframe	: Keyframe	= layer.getKeyframeAt( movie.currentFrame, curKFr);
		
		if ( lKeyframe.isEmpty){
			curKFr = lKeyframe;
			
			freeContent();
		}else if ( curKFr == null || curKFr.isEmpty){
			curKFr = lKeyframe;
			
			ceateContent( lKeyframe);
		}else if ( curKFr.symbolId == lKeyframe.symbolId){ // WARNING : don't resolve discontinuous timeline if the player skips some frames
			curKFr = lKeyframe;
			
			updateContent( lKeyframe);
		}else{
			curKFr = lKeyframe;
			
			freeContent();
			ceateContent( lKeyframe);
		}
	}
	
	function ceateContent( pKeyframe : Keyframe) : Void {
		content = cont.addChild( cast FlumpLibrary.createSymbol( pKeyframe.symbolId, movie.symbol.library.id, this));
		
		updateContent( pKeyframe);
	}
	
	function updateContent( pKeyframe : Keyframe) : Void {
		
	}
}

class MasterFramer {
	// TODO !!
}