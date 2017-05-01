package flump.pixi;

import flump.library.Symbol;

/**
 * general interface for Sprite and Movie symbols from the Flump model
 */
interface ISymbol {
	/** the library symbol descriptor */
	var symbol( default, null)				: Symbol;
}