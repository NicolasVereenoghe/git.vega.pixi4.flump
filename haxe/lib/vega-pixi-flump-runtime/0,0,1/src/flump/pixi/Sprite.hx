package flump.pixi;

import flump.library.FlumpLibrary;
import flump.library.SpriteSymbol;
import flump.library.Symbol;

import pixi.core.display.DisplayObject;

import haxe.extern.EitherType;

/**
 * Sprite implementation of the Flump model
 */
class Sprite extends pixi.core.sprites.Sprite implements ISymbol {
	/** @inheritDoc */
	public var symbol( default, null)					: Symbol;
	
	/**
	 * contructor
	 * @param	pSymbolId	the symbol link identifier
	 * @param	pResourceId	library identifier of the symbol ; let null for "global domain"
	 */
	public function new( pSymbolId : String, pResourceId : String = null) {
		var lSymbol		: Symbol;
		
		if ( pResourceId != null){
			lSymbol = FlumpLibrary.libraries.get( pResourceId).symbols.get( pSymbolId);
		}else{
			lSymbol = FlumpLibrary.findLibraySymbolFromId( pSymbolId);
		}
		
		if ( lSymbol == null) throw( "Flump sprite does not exist: " + pSymbolId + " : " + pResourceId);
		if( ! Std.is( lSymbol, SpriteSymbol)) throw( "Wrong symbol type for Flump sprite : " + pSymbolId + " : " + pResourceId);
		
		super( cast( lSymbol, SpriteSymbol).texture);
		
		symbol = lSymbol;
		
		anchor.x = cast( symbol, SpriteSymbol).origin.x / texture.width;
		anchor.y = cast( symbol, SpriteSymbol).origin.y / texture.height;
	}
	
	/** @inheritDoc */
	override public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		symbol = null;
		
		super.destroy();
	}
}