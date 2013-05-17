##### CHANGELOG - Add changes to the top.

* 16 May 2012 - Clay - Created and added two grasslands test maps; one retina and one standard display. This revealed a number of bugs in the implementation of CCPanZoomController. These were addressed by performing a retina check in `MapLayer` and allowing for specific balancing of zooming and scrolling dampening values in `Constants.h`. Also added but did nothing with the `RandomMapGenerator` class.

* 16 May 2013 - Clay - Added two layers to the test map and added some placeholder graphics for our main Character. Also added the GameObject and GameObjectSprite classes, which will be the superclasses from which our other classes of game objects and items are derived. Note that, when adding layers to a .tmx map, you must add at least one tile to each layer or there is an assertion when the map is loaded. Need to add a few tiles to the default tileset that can be used for marking things on these layers -- collisions, etc. They can be bright pink or something. 

