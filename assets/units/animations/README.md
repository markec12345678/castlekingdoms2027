Unit Animation Frames

Directory structure: assets/units/animations/<UnitName>/<state>_<frame>.png

States: idle, walk, attack, death, hit, retreat
Frames: state_01.png, state_02.png, ... (max 20 per state)

Example:
  assets/units/animations/Archer/idle_01.png
  assets/units/animations/Archer/idle_02.png
  assets/units/animations/Archer/walk_01.png
  assets/units/animations/Archer/attack_01.png
  assets/units/animations/Archer/death_01.png

If no animation files exist, system falls back to static HD unit sprite.
Default FPS: 10 (configurable per unit).

Framework: objects/Animation/UnitAnimationSystem.lua (v3.13.6)
