package flump.library;

import flump.json.FlumpJSON;
import pixi.core.math.Point;

/**
 * wrapper in order to serve KeyframeSpec raw datas
 */
class Keyframe {
	/** zero vector reference */
	static var ZERO									: FlumpPointSpec					= cast [ 0.0, 0.0];
	/** unity vector reference */
	static var UNITY								: FlumpPointSpec					= cast [ 1.0, 1.0];
	
	/** reference on layer's decriptor that owns this keyframe */
	public var layer( default, null)				: Layer;
	
	/** duration of the keyframe in number of frames */
	public var numFrames( get, null)				: UInt;
	
	/** frame index of the beginning of the keyframe ; [ 0 .. totalFrames - 1] */
	public var index( get, null)					: UInt;
	
	/** true if the keyframe is empty, else false */
	public var isEmpty( get, null)					: Bool;
	
	/** identifier of the symbol's descriptor found at this keyframe */
	public var symbolId( get, null)					: String;
	
	/** the pivot point */
	public var pivot( get, null)					: FlumpPointSpec;
	
	/** location point */
	public var location( get, null)					: FlumpPointSpec;
	
	/** true if there's a tweening to the next keyframe, else false */
	public var tweened( get, null)					: Bool;
	
	/** scale x & y coefficients */
	public var scale( get, null)					: FlumpPointSpec;
	
	/** alpha rate [ 0 .. 1] */
	public var alpha( get, null)					: Float;
	
	/** skew x & y coefficients */
	public var skew( get, null)						: FlumpPointSpec;
	
	/** easing coefficient */
	public var ease( get, null)						: Float;
	
	/** keyframe index in raw datas ; used internally to quickly compute the next keyframe */
	public var kFrameIndex( default, null)			: Int;
	
	/** reference on keyframe raw datas */
	var spec										: KeyframeSpec;
	
	/**
	 * constructor
	 * @param	pSpec			keyframe raw data
	 * @param	pLayer			reference on layer's decriptor that owns this keyframe
	 * @param	pKFrameIndex	keyframe index in raw datas ; used internally to quickly compute the next keyframe
	 */
	public function new( pSpec : KeyframeSpec, pLayer : Layer, pKFrameIndex : Int) {
		spec		= pSpec;
		layer		= pLayer;
		kFrameIndex	= pKFrameIndex;
	}
	
	// getters
	
	function get_numFrames() : UInt { return spec.duration; }
	function get_index() : UInt { return spec.index; }
	function get_isEmpty() : Bool { return ( spec.ref == null); }
	function get_symbolId() : String { return spec.ref; }
	function get_pivot() : FlumpPointSpec { return spec.pivot == null ? ZERO : spec.pivot; } // TODO : ne tient pas compte de resolution ; à reporter lors de l'utilisation
	function get_location() : FlumpPointSpec { return spec.loc == null ? ZERO : spec.loc; } // TODO : ne tient pas compte de resolution ; à reporter lors de l'utilisation
	function get_tweened() : Bool { return ! ( spec.tweened == false); }
	function get_scale() : FlumpPointSpec { return spec.scale == null ? UNITY : spec.scale; }
	function get_skew() : FlumpPointSpec { return spec.skew == null ? ZERO : spec.skew; }
	function get_alpha() : Float { return spec.alpha == null ? 1 : spec.alpha; }
	function get_ease() : Float { return spec.ease == null ? 0 : spec.ease; }
}