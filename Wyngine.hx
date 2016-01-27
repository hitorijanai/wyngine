package wyn;

import kha.Assets;
import kha.System;
import kha.ScreenRotation;
import kha.Image;
import kha.Scheduler;
import kha.Framebuffer;
import kha.Scaler;
import kha.graphics2.Graphics;
import kha.graphics2.ImageScaleQuality;
import wyn.manager.WynManager;

class Wyngine
{
	var backbuffer:Image;
	var g:Graphics;

	static var active:Bool = true;
	static var visible:Bool = true;

	public static var imageQuality:ImageScaleQuality = ImageScaleQuality.High;
	public static var onResize:Void->Void;
	public static var gameWidth(default, null):Int = 0;
	public static var gameHeight(default, null):Int = 0;
	public static var screenOffsetX(default, null):Int = 0;
	public static var screenOffsetY(default, null):Int = 0;
	public static var gameScale(default, null):Float = 1; // this value will adjust according to khanvas dimensions
	public static var dt(default, null):Float = 0;
	public static var bgColor:Int = 0xff6495ed; // cornflower
	public static var frameBgColor:Int = 0xFFFFFFFF;

	static var currTime:Float = 0;
	static var prevTime:Float = 0;
	static var screens:Array<WynScreen> = [];
	static var screensToAdd:Array<WynScreen> = [];
	static var managers:Array<WynManager> = [];
	static var currScreen:WynScreen;
	static var screensLen:Int = 0;



	public function new (width:Int, height:Int)
	{
		backbuffer = Image.createRenderTarget(width, height);
		g = backbuffer.g2;

		gameWidth = width;
		gameHeight = height;
		currTime = Scheduler.time();

		#if js

			setupHtml();

		#else if sys_android_native

			setupAndroid();

		#end

		// Delay update game scale once upon startup to make sure
		Scheduler.addTimeTask(function () {
			refreshGameScale();
		}, 1);

		// Requires the rotate icon
		Assets.images.icon_horizontalLoad(function () {});
	}

	function setupHtml ()
	{
		#if js

			// Prevents mobile touches from scrolling/scaling the screen.
			js.Browser.window.addEventListener("touchstart", function (e:js.html.Event) {
				e.preventDefault();
			});

			// Make sure that the canvas is refreshed on browser resize, to prevent
			// the mouse/touch positions from desyncing.
			js.Browser.window.addEventListener("resize", function () {
				
				// NOTE: we need to delay the method call here because we can't get
				// the updated width/height values immediately.

				Scheduler.addTimeTask(function () {

					refreshGameScale();
					if (onResize != null)
						onResize();

				}, 0.1);
			});

			var wyn = 'background:#ff69b4;color:#ffffff';
			var black = 'background:#ffffff;color:#000000';
			var kha = 'background:#2073d0;color:#fdff00';
			js.Browser.console.log('%cMade with %c wyngine %c\nPowered by %c kha ', black, wyn, black, kha);

		#end
	}

	function setupAndroid ()
	{
		// TODO
	}

	static public function refreshGameScale ()
	{
		// always reset before rescaling
		screenOffsetX = 0;
		screenOffsetY = 0;

		var khanvasW = System.pixelWidth;
		var khanvasH = System.pixelHeight;
		// var ratioW = gameWidth / khanvasW;
		// var ratioH = gameHeight / khanvasH;
		// var ratio = Math.min(ratioW, ratioH);
		// gameScale = ratio;

		var screenRatioW = khanvasW / gameWidth;
		var screenRatioH = khanvasH / gameHeight;
		gameScale = Math.min(screenRatioW, screenRatioH);
		var w = gameWidth * gameScale;
		var h = gameHeight * gameScale;

		if (screenRatioW > screenRatioH)
		{
			screenOffsetX = Math.floor((khanvasW/gameScale - gameWidth)/2);
			// gameOffsetX = Math.floor((khanvasW - w) / 2 / zoom);
		}
		else
		{
			screenOffsetY = Math.floor((khanvasH/gameScale - gameHeight)/2);
			// gameOffsetY = Math.floor((khanvasH - h) / 2 / zoom);
		}

		// trace("refresh game scale : " + khanvasW + "," + khanvasH + " / " + gameWidth + "," + gameHeight + " / " + screenOffsetX + "," + screenOffsetY + " / " + gameScale);

		// trace("khanvas : " + khanvasW + "," + khanvasH);
		// trace("game    : " + gameWidth + "," + gameHeight);
		// trace("ratio : " + screenRatioW + " , " + screenRatioH);
		// trace("w/h :   " + w + " , " + h);
		// trace("offset  : " + screenOffsetX + " , " + screenOffsetY);
		// trace("final scale : " + " , " + gameScale);
	}

	public function update ()
	{
		// Make sure prev/curr time is updated to prevent time skips
		prevTime = currTime;
		currTime = Scheduler.time();

		if (!active)
			return;

		// Update delta time if we didn't return
		dt = currTime - prevTime;

		// Add and init any screens that were previously added
		while (screensToAdd.length > 0)
		{
			var nextScreen = screensToAdd.shift();
			nextScreen.open();
			screens.push(nextScreen);
		}

		// Update scene object and their components
		// render from back to front (index 0 to last)
		var i = 0;
		while (i < screens.length)
		{
			currScreen = screens[i];

			// remove screens that are inactive
			if (!currScreen.alive)
			{
				screens.remove(currScreen);
				i--;
			}
			else
			{
				if (i < screensLen-1)
				{
					if (currScreen.persistentUpdate)
						currScreen.update();
				}
				else
				{
					currScreen.update();
				}
			}

			i++;
		}

		// Events will always trigger first, and we want screens
		// to react to the changes before the manager processes them.
		for (m in managers)
		{
			if (m.active)
				m.update();
		}
	}

	public function render (framebuffer:Framebuffer)
	{
		if (!visible)
			return;

		g.begin(true, bgColor); // cornflower

		g.imageScaleQuality = imageQuality;

		// render from back to front (index 0 to last)
		screensLen = screens.length;
		for (i in 0 ... screensLen)
		{
			currScreen = screens[i];

			if (i < screensLen-1)
			{
				if (currScreen.persistentRender)
					currScreen.render(g);
			}
			else
			{
				currScreen.render(g);
			}
		}

		g.end();

		framebuffer.g2.begin(true, frameBgColor);
		framebuffer.g2.imageScaleQuality = imageQuality;
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	static public function addScreen (screen:WynScreen)
	{
		if (screens.indexOf(screen) == -1)
		{
			// add to list to immediately update/render the screen
			screensToAdd.push(screen);
		}
	}

	static public function removeScreen (screen:WynScreen)
	{
		if (screens.indexOf(screen) != -1)
		{
			// begin closing
			screen.close();
		}
	}

	static public function addManager (manager:WynManager)
	{
		managers.push(manager);
	}
}