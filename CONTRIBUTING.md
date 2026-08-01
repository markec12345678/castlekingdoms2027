# Contributing to Stronghold 2027

Hvala, da želiš prispevati k Stronghold 2027! Ta dokument opisuje, kako lahko pomagaš.

## 🚀 Hitri začetek

```bash
# 1. Kloniraj repozitorij z LFS
git lfs install
git clone https://github.com/markec12345678/stronghold2027.git
cd stronghold2027

# 2. Namesti LÖVE 11.5+ (https://love2d.org/)
# Linux:  apt install love  ali  prenesi AppImage
# macOS:  brew install love
# Windows: prenesi iz love2d.org

# 3. Zaženi igro
love .

# 4. Ustvari feature vejo
git checkout -b feat/my-feature

# 5. Naredi spremembe, commit, push
git add .
git commit -m "feat(scope): opis spremembe"
git push origin feat/my-feature

# 6. Odpri Pull Request na GitHubu
```

## 🌿 Strategija vej

| Veja | Namen | Stabilnost |
|------|-------|-----------|
| `main` | Produkcija - releasi | Stabilna |
| `dev` | Integracijska veja | Testna |
| `feat/bugfixes` | Popravki bugov | Razvojna |
| `feat/hd-assets` | HD grafični asseti | Razvojna |
| `feat/slovenian-polish` | Izboljšave slovenskega prevoda | Razvojna |
| `feat/...` | Tvoja nova funkcija | Razvojna |

**Pravila:**
- Nikoli ne commitaj direktno v `main`
- Vedno ustvari feature vejo iz `dev`
- Po merge-u izbriši feature vejo
- Uporabi pull request za merge v `dev`

## 📝 Conventional Commits

Uporabljamo [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Tipi:
- `feat` - Nova funkcija
- `fix` - Popravek buga
- `docs` - Sprememba dokumentacije
- `style` - Formatiranje, brez spremembe kode
- `refactor` - Refaktoriranje kode
- `test` - Dodajanje testov
- `chore` - Vzdrževalna opravila

### Scope (primeri):
- `i18n` - Lokalizacija
- `ui` - Uporabniški vmesnik
- `gameplay` - Mehanike igre
- `assets` - Grafične/zvočne datoteke
- `build` - Build sistem, CI

### Primeri:
```
feat(i18n): dodaj slovenski prevod (slv.yaml)
fix(gameplay): popravi pathfinding skozi zgradbe
docs: posodobi README z navodili za namestitev
refactor(ui): preuredi market_trade.lua
```

## 🧪 Testiranje

### Pred oddajo PR-ja:

1. **Luacheck** - statična analiza
   ```bash
   luacheck . --config .luacheckrc
   ```

2. **YAML validacija** (za locale datoteke)
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('locale/slv.yaml'))"
   ```

3. **Ročno testiranje**
   - Zaženi igro: `love .`
   - Preveri tvoje spremembe v različnih scenarijih

### CI Pipeline
Vsak push in PR avtomatsko zažene:
- ✅ Luacheck (statīčna analiza)
- ✅ YAML validacija vseh locale datotek
- ✅ Build (.love paket)

## 🌍 Lokalizacija

### Dodajanje novega jezika:
1. Kopiraj `locale/source/strings.yaml` v `locale/<xxx>.yaml` (3-črkovni ISO koda)
2. Prevedi vsa besedila
3. Dodaj jezik v `objects/Enums/Languages.lua`
4. Registriraj v `objects/Controllers/LanguageController.lua`
5. Testiraj z zagonom igre

### Posodabljanje prevoda:
- Vedno preveri YAML sintakso
- Ohrani `\n` formatiranje kot v originalu
- Ne spreminjaj strukture (ključi morajo ostati enaki)

## 🎨 Grafični asseti

### Za nove assete:
- Format: PNG (lossless)
- Ločljivost: 4K za HD, 2K za standard
- Imenovanje: `snake_case.png`
- Lokacija: `assets/<kategorija>/<ime>.png`

### Za zamenjavo obstoječih:
- Ohrani enako ime datoteke
- Ohrani enako dimenzijo (ali večjo)
- Commit z: `assets: zamenjaj <ime> z HD verzijo`

## 📞 Kontakt

- **Issues:** [GitHub Issues](https://github.com/markec12345678/stronghold2027/issues)
- **Upstream:** [Stone Kingdoms GitLab](https://gitlab.com/stone-kingdoms/stone-kingdoms)

## 📜 Licenca

Prispevki so licencirani pod Apache 2.0 (enako kot upstream).

---

Hvala za tvoj prispevek! 🏰
