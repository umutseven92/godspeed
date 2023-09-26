
# Godspeed

![A schoolbus on fire, flying towards the screen](source/assets/images/meta/card.png "Godspeed")

**One schoolbus, one ticking bomb, only one way to- forward. Godspeed.**

**Godspeed** is a simple game for Playdate, inspired by the movie [Speed](https://www.imdb.com/title/tt0111257/?ref_=fn_al_tt_1). You play as a bus, speding down a highway full of obstacles, and you cannot afford to slow down.

## Requirements

* [Playdate SDK](https://play.date/dev/)
  
## Running

* [Set PLAYDATE_SDK_PATH Environment Variable](https://sdk.play.date/2.0.1/Inside%20Playdate.html#_set_playdate_sdk_path_environment_variable)
* Run:

  ```bash
  pdc source/ out/godspeed.pdx
  ```

* Then either play in the [Simulator](https://sdk.play.date/2.0.1/Inside%20Playdate.html#_running_your_game), or in your [Playdate](https://sdk.play.date/2.0.1/Inside%20Playdate.html#_running_your_game_on_playdate_hardware).

## How to Play

Dodge obstacles while making sure not to slow down. Every obstacle you hit, you slow down. If you don't mash A or B hard enough, you slow down. If you slow down too much, you explode! How far can you go?

* <kbd>↑</kbd> to move up one lane
* <kbd>↓</kbd> to move down one lane
* Mas <kbd>A</kbd> or <kbd>B</kbd> to speed up

## Third Party Libraries & Assets Used

* [AnimatedSprite](https://github.com/Whitebrim/AnimatedSprite) by [Whitebrim](https://github.com/Whitebrim)
* Asheville Sans font

## Licenses

* All the code, that is, everything under the `source/` folder, except `source/lib` and `source/assets/`, is licensed under the [MIT License](LICENSE).
* All the assets and asset data files, that is, everything under the `source/assets/` and `support/` folders, except `source/assets/fonts`, are licensed under [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/).

## Todo

### Code

* Testing and polishing, especially slowing down
* Difficulty curve as time goes on
* LERP speed & scrolling
* Quick intro ("START MASHING")
* Localisation
* Music & sound effects

### Assets

#### Sounds

* Car whirring
* Lane change (tire screech)
* Car crash
* Bomb beeping
* Explosion
* Game over jingle