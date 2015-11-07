package wyn;

import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Rectangle;
import kha.graphics2.Graphics;

class WynButton extends WynSprite
{
	/**
	 * - Buttons have separate images for up/hover/down states.
	 * - If the button is 9-slices, it will re-draw the slice every time
	 * the width or height changes.
	 * - By logic, a 9-slice image cannot be animated because it consists
	 * of 9 parts within a spritesheet.
	 * - As such, buttons can't be animated.
	 *
	 * To use WynButton:
	 * - instance it normally like a WynSprite
	 * - load the image and provide the down/hover/up state's SliceData
	 * - (optional) set the hitbox offset.
	 */

	// Button states as int
	public static inline var UP:Int = 1;
	public static inline var HOVER:Int = 2;
	public static inline var DOWN:Int = 3;

	// These store a cached image for the 9-sliced button.
	// This way we don't have to slice it every update.
	var imageUp:Image;
	var imageHover:Image;
	var imageDown:Image;

	// Store the slice data so we can reslice it when width or height changes
	var upData:WynSprite.SliceData;
	var hoverData:WynSprite.SliceData;
	var downData:WynSprite.SliceData;

	var _buttonState:Int;



	public function new (x:Float=0, y:Float=0, w:Float=0, h:Float=0)
	{
		super(x, y, w, h);
	}

	override public function update (dt:Float)
	{
		super.update(dt);

		// Reset state every update. When iterating through multiple
		// cameras, the mouse may be "inside" a button in one camera, but
		// "outside" the button in other cameras. As such, prioritise:
		// DOWN > HOVER > UP
		setButtonState(WynButton.UP);

		for (cam in Wyngine.G.cameras)
		{
			// Completely break the loop
			if (_buttonState == WynButton.DOWN)
				break;

			var mouseX = (WynMouse.windowX / Wyngine.G.zoom / cam.zoom) - (cam.x - cam.scrollX) / cam.zoom;
			var mouseY = (WynMouse.windowY / Wyngine.G.zoom / cam.zoom) - (cam.y - cam.scrollY) / cam.zoom;

			// If the mouse is in or outside
			var hitHoriz = false;
			var hitVert = false;
			if (mouseX > x) hitHoriz = mouseX < x + width;
			if (mouseY > y) hitVert = mouseY < y + height;
			if (hitHoriz && hitVert)
			{
				if (WynMouse.isMouse(0))
					setButtonState(WynButton.DOWN);
				else
					setButtonState(WynButton.HOVER);
			}
		}
	}

	override public function render (c:WynCamera)
	{
		super.render(c);
	}

	/**
	 * Load image via kha's internal image loader. Make
	 * sure you loaded the room that contains this image,
	 * in project.kha.
	 */
	public function loadButtonImage (name:String, frameW:Int, frameH:Int, ?up:WynSprite.SliceData, ?hover:WynSprite.SliceData, ?down:WynSprite.SliceData)
	{
		_spriteType = WynSprite.BUTTON;

		// Image name is set from project.kha
		image = Loader.the.getImage(name);

		// Set default variables in case there is no button data
		frameWidth = frameW;
		frameHeight = frameH;

		upData = up;
		hoverData = hover;
		downData = down;

		setButtonState(WynButton.UP);
	}

	public function load9SliceButtonImage (name:String, downData:WynSprite.SliceData, hoverData:WynSprite.SliceData, upData:WynSprite.SliceData)
	{
		// if (downData != null)
		// {
		// 	this.downData = downData;
		// 	drawSlice(imageUp, downData);
		// }

		// if (hoverData != null)
		// {
		// 	this.hoverData = hoverData;
		// 	drawSlice(imageUp, hoverData);
		// }

		// if (upData != null)
		// {
		// 	this.upData = upData;
		// 	drawSlice(imageUp, upData);
		// }
	}

	function setButtonState (state:Int)
	{
		if (_buttonState == state)
			return;

		_buttonState = state;

		if (state == WynButton.UP && upData != null)
		{
			frameX = upData.x;
			frameY = upData.y;
			frameWidth = upData.width;
			frameHeight = upData.height;
		}
		else if (state == WynButton.HOVER && hoverData != null)
		{
			frameX = hoverData.x;
			frameY = hoverData.y;
			frameWidth = hoverData.width;
			frameHeight = hoverData.height;
		}
		else if (state == WynButton.DOWN && downData != null)
		{
			frameX = downData.x;
			frameY = downData.y;
			frameWidth = downData.width;
			frameHeight = downData.height;
		}
	}
}