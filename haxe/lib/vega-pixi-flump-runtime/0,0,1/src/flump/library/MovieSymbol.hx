package flump.library;

import flump.json.FlumpJSON;

/**
 * library movie descriptor
 */
class MovieSymbol extends Symbol {
	/** number of frames of the movie */
	public var totalFrames( default, null)	: UInt;
	
	/** reference on the movie's descriptor raw datas */
	public var movieSpec( default, null)	: MovieSpec;
	
	/** map of layer descriptors indexed by identifier */
	var layers								: Map<String,Layer>;
	
	/**
	 * constructor
	 * @param	pLib		the library instance that owns this symbol
	 * @param	pMovieSpec	reference on the movie's descriptor raw datas
	 */
	public function new( pLib : FlumpLibrary, pMovieSpec : MovieSpec) {
		super( pLib);
		
		movieSpec = pMovieSpec;
		
		buildLayerMap();
	}
	
	/** @inheritDoc */
	override public function destroy() : Void {
		for ( iLayer in layers) iLayer.destroy();
		
		layers = null;
		
		movieSpec = null;
		
		super.destroy();
	}
	
	/**
	 * gets the layer with the specified layer identifier
	 * @param	pId	layer identifier
	 * @return	layer descriptor with the specified identifier ; null if no corresponding identifier
	 */
	public function getLayer( pId : String) : Layer {
		if ( layers.exists( pId)) return layers.get( pId);
		else return null;
	}
	
	/**
	 * gets the layer at the specified layer index
	 * @param	pIndex	layer index : [ 0 .. nbLayers - 1]
	 * @return	layer descriptor at the specified layer index
	 */
	public function getLayerAt( pIndex : Int) : Layer { return getLayer( movieSpec.layers[ pIndex].name); }
	
	/**
	 * gets the number of layers contained by a described movie instance
	 * @return	number of layers described
	 */
	public function getNbLayers() : Int { return movieSpec.layers.length; }
	
	/**
	 * parse and build layer descriptors
	 */
	function buildLayerMap() : Void {
		var lLayer	: Layer;
		
		totalFrames = 0;
		layers		= new Map<String,Layer>();
		
		for ( iLSpec in movieSpec.layers){
			lLayer	= new Layer( this, iLSpec);
			layers.set( lLayer.name, lLayer);
			
			if ( lLayer.totalFrames > totalFrames) totalFrames = lLayer.totalFrames;
		}
	}
	
	// getters
	
	override function get_name() : String { return movieSpec.id; }
}