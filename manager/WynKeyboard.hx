package wyn.manager;

import kha.input.Keyboard;
import kha.Key;

class WynKeyboard extends WynManager
{
	// Taken from:
	// https://github.com/RafaelOliveira/LD34

	static var keysDown:Map<String, Bool>;
	static var keysHeld:Map<String, Bool>;
	static var keysUp:Map<String, Bool>;
	static var keysCount:Int = 0;
	static var keysJustPressed:Bool = false;

	public function new ()
	{
		super();

		Keyboard.get().notify(onKeyDown, onKeyUp);

		keysDown = new Map<String, Bool>();
		keysHeld = new Map<String, Bool>();
		keysUp = new Map<String, Bool>();
	}

	override public function update ()
	{
		for (key in keysDown.keys())
			keysDown.remove(key);

		for (key in keysUp.keys())
			keysUp.remove(key);

		keysJustPressed = false;
	}

	override public function reset ()
	{
		super.reset();

		for (key in keysDown.keys())
			keysDown.remove(key);

		for (key in keysHeld.keys())
			keysHeld.remove(key);

		for (key in keysUp.keys())
			keysUp.remove(key);
	}



	function onKeyDown (key:Key, char:String)
	{
		// trace("down : " + key + " , " + char);

		if (key == Key.CHAR)
		{
			keysDown.set(char, true);
			keysHeld.set(char, true);
		}
		else
		{
			keysDown.set(key.getName().toLowerCase(), true);
			keysHeld.set(key.getName().toLowerCase(), true);
		}

		keysCount++;

		keysJustPressed = true;
	}

	function onKeyUp (key:Key, char:String)
	{
		// trace("up : " + key + " , " + char);

		if (key == Key.CHAR)
		{
			keysUp.set(char, true);
			keysHeld.set(char, false);
		}
		else
		{
			keysUp.set(key.getName().toLowerCase(), true);
			keysHeld.set(key.getName().toLowerCase(), false);
		}

		keysCount--;
	}

	inline public static function isDown (key:String) : Bool
	{
		return keysDown.exists(key);
	}

	inline public static function isHeld (key:String) : Bool
	{
		return keysHeld.get(key);
	}

	inline public static function isUp (key:String) : Bool
	{
		return keysUp.exists(key);
	}

	inline public static function isAny () : Bool
	{
		return (keysCount > 0);
	}

	inline public static function isAnyDown () : Bool
	{
		return keysJustPressed;
	}
}