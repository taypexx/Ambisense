# Ambisense

### Ambisense is a rhythm game with a deep story where you beat different levels by fighting your opponents to the music.

## Structure of the project:

assets - all assets related to the game
- /maps - every map(location) of the game. Contains folders that start with 3 digits and an underscore.
- /maps/map - map files: .tmx (Tiled project), .lua (Map data)
- /tilemaps - tilemaps(images) for the map building. Basically spritesheets of tiles.
- /music - game music
- /sfx - sound effects and other audio
- /sprites - all game sprites besides tilemaps
- /video - every video asset (mostly cutscenes)

engine - the engine developed specifically for the game. Contains abstract data types and other stuff.

src - source code of the game

## Structure outside of the game (app data)

- cache - cache and temporary files of the game
- logs - self explanatory
- save.dat - game progress
- settings.json - user settings and preferences

## Coding principles

### Engine
All abstract concepts should be kept in the engine section. 
Everything else will be built on top of that.

### Coordinates and game look
The main game view is plain 2D with some parallax elements for the 3D effect.
Coordinates start at top left corner.
Design-wise half of the game is pixelated.

### Objects and instantiation
Everything that can be instantiated must derive from Object (engine).
Apple - object, Player - object, Camera - not an object.
This is made for the garbage collection and optimization.