package flump.library;

import flump.json.FlumpJSON;
import flump.pixi.ISymbol;
import flump.pixi.Movie;
import flump.pixi.Sprite;

import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;

/**
 * Flump library descriptor
 */
class FlumpLibrary {
	/** map of flump resources, indexed by resource identifier */
	public static var libraries( default, null)			: Map<String,FlumpLibrary>				= new Map<String,FlumpLibrary>();
	
	/** library identifier ; ie : json file path + name */
	public var id( default, null)						: String;
	
	/** resolution factor applyed to library content */
	public var resolution( default, null)				: Float;
	
	/** collection of symbol descriptors defined into this library ; indexed by symbol identifier */
	public var symbols( default, null)					: Map<String,Symbol>;
	
	/** framerate defined for this library */
	public var framerate( get, null)					: UInt;
	
	/** frame time in ms */
	public var frameTime( get, null)					: Float;
	
	/** md5 check sum from the provided raw json */
	public var md5( get, null)							: String;
	
	/** raw json flump datas for this library */
	var datas											: FlumpJSON;
	
	/** current TextureGroupSpec instance selected that best suits the defined resolution */
	var curTGSpec										: TextureGroupSpec;
	
	/**
	 * finds the library symbol descriptor corresponding to the specified symbol identifier in all libraries
	 * @param	pSymbolId	symbol identifier
	 * @return	the first librayry symbol occurance that macthes the identifier ; null if not found
	 */
	public static function findLibraySymbolFromId( pSymbolId : String) : Symbol {
		for ( iLib in libraries){
			if ( iLib.symbols.exists( pSymbolId)) return iLib.symbols.get( pSymbolId);
		}
		
		return null;
	}
	
	/**
	 * tests if a symbol is defined into loaded libraries
	 * @param	pSymbolId	symbol identifier
	 * @param	pLibId		library identifier ; null to check in every libraries
	 * @return	true if symbol defined, else false
	 */
	public static function exists( pSymbolId : String, pLibId : String = null) : Bool {
		if ( pLibId == null){
			for ( iLib in libraries) if ( iLib.symbols.exists( pSymbolId)) return true;
			
			return false;
		}else return libraries.exists( pLibId) && libraries.get( pLibId).symbols.exists( pSymbolId);
	}
	
	/**
	 * instanciate a symbol
	 * @param	pSymbolId	symbol identifier
	 * @param	pLibId		library identifier ; null to get the first definition found in every libraries
	 * @param	pOnLayer	if the symbol is created on a movie layer, we use this reference to setup initial rendered frame ; null to dont manage synchronisation on a layer
	 * @return	symbol instance
	 */
	public static function createSymbol( pSymbolId : String, pLibId : String = null, pOnLayer : LayerDatas = null) : ISymbol {
		var lSymbol	: Symbol;
		
		if ( pLibId == null) lSymbol = findLibraySymbolFromId( pSymbolId);
		else lSymbol = libraries.get( pLibId).symbols.get( pSymbolId);
		
		if ( Std.is( lSymbol, SpriteSymbol)) return new Sprite( pSymbolId, lSymbol.library.id);
		else return new Movie( pSymbolId, lSymbol.library.id, pOnLayer);
	}
	
	/**
	 * constructor
	 * @param	pDatas		raw json flump datas
	 * @param	pResolution	resolution factor to apply to library content
	 * @param	pId			library identifier
	 */
	public function new( pDatas : FlumpJSON, pResolution : Float, pId : String) {
		resolution	= pResolution;
		symbols		= new Map<String,Symbol>();
		datas		= pDatas;
		id			= pId;
		curTGSpec	= getSmartestTGSpec();
		
		addSprites();
		addMovies();
		
		libraries.set( id, this);
	}
	
	/**
	 * free resource memory, unregister it to be garbage collected
	 */
	public function destroy() : Void {
		libraries.remove( id);
		
		for ( iSym in symbols) iSym.destroy();
		
		symbols = null;
		
		datas = null;
		
		curTGSpec = null;
	}
	
	/**
	 * gets the atlas raw datas at the specified index from the selected TextureGroupSpec instance
	 * @param	pIndex	atlas raw datas index : [ 0 .. nbAtlases - 1]
	 * @return	atlas raw datas
	 */
	public function getAtlasAt( pIndex : Int) : AtlasSpec { return curTGSpec.atlases[ pIndex]; }
	
	/**
	 * gets the number of atlas from the selected TextureGroupSpec instance
	 * @return	number of atlas defined from the selected TextureGroupSpec instance
	 */
	public function getNbAtlases() : Int { return curTGSpec.atlases.length; }
	
	/**
	 * gets the atlas raw datas with the specified atlas file name, from the selected TextureGroupSpec instance
	 * @param	pName	file name of the searched atlas raw datas
	 * @return	atlas raw datas ; null if not found
	 */
	public function getAtlasWithFileName( pName : String) : AtlasSpec {
		for ( iASpec in curTGSpec.atlases){
			if ( iASpec.file == pName) return iASpec;
		}
		
		return null;
	}
	
	/**
	 * Find best suited resolution from available textures
	 * @return	TextureGroupSpec instance that best suites the resolution among the provided
	 */
	function getSmartestTGSpec() : TextureGroupSpec {
		var lTGSpecs : Array<TextureGroupSpec>	= datas.textureGroups;
		
		for ( iTG in lTGSpecs) if ( iTG.scaleFactor >= resolution) return iTG;
		
		return lTGSpecs[ lTGSpecs.length - 1];
	}
	
	/**
	 * parse json datas in order to index sprite descriptors by identifier into the ::symbols map
	 */
	function addSprites() : Void {
		for ( iASpec in curTGSpec.atlases){
			for ( iTSpec in iASpec.textures) symbols.set( iTSpec.symbol, new SpriteSymbol( this, iTSpec));
		}
	}
	
	/**
	 * parse json datas in order to index movie descriptors by identifier into the ::symbols map
	 */
	function addMovies() : Void {
		for ( iMSpec in datas.movies) symbols.set( iMSpec.id, new MovieSymbol( this, iMSpec));
	}
	
	// getters
	
	function get_framerate() : UInt { return datas.frameRate; }
	function get_frameTime() : Float { return 1000 / framerate; }
	function get_md5() : String { return datas.md5; }
}