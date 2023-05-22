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
