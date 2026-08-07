# Contributing to Castle Kingdoms 2027

Hvala, da želite prispevati k Castle Kingdoms 2027! Tukaj je vodič za razvijalce.

## 🚀 Hitri začetek

### Zahteve
- [LÖVE 11.5](https://love2d.org) — igralni engine
- [Git LFS](https://git-lfs.com) — za prenos binarnih assetov
- Lua 5.1 / LuaJIT — programski jezik
- [Git](https://git-scm.com) — verzioniranje

### Namestitev

```bash
# 1. Kloniraj repozitorij
git clone https://github.com/markec12345678/castlekingdoms2027.git
cd castlekingdoms2027

# 2. Namesti Git LFS
git lfs install

# 3. Prenesi assete
git lfs pull

# 4. Zaženi igro
love .
```

## 📝 Konvencije

### Commit Messages
Uporabljaj [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Tipi:**
- `feat` — nova funkcija
- `fix` — popravljena napaka
- `docs` — dokumentacija
- `style` — formatiranje
- `refactor` — refaktoriranje
- `test` — testi
- `chore` — gradnja, orodja

**Primeri:**
```
feat(multiplayer): add TCP/IP networking with lobby
fix(render): SetScale needs both X and Y arguments
docs(readme): update installation instructions
```

### Lua Style Guide
- Zamik: 4 presledki (ne tabi)
- Imena funkcij: `camelCase`
- Imena razredov: `PascalCase`
- Konstante: `UPPER_SNAKE_CASE`
- Datoteke: `snake_case.lua`

### Struktura kode
```
objects/           # Game objects & systems
  Category/        # AI, Audio, Combat, Config, itd.
    SystemName.lua # Eno skrbništvo na datoteko
states/            # Game states
  ui/              # UI komponente
    category/      # multiplayer, settings, itd.
shaders/           # GLSL shaderji
locale/            # YAML prevodi
mods/              # Mod direktorij
```

## 🧪 Testiranje

### Pred pošiljanjem PR-ja

1. **Preveri sintakso**: `luac -p your_file.lua`
2. **Zaženi mission tests**: F10 v igri
3. **Preveri release checklist**: Ctrl+L v igri
4. **Testiraj na .love datoteki**: build + run

### Debug Console
Pritisni **Tilde (~)** v igri za debug console:
```
help          — seznam ukazov
perf          — FPS, memory, quality
stats         — igrače statistike
mods          — naloženi modi
gc            — garbage collection
```

## 🎨 Ustvarjanje vsebine

### Nova misija
1. Ustvari `saves/Missions/campaign/missionN_name.lua`
2. Definiraj: name, description, objectives, winCondition, loseCondition
3. Testiraj s F10

### Nov jezik
1. Kopiraj `locale/eng.yaml` → `locale/xxx.yaml`
2. Prevedi vse vrednosti
3. Dodaj v `LocalizationSystem.SUPPORTED_LANGUAGES`

### Nov mod
1. Ustvari `mods/my_mod/manifest.lua`
2. Ustvari `mods/my_mod/init.lua` (entry point)
3. Opcijsko: `buildings/`, `units/`, `maps/`, `scripts/`
4. Glej `mods/sample_mod/` za primer

### Nov building
```lua
return {
    name = "CustomWorkshop",
    displayName = "Custom Workshop",
    description = "Produces goods",
    cost = { wood = 50, stone = 20 },
    buildTime = 25,
    size = { w = 2, h = 2 },
    category = "industry",
    workers = 3,
    tier = 1,
    production = {
        input = { wood = 5 },
        output = { gold = 10 },
        rate = 5.0,
    },
}
```

## 🐛 Prijavljanje napak

### Uporabi Community Feedback System
V igri pošlji bug report prek debug konzole ali:
1. Pritisni **Tilde (~)**
2. Vtipkaj: `bug_report "Naslov" "Opis" "Koraki"`

### Ali na GitHubu
1. Preveri, če napaka že obstaja v [Issues](https://github.com/markec12345678/castlekingdoms2027/issues)
2. Ustvari nov Issue z:
   - Naslovom
   - Opisom
   - Koraki za reproduciranje
   - Verzijo igre (F11 za informacije)
   - Screenshot/video (če relevantno)

## 🔄 Pull Request proces

1. **Fork** repozitorij
2. Ustvari **branch**: `git checkout -b feature/your-feature`
3. **Commit** spremembe: `git commit -m 'feat(scope): description'`
4. **Push** na fork: `git push origin feature/your-feature`
5. Ustvari **Pull Request** na `main` branch

### Kaj preveriti pred PR-jem
- [ ] Koda sledi style guide
- [ ] Lua sintaksa je pravilna
- [ ] Mission tests pass (F10)
- [ ] Release checklist pass (Ctrl+L)
- [ ] Ni novih crash-ov
- [ ] Dokumentacija posodobljena

## 📦 Build

### .love datoteka
```bash
zip -r castlekingdoms2027.love . -x ".git/*" "*.md"
```

### Release
1. Posodobi `CHANGELOG.md`
2. Posodobi verzijo v `README.md`
3. Commit + tag: `git tag -a v1.x.0 -m "Release v1.x.0"`
4. Push tag: `git push origin v1.x.0`
5. Ustvari GitHub Release z .love datoteko

## ❓ Vprašanja

- [GitHub Issues](https://github.com/markec12345678/castlekingdoms2027/issues)
- [GitHub Discussions](https://github.com/markec12345678/castlekingdoms2027/discussions)

---

Hvala za vaše prispevke! 🎮
