package flump.pixi;

import flump.library.FlumpLibrary;
import flump.library.SpriteSymbol;
import flump.json.FlumpJSON;

import haxe.Timer;

import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.BaseTexture;
import pixi.core.textures.Texture;
import pixi.loaders.Loader;
import pixi.loaders.Resource;

/**
 * sample parser to load atlas files and initialize a Flump library from a json Flump descriptor file
 */
class Parser {
	/** time to wait in ms before reloading atlases if an error occures */
	var RELOAD_DELAY					: Int							= 3000;
	
	/** resolution factor to apply to loaded Flump assets */
	var resolution						: Float;
	
	/** string to add to atlas files names (cache control, ie: "?v=42") ; null to don't add anything */
	var addUrl							: String;
	
	/** Resource instance from the loaded json file */
	var jsonResource					: Resource;
	
	/** callback function to signal the end of loading and resources building */
	var afterJSonCallback				: Void->Void;
	
	/** loader instance used to load the queue of atlas files */
	var atlasLoader						: Loader;
	
	/** library descriptor instance of the current loading content */
	var lib								: FlumpLibrary;
	
	/** map of loaded textures indexed by symbol identifier */
	var textures						: Map<String,Texture>;
	
	/**
	 * build a middleware function to manage atlas loading and build resources instances
	 * plug this to the pixi.loaders.Loader::after utility, of the loader instance responsible for loading a json Flump descriptor file
	 * @param	pResolution	resolution factor to apply to loaded Flump assets
	 * @param	pAddUrl		string to add to atlas files names (cache control, ie: "?v=42") ; null to don't add anything
	 * @return	middleware function to use with the pixi.loaders.Loader::after utility
	 */
	public static function parse( pResolution : Float = 1, pAddUrl : String = null) : Resource->(Void->Void)->Void {
		return ( new Parser( pResolution, pAddUrl)).afterJSonLoadAtlas;
	}
	
	/**
	 * constructor : the instance keeps the parameters persistant when using the Parser::afterJSonLoadAtlas middleware
	 * @param	pResolution	resolution factor to apply to loaded Flump assets
	 * @param	pAddUrl		string to add to atlas files names (cache control) ; null to don't add anything
	 */
	function new( pResolution : Float = 1, pAddUrl : String = null) {
		resolution	= pResolution;
		addUrl		= pAddUrl;
	}
	
	/**
	 * middleware function to manage atlas loading and build resources instances
	 * @param	pResource	the loaded json Flump descriptor file's Resource instance ; used to establish the list of atlas to load
	 * @param	pNext		callback function to signal the end of loading and resources building
	 */
	function afterJSonLoadAtlas( pResource : Resource, pNext : Void->Void) : Void {
		var lData : Dynamic = pResource.data;
		
		jsonResource		= pResource;
		afterJSonCallback	= pNext;
		
		if ( pResource.error != null || lData == null || ! pResource.isJson || ! Reflect.hasField( lData, "md5") || ! Reflect.hasField( lData, "movies") || ! Reflect.hasField( lData, "textureGroups") || ! Reflect.hasField( lData, "frameRate")){
			onError();
			return;
		}
		
		lib			= new FlumpLibrary( lData, resolution, pResource.url.split( "?")[ 0]);
		textures	= new Map<String,Texture>();
		
		atlasLoader = new Loader();
		atlasLoader.on( "error", onAtlasError);
		atlasLoader.on( "complete", onAtlasLoadComplete);
		
		buildAtlasLoadQ();
		
		doAtlasLoad();
	}
	
	/**
	 * build the atlases load queue
	 * @param	pForceAntiCache	true to prevent from cached file, else false
	 */
	function buildAtlasLoadQ( pForceAntiCache : Bool = false) : Void {
		var lBase		: String		= ~/\/(.[^\/]*)$/i.replace( jsonResource.url, "");
		var lI			: Int			= 0;
		var lSpec		: AtlasSpec;
		var lFile		: String;
		
		while ( lI < lib.getNbAtlases()){
			lSpec	= lib.getAtlasAt( lI);
			lFile	= lBase + "/" + lSpec.file;
			
			if ( pForceAntiCache) lFile += "?" + Date.now().getTime();
			else if ( addUrl != null) lFile += addUrl;
			
			atlasLoader.add( lSpec.file, lFile, onAtlasLoaded);
			
			lI++;
		}
	}
	
	/**
	 * triggers the loading of the atlas load queue
	 */
	function doAtlasLoad() : Void { atlasLoader.load(); }
	
	/**
	 * an atlas is loaded
	 * @param	pResource	loading resource descriptor
	 */
	function onAtlasLoaded( pResource : Resource) : Void {
		var lSpecs		: Array<TextureSpec>	= lib.getAtlasWithFileName( pResource.name).textures;
		var lTexture	: BaseTexture			= new BaseTexture( pResource.data);
		
		// TODO : include resolution effect
		// lTexture.resolution = resolution;
		
		for ( iSpec in lSpecs){
			cast( lib.symbols.get( iSpec.symbol), SpriteSymbol).texture = new Texture( lTexture, new Rectangle( iSpec.rect.x, iSpec.rect.y, iSpec.rect.width, iSpec.rect.height));
		}
	}
	
	/**
	 * all atlases are loaded
	 */
	function onAtlasLoadComplete( pLoader : Loader) : Void {
		afterJSonCallback();
		
		clear();
	}
	
	/**
	 * the Flump descriptor is not correctly loaded
	 */
	function onError() : Void {
		trace( "ERROR : Parser::onError");
		trace( jsonResource);
	}
	
	/**
	 * an atlas fails to load
	 */
	function onAtlasError() : Void {
		trace( "ERROR : Parser::onAtlasError : reload");
		
		atlasLoader.reset();
		
		buildAtlasLoadQ( true);
		
		Timer.delay( doAtlasLoad, RELOAD_DELAY);
	}
	
	/**
	 * clear references from this instance, to prepare it to be garbage collected
	 */
	function clear() : Void {
		addUrl = null;
		jsonResource = null;
		afterJSonCallback = null;
		atlasLoader.removeAllListeners();
		atlasLoader = null;
		lib = null;
		textures = null;
	}
}