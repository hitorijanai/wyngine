# Wyngine
Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them. The code base is influenced by HaxePunk and HaxeFlixel, because I'm still learning. Ultimately I hope it'll evolve into a usable game engine alternative for Kha.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

The API may change drastically as I learn new techs and apply them into the overall structure of the engine. Please use at your own risk! When the engine is ready, you will see a "Getting Started" section below. If not, please be patient :)

# Wyngine 0.3 (update: 27 December 2015)

Overhauled framework completely, straying from Flixel-based structure. Wyngine is now component-based, similar to Unity. Existing classes are converted to components which can be added or removed from base WynObjects. This allows for WynObjects to be lightweight and customisable -- without any redundant properties like physics, sprites or hitboxes if the game doesn't require any.

# Wyngine 0.2 (update: 14 December 2015)

Due to Kha's submodule reliance, legacy Wyngine no longer works with Kha unless you know which commit to revert to for both Kha and its submodules.
As a result, Wyngine is now updated to work with latest Kha (git) version.

# Roadmap

https://trello.com/b/LAOdvBzt/wyngine

# Wyngine 0.1

Legacy Wyngine, based on previous version of Kha. Code is no longer usable, but the following demos have been made with legacy Wyngine/Kha:

* [KhaPong](http://coinflipstudios.com/khapong)
* [Khasteroids](http://coinflipstudios.com/khasteroids)
* [KhaQuadTree](http://coinflipstudios.com/khaquadtree)
* [KhaMenu](http://coinflipstudios.com/khamenu)
* [KhaCamera (multiple cameras, scroll)](http://coinflipstudios.com/khacamera)
* [KhaCamera (flash, fill, fadeIn, fadeOut)](http://coinflipstudios.com/khacamera2)
* [KhaButton (image, 9-slice image, button, 9-slice button)](http://coinflipstudios.com/khabutton)
* [Pollen (game)](http://coinflipstudios.com/pollen)

# Current Available Features

* Sprite animation
* Input
	* Keyboard
	* Mouse
	* Touch (untested)
* Audio
	* Play BGM
	* Play sound
* Simple collision check
* Object Pooling
* Quad-tree collisions
* Screen states
* Text
	* Default Kha text
	* Bitmap text
* Camera system (multiple cameras, scrolling, zooming, shake, flash, fade, fill)
* 9-slice image
* Buttons, 9-slice buttons
* Tweening (with [David King's refactored code](https://github.com/oodavid/timestep/blob/master/src/animate/transitions.js) based on [Andrey Sitnik's easings.net](http://easings.net/))
* Particle system (for explosions & smoke effects)
* Subscreens (similar to Flixel's SubStates)
