package flump.library;

import flump.json.FlumpJSON;

/**
 * library movie's layer description
 */
class Layer {
	/** reference on layer's movie descriptor */
	public var movie( default, null)			: MovieSymbol;
	
	/** layer's identifier */
	public var name( get, null)					: String;
	
	/** number of frames on this layer timeline */
	public var totalFrames( default, null)		: UInt;
	
	/** referenceon the layer descriptor raw datas */
	var layerSpec								: LayerSpec;
	
	/**
	 * constructor
	 * @param	pMovieSymbol	the library movie which owns this layer
	 * @param	pLayerDesc		reference on the layer descriptor raw datas
	 */
	public function new( pMovieSymbol : MovieSymbol, pLayerDesc : LayerSpec) {
		movie		= pMovieSymbol;
		layerSpec	= pLayerDesc;
		
		parseKeyframes();
	}
	
	/**
	 * destructor
	 */
	public function destroy() : Void {
		movie = null;
		layerSpec = null;
	}
	
	/**
	 * gets the keyframe at the specified frame index
	 * @param	pIndex		frame index [ 0 .. movie.totalFrames - 1]
	 * @param	pFromKFrame	keyframe wrapper instance from where to begin the searching ; if null, search from the first keyframe
	 * @return	keyframe descriptor wrapper ; if index out of range, return an empty keyframe instance
	 */
	public function getKeyframeAt( pIndex : Int, pFromKFrame : Keyframe = null) : Keyframe {
		var lFrI	: Int;
		var lPrev	: Keyframe;
		
		if ( pIndex >= totalFrames){
			return new Keyframe(
				cast {
					duration: movie.totalFrames - totalFrames,
					index: totalFrames,
				},
				this,
				getNbKeyframes()
			);
		}
		
		if ( pFromKFrame == null) pFromKFrame = getKeyframeAtKframeIndex( 0);
		
		if ( pIndex == pFromKFrame.index) return pFromKFrame;
		else if ( pIndex < pFromKFrame.index){
			do{
				pFromKFrame = getKeyframeAtKframeIndex( pFromKFrame.kFrameIndex - 1);
			}while ( pIndex < pFromKFrame.index);
		}else{
			while ( pIndex >= pFromKFrame.index + pFromKFrame.numFrames){
				pFromKFrame = getKeyframeAtKframeIndex( pFromKFrame.kFrameIndex + 1);
			}
		}
		
		return pFromKFrame;
	}
	
	/**
	 * gets the keyframe raw datas wrapper at the specified keyframe index
	 * @param	pKFrameIndex	keyframe index [ 0 .. nbKeyframes - 1]
	 * @return	keyframe raw datas wrapper
	 */
	function getKeyframeAtKframeIndex( pKFrameIndex : Int) : Keyframe { return new Keyframe( layerSpec.keyframes[ pKFrameIndex], this, pKFrameIndex); }
	
	/**
	 * gets the number of keyframes defined in this layer's timeline
	 * @return	number of keyframes
	 */
	function getNbKeyframes() : Int { return layerSpec.keyframes.length; }
	
	/**
	 * parse keyframes raw datas to process ::totalFrames
	 */
	function parseKeyframes() : Void {
		totalFrames	= 0;
		
		for ( iKSpec in layerSpec.keyframes) totalFrames += iKSpec.duration;
	}
	
	// getters
	
	function get_name() : String { return layerSpec.name; }
}