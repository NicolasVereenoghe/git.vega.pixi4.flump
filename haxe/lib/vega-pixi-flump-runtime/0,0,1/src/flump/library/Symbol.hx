package flump.library;

/**
 * library symbol descriptor
 */
class Symbol {
	/** symbol identifier */
	public var name( get, null)				: String;
	
	/** reference on symbol's library */
	public var library( default, null)		: FlumpLibrary;
	
	/**
	 * constructor
	 * @param	pLib	the library instance that owns this symbol
	 */
	public function new( pLib : FlumpLibrary) { library = pLib; }
	
	/**
	 * destructor
	 */
	public function destroy() : Void { library = null; }
	
	// getters
	
	function get_name() : String { return null; }
}