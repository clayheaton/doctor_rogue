##### CHANGELOG - Add changes to the top.

* 20 May 2013 - Clay - Killed two birds with one stone by replacing the dirt-to-brick tiles with tiles that show a hole in the dirt (or can be used to create a rift). They are placeholder, but provide us with the opportunity to create chasms, like in Brogue, that the player can jump into. I also restructured several things around MapLayer and MainGameScene to prepare GameWorld for creating an in-memory representation of the various things ongoing on the map.

* 19 May 2013 - Clay - This build is the first to include the build number on the main menu screen. While it doesn't look like much else was done, I refactored some of the code for touch detection in the MapLayer to make certain that we were properly translating screen touches to map locations. We weren't. Now we are. To see the effects of this, double tap on any tile and an ugly white circle will appear there, indicating that you "selected" it. You then can scroll and zoom with the same tile selected. If you double-tap a different tile, it will become selected. If you double-tap a selected tile, the ugly white circle will disappear.

* 18 May 2013 - Clay - Added fog of war tiles and examples of how they look onto the test maps.

* 16 May 2013 - Clay - Created and added two grasslands test maps; one retina and one standard display. This revealed a number of bugs in the implementation of CCPanZoomController. These were addressed by performing a retina check in `MapLayer` and allowing for specific balancing of zooming and scrolling dampening values in `Constants.h`. Also added but did nothing with the `RandomMapGenerator` class.

* 16 May 2013 - Clay - Added two layers to the test map and added some placeholder graphics for our main Character. Also added the GameObject and GameObjectSprite classes, which will be the superclasses from which our other classes of game objects and items are derived. Note that, when adding layers to a .tmx map, you must add at least one tile to each layer or there is an assertion when the map is loaded. Need to add a few tiles to the default tileset that can be used for marking things on these layers -- collisions, etc. They can be bright pink or something. 

