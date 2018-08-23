# Cave-Like levels generation with cellular Automata

A roguelike prototype inspired by readings on  procedural generation of terrain and auto-tiling.

made with [love2d](https://love2d.org/) <small>_(with love)_</small> 

source: [Lawrence Johnson / Julian Togelius / Georgios N. Yannakakis](http://julian.togelius.com/Johnson2010Cellular.pdf)

source: [rogueBassin](http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels)

source: [dev tuts auto-tile](https://gamedevelopment.tutsplus.com/tutorials/how-to-use-tile-bitmasking-to-auto-tile-your-level-layouts--cms-25673)

![fullMap zoom-out](https://github.com/r-sede/lovePacMan/raw/master/assets/img/readMe/mapScreen.jpg ':v')

![Yeah bomb](https://github.com/r-sede/lovePacMan/raw/master/assets/img/readMe/animGif.gif ' bomb !!')

### TODO:

- [ ] fix some tiles
- [x] drop bomb !!
- [ ] detect start in small closed room :/
- [ ] add other entities
- [ ] add Fx/Music
- [ ] bomb must destroy torchs + deco ..
- [ ] create stats n inventory for our old Men
- [x] lerp Camera except on edges
- [ ] add menu to title screen (play/scores)
- [x] add explosion effects (shake, smoket etc .)
- [ ] find a better way to handle, map layers, obstacles etc...
- [ ] better looking Fog of war 
- [ ] better collisions ? :/

---

## control:

**arrow key:** move hero

**esc:** quit game

**b:** drop bomb !!

**d:** toggle debug info

**t:** toggle tiles id

**t:** toggle fog of war (effect on next reset)

**s:** gen a new Seed

**r:** reset the dungeon (reset a Seed before to gen a new Dungeon )

---

## windows:

unzip build/loveCellular.zip

run loveCellular.exe

## linux:

install love2d package for your distrib

_ex deb package:_

```
$ sudo add-apt-repository ppa:bartbes/love-stable
$ sudo apt-get update
```

```
$ git clone https://github.com/r-sede/loveCellular.git
$ cd loveCellular
$ love .
```

show output in console + additional debug info on screen:

```
$ love . -debug
```
