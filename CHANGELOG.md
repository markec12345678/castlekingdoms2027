# 0.7.0-stronghold2027-alpha (2026-08-01)

Prvi alpha release Stronghold 2027 - forka Stone Kingdoms z dodatnimi izboljšavami.

### Features

- **Slovenski prevod (slv.yaml)**: Popoln prevod vseh 472 vrstic besedila (5 misij, 63 zgradb, 12 mesecev, UI, nastavitve)
- **Modding API (alpha)**: Osnovni sistem za uporabniške mode z lifecycle hook-i (onLoad, onTick, onBuildingPlaced, onUnitRecruited)
- **HD Shaderji**: Moderni post-processing shaderji (bloom, color grading, vignette, dynamic lighting) za izboljšano vizualno izkušnjo
- **Performance Profiler**: Debug overlay s FPS, memory usage, custom counters (F3 za toggle, F4 za detailed mode)
- **CI/CD Pipeline**: GitHub Actions z luacheck, YAML validacijo, custom test runnerjem in build pipeline
- **Comprehensive Test Suite**: 343 preverjanj - sintaksa, YAML, dokumentacija, arhitektura

### Documentation

- **README.md**: Posodobljen z informacijami o forku in roadmapom
- **FORK_NOTICE.md**: Dokumentacija odnosa do upstream Stone Kingdoms
- **CONTRIBUTING.md**: Navodila za sodelovanje z Conventional Commits
- **ROADMAP.md**: Razvojni načrt do 2027-09-01
- **BUGFIX_STRATEGY.md**: Strategija popravkov v 4 fazah
- **HD_ASSETS_GUIDE.md**: Specifikacije za grafične oblikovalce (4K tileset, UI, animacije)
- **MODDING_API.md**: Dokumentacija modding API za ustvarjalce modov

### Branches

- `main` - Stabilna produkcija
- `dev` - Integracijska veja
- `feat/bugfixes` - Popravki bug-ov
- `feat/hd-assets` - HD grafični asseti
- `feat/slovenian-polish` - Izboljšave slovenskega prevoda

### GitHub Templates

- Issue template za bug report
- Issue template za feature request
- Pull request template s checklist

### Infrastructure

- Git LFS konfiguriran za vse binarne datoteke (PNG, DDS, MP3, DEB, DXT5, BIN)
- 1151 LFS objektov (1.8 GB) sinhronizirano z GitHubom
- 4 nove razvojne veje ustvarjene
- Slovenščina registrirana kot 10. podprti jezik

### Stats

- 280 Lua datotek v projektu (213,215 vrstic kode)
- 71 struktur (zgradbe)
- 42 enot
- 15+ krmilnikov (Controllers)
- 33 jezikovnih datotek v locale/
- 343 test preverjanj - 100% pass rate

### Known Issues

- Xvfb (virtual display) ne podpira GLX v strežniškem okolju - dejansko grafično testiranje zahteva lokalni računalnik
- GitHub LFS storage trenutno porabljen 1.8 GB (free plan = 1 GB) - priporočen nakup GitHub Pro ($4/mesec)
- Apothecary, Stable, Maypole so še vedno nefunkcionalni (enako kot upstream v0.6.1)
- Combat sistem še ni implementiran (enake kot upstream v0.6.1)

### Credits

- Original Stone Kingdoms team - celotna koda, arhitektura in asseti
- Firefly Studios - dovoljenje za uporabo originalnih Stronghold assetov
- Stronghold 2027 ekipa - slovenski prevod, CI/CD, modding API, HD shaderji, dokumentacija

### Breaking Changes

- Branch renamed: `master` → `main`
- `*.dds` files migrated to Git LFS in history (to bypass GitHub 100MB limit)
- README.md replaced with fork-specific documentation

---

# 0.6.1

### Misc

- Added the innkeeper (partially implemented).
- Added the Grasslands map which loads an empty 128x128 map for testing purposes.
- Menu buttons are now sized to the localized caption if necessary

### Bug Fixes

- Pressing exit or loading a game no longer freezes for 1 second.
- Fixed crash when centering on granary or keep before they were placed
- Fixed crash with OxHandler
- Fixed crash when worker leaves their workplace while working
- Fixed crash with pathfinding when workers couldn't find a path back to the stockpile
- Fixed crash with Miller boys
- Fixed the ability for workers to leave/sleep the windmill
- Fixed crash when upgrading castle placed near edge of map
- Fixed peasants getting stuck at campfire
- Fixed various rendering bugs with defensive structures

# 0.6.0

### New Buildings

- **Wooden Perimeter Tower**: A small wooden defensive tower.
- **Wooden Defensive Tower**: A large wooden defensive tower.
- **Wooden Big Gate**: A bigger kind of wooden gate.
- **Pich Rig**: Small platform to collect pitch from the swamp.
- **Apothecary**: It creates a healer that wanders around. Temporarely not functional.
- **Stable**: It produces horses. Temporarely not functional.

### Gameplay

