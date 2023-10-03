# Godspeed

![A schoolbus on fire, flying towards the screen](source/assets/images/meta/card.png "Godspeed")

**One schoolbus, one ticking bomb, only one way to- forward. Godspeed.**

**Godspeed** is a simple game for Playdate, inspired by the movie [Speed](https://www.imdb.com/title/tt0111257/?ref_=fn_al_tt_1). You play as a bus, speding down a highway full of obstacles, and if you slow down, or crash too much, the bomb explodes.

## Requirements

* [Playdate SDK](https://play.date/dev/)
  
## Running

* [Set PLAYDATE_SDK_PATH Environment Variable](https://sdk.play.date/2.0.1/Inside%20Playdate.html#_set_playdate_sdk_path_environment_variable)
* Run:

  ```bash
  pdc source/ out/godspeed.pdx
  ```

* Then either play in the [Simulator](https://sdk.play.date/2.0.1/Inside%20Playdate.html#_running_your_game), or in your [Playdate by sideloading](https://help.play.date/games/sideloading/).

## How to Play

Every obstacle you hit, you slow down. If you don't mash A hard enough, you slow down. If you slow down too much, or hit obstacles thrice, you explode! How far can you go?

* <kbd>↑</kbd> to move up one lane
* <kbd>↓</kbd> to move down one lane
* Mash <kbd>A</kbd> to speed up
* Press <kbd>B</kbd> to restart the game after exploding

## Third Party Libraries & Assets Used

* [AnimatedSprite](https://github.com/Whitebrim/AnimatedSprite) by [Whitebrim](https://github.com/Whitebrim) (MIT)
* [Car engine sound effect](https://freesound.org/people/MarlonHJ/sounds/242740/) by MarlonHJ (CC0)
* [Crash crash sound effect](https://freesound.org/people/Eponn/sounds/420356/) by Eponn (CC0)
* [Explosion sound effect](https://freesound.org/people/tommccann/sounds/235968/) by tommccann (CC0)
* [Bomb beep sound effect](https://freesound.org/people/snakebarney/sounds/138108/) by snakebarney (CC0)

## Licenses

* All the code, that is, everything under the `source/` folder, except `source/lib` and `source/assets/`, is licensed under the [MIT License](LICENSE).
* All the assets and asset data files, that is, everything under the `source/assets/` and `support/` folders, except `source/assets/fonts`, are licensed under [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).
