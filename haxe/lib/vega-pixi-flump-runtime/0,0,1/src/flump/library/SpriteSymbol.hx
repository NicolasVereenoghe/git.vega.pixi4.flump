package flump.library;

import flump.json.FlumpJSON;

import pixi.core.textures.Texture;

/**
 * library sprite descriptor
 */
class SpriteSymbol extends Symbol {
	/** the texture reference */
	public var texture					: Texture;
	
	/** the origin of the texture */
	public var origin( get, null)		: FlumpPointSpec;
	
	/** reference on the sprite's texture descriptor raw datas */
	var textureSpec						: TextureSpec;
	
	/**
	 * constructor
	 * @param	pLib			the library instance that owns this symbol
	 * @param	pTextureSpec	reference on the sprite's texture descriptor raw datas
	 */
	public function new( pLib : FlumpLibrary, pTextureSpec : TextureSpec){
		super( pLib);
		
		textureSpec = pTextureSpec;
	}
	
	/** @inheritDoc */
	override public function destroy() : Void {
		if ( texture != null) {
			texture.destroy( true);
			texture = null;
		}
		
		textureSpec = null;
		
		super.destroy();
	}
	
	// getters
	
	override function get_name() : String { return textureSpec.symbol; }
	function get_origin() : FlumpPointSpec { return textureSpec.origin; }
}