- Added military units (they can only be moved around for now, there's no combat yet).
- Switched popularity system to be more similar to Stronghold.
- Buildings will now be unlocked by upgrading the keep.
- Added ability to upgrade houses to increase the population.
- Added priest worker for the chapel (he blesses buildings, but there's no popularity bonus yet).
- Workers now leave their job when they're unhappy.
- Added sleep feature to buildings.

### Misc

- Added new tree types: birch and chestnut.
- Added [translations framework](https://crowdin.com/project/stone-kingdoms). Currently supported languages are German, Italian, Polish, Portuguese (BR) and Ukrainian. Contributions are welcome!
- Changes some fonts to improves language support.
- Extended soundtrack (check below for credits).
- Added drunkard. They will wander around the inn and houses.
- Added automatic crash reporting via Sentry.
- Made woodcutter's tree finding algorithm smarter.
- Added master volume slider in the settings.
- Added a new main menu soundtrack.
- Major overhaul of the graphics settings.
- Added language picker to the menu.

### Bug Fixes

- Fixed workers not able to enter buildings when they're built next to other buildings.
- Fixed an issue where you couldn't trade goods when you select them from the stockpile.
- Fixed crash when completing the last mission in the campaign.
- Fixed crash on load when having a Maypole.
- Fixed crash on load when having an Inn.
- Fixed Orchard farmer crash.
- Fixed Chicken related crash.
- Fixed not reloading prices at the market.
- Fixed woodcutters getting stuck in various situations.
- Fixed inaccurate gold counter when trading weapons.
- Fixed multiple woodcutters chopping the same tree.
- Fixed game music not stopping when return back to main menu.
- Fixed crash loading a game with a windmill.
- Fixed "cannot build" sounds not always playing.

### Credits

- Features additional art by Ho6org, Lord Steinhauer, Monsterfish and Zarentreuer Lenin.
- Extended soundtrack was made by Alexander Nakarada, Kevin MacLeod & Random Mind. See `/sounds/music` for full attribution & licensing info.
- Thanks to UCP team and Project Reconquista for technical support.

# 0.5.0

### New Buildings

- **Dairy Farm**: Produce cheese for food consumption.
- **Hops Farm**, **Brewery**, **Inn**: Grow hops, produce ale and distribute it, making people happy!
- **Armory**: A storage for your weapons.
- **Fletcher's Workshop**: Produce bows or crossbows.
- **Poleturner's Workshop**: Produce spears or pikes.
- **Blacksmith's Workshop**: Produce swords or maces.
- **Armorer's Workshop**: Produce shields.
- **Barracks**, **Stone Barracks**, **Engineer's Guild**, **Tunneler's Guild**: They are currently placeholders, but they will allow recruiting military units in the next updates.
- **Chapel**, **Church**, **Cathedral**: They are currently non-functional, but in future updates they will increase faith, which will increase happiness.
- **Apothecary**: Currently non-functional. It will gain utility in future updates.
- **Positive Buildings**: Gardens, ponds and maypole. Build them to increase population happiness.
- **Defensive Stone Structures**: Towers and gates made out of stone.

### Gameplay

- Added a new "Campaign" mode, where you can play missions with objectives.
- The previous free build mode is now a separate mode called "Freebuild".
- Added auto tax feature to castles. This will automatically apply tax on your population, based on the happiness level.
- Workers from destroyed builders will no longer disappear anymore and they will become unemployed again.
- Destroyed buildings will now refund half of the material cost.

### GUI

- Added map selection for the freebuild mode.
- Added campaign menu.
- Added option to select game resolution.
- Added GUI for the barracks.
- Added GUI for the armory.
- The material cost on building tooltips will change color based on if you have the required resources or not.

### Misc

- The game date is now displayed.
- Added the lord unit. It will wander around your castle.
- You can now press F12 to take a screenshot.
- The camera zoom is now smoother.
- Added tooltips to built buildings.
- Added current materials beside the cost to the building tooltips.
- Clicking on materials in the stockpile UI will now open the market UI with that material.
- Added right click shortcut to navigate back in UIs.
- Added soundeffects to the action bar.
- Save files are now ~10 times smaller.
- Added configurable keybindings. This is currently not exposed in the UI.

### Bug Fixes

- Buying materials from the market when the stockpile is full will no longer spend money.
- Fixed wheat farmer sometimes getting stuck.
- Fixed crash after trying to build outside of the map.
- The quarry workers will not get stuck anymore if the ox handler is unemployed.
- Fixed wrong shading of the stockpile on game load.
- Fixed not being able to select the Fortress (upgraded keep).
- Fixed several bugs about terraforming when placing buildings.
- Fixed being able to place the initial buildings when the game is paused.
- Fixed stone texture in the stockpile getting misaligned.
- Fixed crash on game start for ARM processors, like Apple's M1 and M2.
- Fixed not being able to fully destroy woodcutters in a loaded game.
- Disable building too close to the keep to not interfere with keep upgrades.
