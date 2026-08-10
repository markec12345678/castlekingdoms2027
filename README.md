# Castle Kingdoms 2027

Modernizirana različica klasične RTS igre o gradnji gradov za leto 2027, zgrajena na LÖVE 11.5 (Lua/LuaJIT). Navdihnjen s klasičnimi srednjeveškimi strateškimi igrami.

[![Version](https://img.shields.io/badge/version-3.11.396-blue.svg)](https://github.com/markec12345678/castlekingdoms2027/releases)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)
[![LÖVE](https://img.shields.io/badge/LÖVE-11.5-orange.svg)](https://love2d.org)
[![Syntax](https://img.shields.io/badge/syntax-1130%2F1133%20pass-brightgreen.svg)](#)
[![Systems](https://img.shields.io/badge/Royal%20systems-484-blue.svg)](#)
[![Lua](https://img.shields.io/badge/Lua%20files-1133-green.svg)](#)
[![Registry](https://img.shields.io/badge/Royal%20Registry-%2BRoyalSystemsPanel-blueviolet.svg)](#)

## Prenosi

- **Zadnja izdaja**: [v3.11.396](https://github.com/markec12345678/castlekingdoms2027/releases)
- **.love datoteka**: `castlekingdoms2027-v3.11.396.love` (34 MB brez LFS, 305 MB z LFS)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md) — 484 Royal sistemov, 1133 Lua datotek, +RoyalSystemsRegistry + Ctrl+R UI Panel
- **LFS**: Po git clone zahtevaj `git lfs pull` za prave PNG asset-e (305 MB)

## Zagon

```cmd
& "C:\Program Files\LOVE\love.exe" "F:\pot\do\castlekingdoms2027-v2.9.1.love"
```

Ali iz git checkout-a (zahteva [git-lfs](https://git-lfs.com/)):
```cmd
git clone https://github.com/markec12345678/castlekingdoms2027.git
cd castlekingdoms2027
git lfs install
git lfs pull
love .
```

## Statistika projekta

| Metrika | Vrednost |
|---------|----------|
| Lua datoteke | 1133 |
| Vrstic kode | ~463.000 |
| GLSL shaderji | 12 |
| Jezikov | 32 |
| Verzij | 135+ (v1.7.9 → v3.11.396) |
| Bug popravkov | 155 (90 krogov pregleda) |
| Syntax pass rate | 1130/1133 (99,7%) |
| PNG assetov | 1.206 |
| **Royal sistemov** | **484 (v3.11.396)** |
| **Royal Systems Registry** | **da (auto-discovers vse 484 sisteme)** |
| **Royal UI Panel** | **Ctrl+R (full-screen browser + actions)** |
| Kampanjske misije | 21 (10 Fernhaven + 11 zgodovinskih) |
| Skirmish misije | 15 |
| Co-op misije | 10 |
| AI osebnosti | 8 |
| Težavnosti | 6 |
| AI konfiguracije | 48 (8×6) |
| Vojaške enote | 11 |
| Zgradbe | 50+ |
| Formacije | 7 |
| Upgrade poti | 7 |
| Vremenski tipi | 9 |
| Festivali | 8 |
| Ekonomski dogodki | 15 |
| Tehnologije | 14 |
| Mape | 6 + procedural generation |
| Steam achievementi | 15 |
| Voice-over sporočila | 42+ |
| SFX kategorije | 8 |
| Tutorial hints | 16 |
| Loading tips | 50+ |
| Daily challenge predloge | 14 |
| Vohunske misije | 5 |
| Produkcijske verige | 7 |
| Stopnje odnosov | 5 |
| Tipi trgovskih poti | 3 |
| Tipi ukazov | 7 |
| Prioritete obvestil | 4 |
| Kategorije obvestil | 6 |
| Kategorije zgradb | 7 |
| Redkosti achievementov | 4 |
| Oskrbne zgradbe | 5 |
| Naključni dogodki | 7 |
| Quest predloge | 9 |
| Sledene metrike | 25+ |
| Taktični načini | 5 |
| Tipi surovin | 17 |
| Diplomatske akcije | 9 |
| Tipi herojev | 6 |
| Vremenske sposobnosti | 7 |
| Zoom nivoji | 5 |
| Hitrosti igre | 8 |
| Stopnje ugleda | 9 |
| Leaderboard kategorije | 8 |
| Tipi turnirjev | 5 |
| Biomi (procedural) | 5 |
| Velikosti map (procedural) | 4 |
| Modding API sekcije | 5 |
| Sekcije povzetka igre | 6 |
| Stopnje ocen | 6 |
| **Religije** | **5** |
| **Verske zgradbe** | **7** |
| **Verske akcije** | **6** |
| **Sveti dnevi** | **7** |
| **Tipi relikvij** | **7** |
| **Cehi (guilds)** | **5** |
| **Stopnje članstva ceha** | **4** |
| **Cehovske pogodbe** | **5** |
| **Stopnje ugleda ceha** | **7** |
| **Najemniška podjetja** | **8** |
| **Trajanja najemniških pogodb** | **4** |
| **Tipi sapovnih pogodb** | **5** |
| **Razredi zapornikov** | **5** |
| **Zapore** | **4** |
| **Bolezni** | **6** |
| **Zdravstvena infrastruktura** | **5** |
| **Governor tipi** | **6** |
| **Governor lastnosti** | **12** |
| **Svetovalci (court)** | **6** |
| **Plemiške hiše** | **5** |
| **Dvoranski eventi** | **7** |
| **Svetovalci (court)** | **6** |
| **Tournament arene** | **5** |
| **Shrines** | **3** |
| **Scarcity eventi** | **6** |
| **Stopnje racioniranja** | **4** |
| **Tipi uporov** | **6** |
| **Pacifikacijske opcije** | **6** |
| **Kontrabanda** | **8** |
| **Tihotapske metode** | **4** |
| **Kraljevski odloki** | **12** |
| **Kategorije odlokov** | **4** |
| **Verige odlokov** | **3** |
| **Izobraževalne ustanove** | **5** |
| **Umetnostne oblike** | **6** |
| **Slavni obiskovalci** | **8** |
| **Kulturni dosežki** | **6** |
| **Kraljeve hiše** | **6** |
| **Tipi porok** | **4** |
| **Tipi ladij** | **5** |
| **Pomorske zgradbe** | **4** |
| **Pomorske taktike** | **4** |
| **Letni časi** | **4** |
| **Zimske kvartire** | **4** |
| **Tipi davkov** | **6** |
| **Davčne stopnje** | **5** |
| **Kategorije kronike** | **8** |
| **Stopnje kakovosti kronike** | **6** |
| **Heraldične barve (tinctures)** | **8** |
| **Heraldični simboli (charges)** | **12** |
| **Delitve ščita** | **6** |
| **Tipi kovancev** | **5** |
| **Tuje valute** | **4** |
| **Tipi turnirjev** | **5** |
| **Turnirska prizorišča** | **6** |
| **Tipi vohunov** | **6** |
| **Vohunske misije** | **8** |
| **Tipi zabavljačev** | **6** |
| **Tipi predstav** | **11** |
| **Zabavne zgradbe** | **4** |
| **Tipi dokumentov** | **6** |
| **Arhivske zgradbe** | **4** |
| **Tipi potovanj (progress)** | **6** |
| **Tipi spremstva** | **6** |
| **Tipi peticij** | **5** |
| **Tipi zločinov** | **8** |
| **Tipi kazni** | **6** |
| **Sodne zgradbe** | **4** |
| **Tipi stražarjev** | **5** |
| **Tipi groženj** | **6** |
| **Naloge stražarjev** | **5** |
| **Tipi gostij** | **6** |
| **Tipi jedi** | **8** |
| **Kuhinjske zgradbe** | **3** |
| **Tipi živali** | **8** |
| **Menažerijske zgradbe** | **4** |
| **Tipi znamenj** | **6** |
| **Tipi prerokb** | **8** |
| **Tipi zelišč** | **8** |
| **Tipi zdravil** | **6** |
| **Tipi strupov** | **4** |
| **Apothekarske zgradbe** | **3** |
| **Tipi zemljevidov** | **6** |
| **Kartografske zgradbe** | **3** |
| **Tipi konjev** | **6** |
| **Hlevske zgradbe** | **4** |
| **Tipi panjev** | **6** |
| **Čebelji produkti** | **4** |
| **Tipi medovca** | **3** |
| **Sorte grozdja** | **6** |
| **Tipi vin** | **4** |
| **Vinogradniške zgradbe** | **3** |
| **Tipi ptic prey** | **6** |
| **Falconry zgradbe** | **4** |
| **Tipi vrtov** | **6** |
| **Tipi rastlin** | **8** |
| **Alkimistični procesi** | **6** |
| **Alkimistični materiali** | **4** |
| **Laboratorijske zgradbe** | **3** |
| **Tipi divjadi** | **6** |
| **Lovske zgradbe** | **4** |
| **Tipi lovov** | **5** |
| **Lovski psi** | **4** |
| **Tipi dreves** | **6** |
| **Gozdske zgradbe** | **4** |
| **Genetske lastnosti** | **8** |
| **Krvne linije** | **6** |
| **Glasbeni instrumenti** | **6** |
| **Glasbene kompozicije** | **8** |
| **Glasbene zgradbe** | **3** |
| **Filozofske šole** | **6** |
| **Teme modrosti** | **8** |
| **Akademske zgradbe** | **3** |
| **Tipi bolezni** | **6** |
| **Tipi zdravljenj** | **8** |
| **Medicinske zgradbe** | **4** |
| **Zodiakalni znaki** | **12** |
| **Nebesni dogodki** | **8** |
| **Tipi horoskopov** | **6** |
| **Oblegovalni stroji** | **8** |
| **Tipi utrdb** | **6** |
| **Inženirske zgradbe** | **4** |
| **Tipi odposlancev** | **6** |
| **Diplomatske misije** | **8** |
| **Diplomatske zgradbe** | **4** |
| **Tipi kronik** | **6** |
| **Zgodovinske teme** | **8** |
| **Arhivske zgradbe** | **4** |
| **Tipi slovesnosti** | **8** |
| **Protokoli** | **6** |
| **Slovesne zgradbe** | **4** |
| **Smrtni grehi** | **6** |
| **Tipi pokore** | **8** |
| **Duhovne zgradbe** | **4** |
| **Tipi glasbenikov** | **6** |
| **Tipi pesmi** | **8** |
| **Prizorišča** | **4** |
| **Tipi šal** | **8** |
| **Tipi norčkov** | **6** |
| **Komedijska prizorišča** | **4** |
| **Tipi pijač** | **6** |
| **Tipi jedi** | **8** |
| **Jedilne zgradbe** | **4** |
| **Tipi sveč** | **6** |
| **Voščeni produkti** | **8** |
| **Svečarske zgradbe** | **4** |
| **Tipi keramike** | **6** |
| **Keramični produkti** | **8** |
| **Lončarske zgradbe** | **4** |
| **Tipi tkanin** | **6** |
| **Tekstilni produkti** | **8** |
| **Tekstilne zgradbe** | **4** |
| **Tipi stekla** | **6** |
| **Stekleni produkti** | **8** |
| **Steklarske zgradbe** | **4** |
| **Tipi ur** | **6** |
| **Časovni produkti** | **8** |
| **Urarske zgradbe** | **4** |
| **Dragi kamni** | **8** |
| **Tipi nakita** | **6** |
| **Zlatarske zgradbe** | **4** |
| **Tipi rokopisov** | **6** |
| **Iluminacije** | **8** |
| **Skriptorijske zgradbe** | **4** |
| **Tipi pogrebov** | **6** |
| **Tehnike balzamiranja** | **8** |
| **Pogrebne zgradbe** | **4** |
| **Dišavne sestavine** | **8** |
| **Tipi parfumov** | **6** |
| **Perfumerske zgradbe** | **4** |
| **Viri barv** | **8** |
| **Kategorije barv** | **6** |
| **Barvarske zgradbe** | **4** |
| **Tipi vezav** | **6** |
| **Kategorije knjig** | **8** |
| **Knjižnične zgradbe** | **4** |
| **Tipi kiparstev** | **6** |
| **Tipi kamna** | **8** |
| **Kiparske zgradbe** | **4** |
| **Tipi slik** | **6** |
| **Pigmenti** | **8** |
| **Slikarske zgradbe** | **4** |
| **Livarski produkti** | **6** |
| **Kovine** | **8** |
| **Kovinarske zgradbe** | **4** |
| **Usnjeni produkti** | **6** |
| **Tipi kož** | **8** |
| **Usnjarske zgradbe** | **4** |
| **Tipi surveyjev** | **6** |
| **Merilni instrumenti** | **8** |
| **Geodetske zgradbe** | **4** |
| **Davčne metode** | **6** |
| **Davčna okrožja** | **8** |
| **Davčne zgradbe** | **4** |
| **Tipi sporočil** | **6** |
| **Tipi kurirjev** | **8** |
| **Poštne zgradbe** | **4** |
| **Tipi žganih pijač** | **6** |
| **Destilarske sestavine** | **8** |
| **Destilarske zgradbe** | **4** |
| **Kategorije orožja** | **6** |
| **Kovinske zlitine** | **8** |
| **Kovaške zgradbe** | **4** |

## Funkcije

### 🎮 Jedro igre
- **21 misij kampanje** s story cutscene-i v slovenščini (10 Fernhaven + 11 zgodovinskih Norman Conquest 1066-1087)
- **15 skirmish misij** s progresivno težavnostjo (Skirmish Trail)
- **10 co-op misij** za 2 igralca
- **Freebuild način** za sproščeno igranje
- **8 AI osebnosti** (aggressive, balanced, defensive, economic, siege_master, fortress_keeper, raider, diplomat) × 6 težavnosti
- **Dynamic economy** — supply/demand, inflacija, sezonski modifikatorji, 10 ekonomskih dogodkov
- **Combat system** — projektili, oklep, damage variance, game feel
- **5 bojnih formacij** (line, column, wedge, scatter, box) z bonusi
- **5 stopenj veterancy** (Novinec → Legendarni) z stat bonusi
- **11 vojaških enot** (Archer, Crossbowman, Spearman, Pikeman, Maceman, Swordsman, Knight, Huscarl, Longbowman, NormanKnight, Javelinman)
- **4 oblegovalna orožja** (catapult, trebuchet, siege tower, battering ram) z resničnimi sprite-i
- **6 vremenskih tipov** ki vplivajo na gameplay (farme, hitrost, vidljivost)
- **Fog of War** s 3 stanji (hidden, explored, visible)
- **5 festivalov** (turnir, gostija, plesi, sejem, verski praznik)
- **6 velikosti map** (Fernhaven, Hastings, London, Yorkshire, WelshBorders, Rouen)
- **Dynamic unit cap** glede na FPS
- **Auto worker assignment** s prioriteto
- **Building upgrade tree** (5 poti, 2-4 tier-i)

### 🌐 Multiplayer
- **TCP/IP socket networking** (do 8 igralcev)
- **Lobby UI** — host/join, seznam igralcev, ready status
- **In-game chat** (Enter za odprtje)
- **Diplomacy** — 6 stanj (neutral, allied, war, truce, proposed_alliance, proposed_peace)
- **Trade system** — predlogi, darila, trade routes
- **Spectator mode** — opazovanje iger (TAB za preklop igralca)
- **Co-op campaign** — 2 igralca skupaj
- **Custom map sharing** — deljenje map med igralci
- **F9** — diplomacy & trade panel

### 🎨 HD Grafika
- **Normal mapping** za teren (Sobel filter iz heightmap)
- **Dynamic point lights** (do 32 luči — bakle, ogenj, zgradbe)
- **SSAO** (Screen-Space Ambient Occlusion)
- **ACES filmic tone mapping** + gamma korekcija
- **Bloom, color grading, vignette** shaderji
- **Day/night cycle** z dinamično osvetlitvijo
- **Weather system** (dež, sneg, megla, nevihta)
- **Particle effects** (7 tipov: spark, smoke, blood, dust, gold, fire, magic)
- **Construction animations** (progress bar, delci, proslava)
- **Visual polish** (UI animacije, hit/build/death efekti)

### 🔊 Zvok
- **Dynamic music** — 5 stanj (menu, peace, combat, victory, defeat)
- **SFX library** — 4 kategorije (combat, building, UI, environment)
- **3D positional audio** (glasnost glede na razdaljo)
- **Slovenian voice-over** — 30+ notifikacij v slovenščini
- **5 kategorij glasnosti** (master, sfx, music, speech, ambient)
- **AI personality dialogue** — 30+ unikatnih dialogov v slovenščini

### 🌍 Lokalizacija
- **32 jezikov** (slovenščina, angleščina, srbščina, grščina, bolgarščina, ...)
- **RTL podpora** (arabščina, hebrejščina)
- **Font detection** (cyrillic, greek, cjk, arabic)
- **Runtime preklop jezika**

### ♿ Dostopnost
- **Colorblind mode-i** (protanopia, deuteranopia, tritanopia)
- **Font scaling** (small, medium, large, extra large)
- **Reduced motion** (izklop screen shake)
- **High contrast mode**
- **Subtitles for speech**
- **Gamepad support** (polna podpora krmilnika z virtualnim kazalcem)
- **Auto-pause na focus loss**

### 🛠️ Orodja
- **Map Editor** (F4) — terrain painting, objects, save/load
- **Replay System** (Ctrl+R) — snemanje/predvajanje
- **Statistics Dashboard** (Ctrl+S) — session + lifetime statistike
- **Debug Console** (Tilde ~) — 12 ukazov
- **Crash Handler** (F11) — auto-disable failing systems
- **Performance Watchdog** — auto quality adjustment
- **Performance Benchmark** (Ctrl+P) — 6 avtomatiziranih testov
- **Release Checklist** (Ctrl+L) — 45 pre-release preverjanj
- **Integration Tests** (Ctrl+I) — 25 testov
- **Screenshot Manager** (Ctrl+M ali F12) — avtomatsko zajemanje
- **Object Pooling** — performance optimizacija
- **Pathfinding Optimizer** — JPS + caching
- **Auto-save** z crash recovery (vsakih 5 minut)
- **Save compatibility** z migration system

### 🔌 Modding
- **Mod loader** — scan /mods, load manifest.lua
- **Custom buildings, units, maps, scripts**
- **Hot-reload** za development
- **Steam Workshop integration** (subscribe/upload)
- **Sample mod** vključen (GoldMine building)

### 🏆 Steam Integration
- **15 achievements** (first_victory, campaign_complete, master_builder, ...)
- **Stats tracking** (buildings, kills, trades, alliances)
- **8 leaderboard kategorij** z AI competitors
- **Steam Workshop** (subscribe/upload/import)
- **Cloud saves** z rich presence

### ⛪ Vera & Religija (v3.0.8)
- **5 religij** (katolištvo, pravoslavje, poganstvo, herezija, državna vera)
- **7 verskih zgradb** (kapela, cerkev, katedrala, samostan, svetišče, tempelj, sveto mesto)
- **6 verskih akcij** (blagoslov, izobčenje, sveta vojna, pokrščevanje, donacija, romanje)
- **7 svetih dni** v letu (Božič, Velika noč, kronanje, ...)
- **Sistem relikvij** (7 tipov, passivni bonusi)
- **Herezija in inkvizicija** (širjenje, zatiranje z vero)
- **Verska toleranca** (0-100, vpliva na širjenje herezije)
- **Diplomatski modifikatorji** med religijami

### 🏛️ Cehovski sistem (v3.0.9)
- **5 cehov** (trgovski, kovaški, tesarski, zidarski, pivovarski)
- **4 stopnje članstva** (vajenec, pomočnik, mojster, starešina)
- **Cehovske dvorane** (gradnja + 2 nadgradnje)
- **Tedenske cehovnine** (avtomatsko)
- **Cehovske zakladnice** (samo starešina dviguje)
- **5 tipov pogodb** (dostava, kvota, rekrutacija, sabotaža, obrt)
- **Ugled** (-100 do +100, 7 stopenj)
- **Rivalstva in zavezništva** med cehovi
- **Passivni bonusi** (popusti, proizvodnja, kakovost)

### ⚔️ Najemniške čete (v3.1.0)
- **8 najemniških podjetij** (mečevci, samostrelci, kopjaši, konjenica, inženirji, saparji, izvidniki, stražarji)
- **4 trajanja pogodb** (14d, 30d, 90d, 365d)
- **Negocijske opcije** (ekskluzivnost, bonus po uspehu, aukcije)
- **Ugled** pri podjetjih (0-100)
- **Dnevne plače** (zlato vsak dan)
- **Mehanika izdaje** (premajhen ugled → prestop k nasprotniku)
- **Aukcije z nasprotniki** (ponudbeni vojni)
- **Specifični bojni bonusi** (napad, obramba, hitrost, obleganje)

### 🔒 Zaporniki & odkupnine (v3.1.1)
- **5 razredov zapornikov** (kmet, vojak, vitez, plemič, kraljevska oseba)
- **4 zapore** (zapora, temnica, stolp, trdnjavska ječa)
- **Capture chance** glede na razred (1%-30%)
- **Negotiacija odkupnin** (5 rund, counter-offer)
- **Sistem izmenjav** zapornikov (uravnotežene glede na težo)
- **Usmrtitev in izpust** z diplomatskimi posledicami
- **Dnevno vzdrževanje** zapornikov
- **Escape mehanika** (glede na jakost zapore)
- **Random eventi** (družina ponuja odkupnino)
- **Ugled pri plemičih** (vpliva na capture chance)

### 🩺 Zdravje & bolezni (v3.0.7)
- **6 tipov bolezni** (kuga, dizenterija, gripa, črne koze, lakotna vročica, kolera)
- **5 zdravstvenih objektov** (apoteka, zdravilnica, čisti vodnjak, bolnišnica, kanalizacija)
- **Karantenski sistem** (-70% širjenje)
- **Raziskava zdravil**
- **Health rating** (0-100, vpliva na rast populacije)

### 👑 Plemiči & dvor (v3.0.6)
- **6 svetovalcev** (kancler, zakladnik, maršal, špijon, diplomant, dvorni župnik)
- **5 plemiških hiš** z dinastičnimi zvezami
- **7 dvoranskih eventov** (zarote, poroke, atentati)
- **Sistem porok in dedičev**

### 🏛️ Governorji (v3.0.5)
- **6 tipov governorjev** (ekonom, general, inženir, diplomat, špijon, duhovnik)
- **12 lastnosti** (pravičnost, krutost, modrost, itd.)
- **Realna prilagoditev** težavnosti

### 🏰 Obleganje gradov (v3.0.3)
- **4 faze obleganja** (priprava, napad, prodor, predaja)
- **9 sekcij zidov**
- **5 oblegovalnih strojev**
- **4 obrambni sistemi** (katapulti, olje, smodnik, pikeman)

### 🌾 Lakota & redkost (v3.1.2)
- **6 scarcity eventov** (suša, nežit, kobilice, ostra zima, poplava, leto kuge)
- **4 stopnje racioniranja** (izobilje, normalno, zmanjšano, stradanje)
- **Žitnice** (gradnja, kapaciteta 2000 hrane)
- **Uvoz hrane** in **pakti o medsebojni pomoči**
- **Podnebni ciklus** (8 faz, leta obilja vs leta lakote)
- **Stradanje** z žrtvami prebivalstva

### ⚔️ Upori & državljanska vojna (v3.1.3)
- **6 tipov uporov** (kmečki, plemiški, verski, vojaški, nasledstveni, tuji)
- **6 opcij pacifikacije** (darila, davki, festival, usmrtitev, amnestija, vojaško)
- **Loyalty tracker** per regija in plemič (0-100)
- **Conspiracies** (detekcija preko špijonaže, 4 tipi)
- **Državljanska vojna** (3+ sočasni upori)
- **Spread mehanika** in sistem zahtev

### 💀 Črni trg & tihotapljenje (v3.1.4)
- **8 tipov kontrabande** (začimbe, svila, orožje, žganje, nakit, relikvije, strupi, sužnji)
- **4 metode tihotapljenja** (karavana, ladja, nočni tekač, podkupljenci)
- **Črni trgovci** (skriti NPC z random inventarjem)
- **Tax evasion** (skrivanje prihodka)
- **Carinski nadzor** (auditi, globe, zaplembe)
- **Podkupovanje uradnikov**
- **Criminal reputation** in **law enforcement level**

### 📜 Kraljevski odloki (v3.1.5)
- **12 odlokov** v 4 kategorijah (ekonomski, vojaški, socialni, verski)
- **Max 5 aktivnih** hkrati, trajanje ali permanentno
- **Predpogoji** (raziskava zahteva 1000 zlata)
- **3 verige odlokov** z bonusi (Razsvetljeni vladar, Vojni lord, Bogataš)
- **Edict fatigue** (preveč odlokov → utrujenost)

### 🎨 Kultura & izobraževanje (v3.1.6)
- **5 izobraževalnih ustanov** (skriptorij, knjižnica, akademija, univerza, observatorij)
- **6 umetnostnih oblik** (rokopis, slika, kip, glasba, poezija, arhitektura)
- **Pismenost** (0-100%, vpliva na raziskave)
- **Knowledge točke** (valuta za umetnost)
- **Kulturni prestiž** in **turizem**
- **8 slavnih obiskovalcev** (Tomaž Akvinski, Dante, Giotto, ...)
- **6 kulturnih dosežkov**
- **Pokroviteljstvo** umetnosti

### 👑 Kraljevska dinastija (v3.1.7)
- **6 kraljevskih hiš** (Normanska, Plantageneti, Habsburžani, Kapetinci, Hohenstaufen, Domača)
- **4 tipi porok** (osnovna, močna, kraljevska, matrilinearna)
- **Sistem dedičev** (rojstvo, staranje, izobraževanje, obljube)
- **Dowry** (dota) negotiacije
- **Razveze** in ponižitve
- **Succession crisis** (kralj umre brez naslednika → upor)
- **Letni ciklus** (staranje, rojstva, smrti)

### ⚓ Pomorski boji & trgovina (v3.1.8)
- **5 tipov ladij** (ribiška, koga, galeja, karaka, vojna ladja)
- **4 pomorske zgradbe** (pristanišče, ladjedelnica, suhi dok, akademija)
- **4 taktike boja** (zabijanje, vkrcanje, streljanje, bombardiranje)
- **Trgovske poti** z visokim profitom in tveganjem piratov
- **Blokade** sovražnikove trgovine
- **Zajemanje ladij** (40% chance pri vkrcanju)
- **Pomorski prestiž**

### ❄️ Zima & hibernacija (v3.1.9)
- **4 letni časi** z različnimi učinki na vojsko
- **4 zimske kvartire** (tabor, barake, trdnjava, zalogovnik)
- **Atricija vojske** pozimi (HP izguba, smrt)
- **Frostbite** (ozebline, dodatne žrtve)
- **Supply sistem** z rekvizicijami
- **Hibernacija** vojske do pomladi
- **Foraging** (poškoduje podeželje)

### 💰 Kraljeva zakladnica & davki (v3.2.0)
- **6 tipov davkov** (dohodnina, posestnina, trgovski, solni, ognjiščarina, desetina)
- **5 davčnih stopenj** (oproščeno do tiransko)
- **Ločena zakladnica** (do 50.000 zlata)
- **Davčni uradi** za učinkovitost
- **Sistem posojil** z obrestmi in roki
- **Inflacija** in **korupcija**
- **Davčni prazniki** za srečo
- **Rebellion risk** pri tiranski stopnji

### 📜 Kronika & zgodovina (v3.2.1)
- **8 kategorij dogodkov** (vojaško, politično, ekonomsko, versko, socialno, dinastično, kulturno, katastrofalno)
- **18+ templates** za narativno pisanje
- **Avtomatsko beleženje** preko event subscriptions
- **Legacy score** s 6 stopenj kakovosti
- **Export kronike** v tekstovno datoteko
- **Reign summary** generator
- **Legacy rank** (Mitičen, Legendaren, Izjemen, ...)

### 🛡️ Heraldika & grbi (v3.2.2)
- **8 heraldičnih barv** (zlato, srebro, rdeča, modra, črna, zelena, škrlatna, oranžna)
- **12 simbolov** (lev, orel, križ, lilija, zmaj, krona, meč, ...)
- **6 delitev ščita** (polno, navpično, vodoravno, četrtinsko, ...)
- **Pravila tincture** (kovina na barvi ali obratno)
- **Heraldični register** in prepoznavanje hiš
- **Heraldični spori** in reševanje
- **Heraldic prestige** (redke kombinacije)

### 💎 Kraljevska kovnica & valuta (v3.2.3)
- **5 tipov kovancev** (denar, groat, florin, plemič, dukat)
- **4 tuje valute** z menjalnimi tečaji
- **Kovnice** in **mintmaster** NPC
- **Debasement** (znižanje čistosti za zlato)
- **Counterfeiting** in varnostni ukrepi
- **Trust level** in exchange rates

### ⚔️ Turnirji & jousting (v3.2.4)
- **5 tipov turnirjev** (joust, melee, strelništvo, veliki melee, kraljevi)
- **6 prizorišč** (vaški travnik do velikega stadiona)
- **Rekrutiranje vitezov** s spretnostjo in zdravjem
- **Single elimination** simulacija
- **Sistem stavnjenja** (2x-3x izplačilo)
- **Poškodbe** in prize money
- **Tournament fame** (dolgoročna slava)

### 🕵️ Vohunstvo & dvorske spletke (v3.2.5)
- **6 tipov vohunov** (dvorna dama, menih, trgovec, norček, služabnik, mojster)
- **8 tipov misij** (infiltriraj, sabotaža, atentat, kraja, ...)
- **Spy skill progression** in cover system
- **Counter-intelligence** (lovljenje vohunov)
- **Zasliševanje** ujetih vohunov
- **Blackmail material** in izsiljevanje
- **Spy upkeep** in detection chance

### 🎭 Dvorna zabava (v3.2.6)
- **6 tipov zabavljačev** (bard, norček, glasbenik, trubadur, plesalec, krotilce)
- **11 tipov predstav** (pesem, šala, epska pripoved, satira, romansa, ...)
- **4 zabavne zgradbe** (odra, gledališče, glasbena dvorana, amfiteater)
- **Court reputation** sistem
- **Touring** (pošiljanje k zaveznikom)
- **Skill progression** zabavljačev
- **Satira** s tveganjem užalitve

### 📚 Kraljevi arhiv (v3.2.7)
- **6 tipov dokumentov** (pogodba, odlok, darovnica, porokna, davčni, kronika)
- **4 arhivske zgradbe** (omara, soba, kraljevi arhiv, velika knjižnica)
- **Document degradation** in preservation
- **Royal scribes** (NPC za pisanje)
- **Treaty management** (aktivne, pretečene, prekinjene)
- **Document search** in restoration

### 🐎 Kraljeva potovanja (v3.2.8)
- **6 tipov ciljev** (glavno mesto, provinca, vazal, meja, sveto mesto, tuj dvor)
- **6 tipov spremstva** (stražarji, dvorjani, služabniki, bard, kuhar, duhovnik)
- **5 tipov peticij** (mejni spori, davki, razbojniki, čudeži, darila)
- **Incidenti na poti** (nevihte, razbojniki, bolezen)
- **Bonusi** za lojalnost, srečo, vero, diplomacijo

### ⚖️ Srednjeveško pravo (v3.2.9)
- **8 tipov zločinov** (kraja, umor, izdaja, herezija, tihotapljenje, ...)
- **6 tipov kazni** (globa, steber, bičanje, zapor, izgon, usmrtitev)
- **4 sodne zgradbe** (vaško do vrhovno sodišče)
- **Sodniki** NPC s spretnostjo
- **Trial sistem** z dokazi in pričevalci
- **Crime rate** in justice reputation

### 🛡️ Kraljeva straža (v3.3.0)
- **5 tipov stražarjev** (dvorna, elitna, tuja, najemniška, viteški poveljnik)
- **6 tipov groženj** (morilec, strup, tropa, rivalni lord, heretik, tuj agent)
- **5 nalog** (patrulja, spremstvo, palača, potovanje, preiskava)
- **Plot detection** in food taster
- **Escape route** za zmanjšanje škode
- **Ruler health** in smrt

### 🍽️ Kraljeve gostije (v3.3.1)
- **6 tipov gostij** (državna večerja, poroka, proslava zmage, verska, pobratna, diplomatska)
- **8 tipov jedi** (merjavec, labod, pavan, ribe, kruh, vino, pivo, sladica)
- **3 kuhinjske zgradbe** (kuhinja, kraljeva kuhinja, velika dvorana)
- **Chef NPC** s spretnostjo
- **Guest management** in satisfaction
- **Feast disasters** (zastrupitev, pretepe, požar)

### 🦁 Kraljeva menažerija (v3.3.2)
- **8 tipov živali** (lev, medved, sokol, pes, panter, slon, opica, pavan)
- **4 menažerijske zgradbe** (kletka, ograja, ptičnjak, velika menažerija)
- **Caretakers** NPC s spretnostjo
- **Breeding program** (mladiči, redke živali)
- **Public exhibitions** (dvigujejo srečo in prestiž)
- **Hunting with animals** (sokoli in psi)

### 🔮 Astrolog in znamenja (v3.3.3)
- **6 tipov znamenj** (komet, mrk, krvavi mesec, padajoča zvezda, poravnava, severni siji)
- **8 tipov prerokb** (zmaga, poraz, lakota, kuga, rojstvo, smrt, zveza, izdaja)
- **Astrolog NPC** z natančnostjo
- **Observatorij** (izboljša natančnost)
- **Superstition level** (vpliva na srečo)

### 🌿 Apothekar in medicina (v3.3.4)
- **8 tipov zelišč** (mandragora, špaj, žajbelj, rožmarin, česen, volčje jabolko, pelin, vrobnica)
- **6 tipov zdravil** (zdravilni napoj, protistrup, sredstvo proti bolečini, tonik, umirjevalo, poživilo)
- **4 tipi strupov** (strup podgan, volčji, počasna smrt, uspavalni napoj)
- **3 apothekarske zgradbe** (zeliščni vrt, delavnica, laboratorij)
- **Herb cultivation** in remedy crafting
- **Healing the ruler** in disease prevention

### 🗺️ Kartograf in zemljevidi (v3.3.5)
- **6 tipov zemljevidov** (svet, regionalni, vojaški, trgovski, zaklad, pomorska karta)
- **3 kartografske zgradbe** (skriptorij, kartografska soba, arhiv)
- **Cartographer NPC** z natančnostjo
- **Exploration tracking** (odkrivanje regij)
- **Treasure maps** in treasures
- **Map trading** in strategic bonuses

### 🐎 Mojster konj in hlevi (v3.3.6)
- **6 tipov konjev** (bojni, hitrovec, palfrej, vsestranski, tovorni, težki bojni)
- **4 hlevske zgradbe** (pašnik, hlev, jahalna dvorana, farma za rejo)
- **Master of Horse NPC** s spretnostjo
- **Horse training** (urjenje za boj in hitrost)
- **Horse breeding** (vzreja z verjetnostjo uspeha)
- **Equestrian events** (dirke in predstave z nagradami)
- **Cavalry bonuses** (hitrost, boj, prestiž)

### 🐝 Čebelar in med (v3.3.7)
- **6 tipov panjev** (brosten, slamnati, škatlasti, okvirni, kraljevski, apiarij)
- **4 produkti** (med, vosak, propolis, matični mleček)
- **3 tipi medovca** (navadni, začinjeni, kraljevski)
- **Seasonal production** (pomlad/poletje = več)
- **Pollination bonus** (do +30% pridelka hrane)
- **Swarm events** (čebele se množijo ali pobegnejo)

### 🍇 Vinograd in vino (v3.3.8)
- **6 sort grozdja** (pinot noir, chardonnay, merlot, riesling, cabernet, muškat)
- **4 tipi vin** (namizno, dobro, letnik, kraljevska rezerva)
- **3 vinogradniške zgradbe** (vinograd, vinska klet, skladišče za staranje)
- **Vintner NPC** s spretnostjo
- **Wine aging** (vina se izboljšujejo s starostjo)
- **Vintage system** z bonusi

### 🦅 Sokolar in lov (v3.3.9)
- **6 tipov ptic prey** (skalnar, kragulj, orel, mali sokol, kobac, polarni sokol)
- **4 falconry zgradbe** (sokolarnica, letarica, urjenišče, reja)
- **Falconer NPC** s spretnostjo
- **Bird training** in hawking expeditions
- **Bird breeding** (vzreja redkih ptic)
- **Molting system** in competitions

### 🌹 Vrtnar in okrasni vrtovi (v3.4.0)
- **6 tipov vrtov** (vrtnice, zeliščni, vozliščni, vodni, topiarij, botanični)
- **8 tipov rastlin** (vrtnice, lilije, tulipani, sivka, bukvica, fontana, kip, živa meja)
- **Gardener NPC** s spretnostjo
- **Seasonal blooming** (različne rastline v različnih sezonah)
- **Garden tours** (obiskovalci prinašajo zlato)
- **Botanical collection** in competitions

### ⚗️ Alkimist in transmutacija (v3.4.1)
- **6 alkimističnih procesov** (transmutacija, eliksir življenja, kamen modrosti, ...)
- **4 materiali** (živo srebro, žveplo, sol, svinec)
- **3 laboratorijske zgradbe** (koča, laboratorij, veliki laboratorij)
- **Alchemist NPC** s spretnostjo
- **Transmutation** (svinec v zlato, 15% uspeh)
- **Elixir brewing** (zdravilni, moči, nevidnosti)
- **Philosopher's stone** (legendarni quest, neskončno zlato)
- **Explosion risk** in alchemical discoveries

### 🏹 Mojster lova in divjad (v3.4.2)
- **6 tipov divjadi** (jelen, merjavec, lisica, zajec, fazan, medved)
- **4 lovske zgradbe** (gozd, park, zajčji vrt, kraljevi rezervat)
- **5 tipov lovov** (kraljevi, sokolarski, lokostrelski, kopljični, poganjalni)
- **Master of Hunt NPC** s spretnostjo
- **Game population management** (trajnostni lov)
- **Hunting dogs** (4 pasme)
- **Trophy system** in hunting incidents

### 🌲 Gozdar in gozdovi (v3.4.3)
- **6 tipov dreves** (hrast, bor, breza, bukev, tisa, kostanj)
- **4 gozdske zgradbe** (koča, žaga, kopica za oglje, drevesnica)
- **Forester NPC** s spretnostjo
- **Sustainable forestry** (pogozdovanje)
- **Timber production** (les za gradnjo)
- **Charcoal production** (oglje za kovaške peči)
- **Foraging** (pasivna hrana iz gozdov)

### 🧬 Genetika in vzreja (v3.4.4)
- **8 genetskih lastnosti** (hitrost, moč, inteligenca, agresivnost, ...)
- **6 krvnih linij** (kraljevska, divja, gorska, puščavska, severna, cesarska)
- **Trait inheritance** in mutation system
- **Bloodline purity** tracking
- **Champion breeding** program
- **Lineage tracking** (družinsko drevo)
- **Breeding contracts** z drugimi dvori

### 🎵 Skladatelj in glasba (v3.4.5)
- **6 tipov instrumentov** (lutnja, harfa, flavta, boben, orgle, violina)
- **8 tipov kompozicij** (maša, madrigal, balada, ples, himna, žalostinka, sonata, opera)
- **3 glasbene zgradbe** (soba, koncertna dvorana, operna hiša)
- **Composer NPC** s spretnostjo
- **Composition creation** in public performances
- **Court orchestra** (najem glasbenikov)
- **Quality system** iz zgradb in skladatelja

### 📚 Filozof in modrost (v3.4.6)
- **6 filozofskih šol** (stoicizem, platonizem, aristotelizem, sholastika, misticizem, humanizem)
- **8 tem modrosti** (etika, politika, metafizika, logika, estetika, ...)
- **3 akademske zgradbe** (študijska soba, akademija, velika univerza)
- **Philosopher NPC** s spretnostjo in šolo
- **School adoption** z bonusi
- **Research system** in philosophical works publication
- **Student mentoring** (3-mesečni program)

### 📚 Vadba & UX
- **10-korak interaktivni tutorial** v slovenščini (Ctrl+T)
- **40+ loading tips** v 8 kategorijah
- **Credits screen** (Ctrl+E)
- **End game screen** s statistiko
- **Loading tips** med nalaganjem
- **Keybind help** (F1) — prikaz vseh bližnjic v igri
- **Performance overlay** (F3) — FPS, memory, frame time

### 🎯 QoL izboljšave
- **Rally points** za barake (desni klik)
- **Right-click dismiss** za vse panele
- **Building queue** (shift+klik, max 10)
- **Minimap drag scroll** (klik in vlečenje)
- **Auto worker assignment** s prioriteto (Ctrl+Shift+W toggle)
- **Dynamic unit cap** glede na FPS
- **Building hotkeys** (Ctrl+1-9)
- **Game speed control** (Space, 1-4)
- **Unit command queue** (shift+klik za več ukazov)
- **Minimap** s terenom, zgradbami, kamero
- **Resource flow visualizer** (Ctrl+Y)
- **Auto-save indicator**

### 🧠 AI
- **8 osebnosti** z edinstvenimi dialogi (aggressive, balanced, defensive, economic, siege_master, fortress_keeper, raider, diplomat)
- **6 težavnosti** (Story → Legendary)
- **48 AI konfiguracij** (8 osebnosti × 6 težavnosti)
- **Threat assessment** — AI se prilagaja moči igralca
- **AI personality dialogue** — 60+ dialogov v slovenščini
- **Resnični bojni ukazi** — AI dejansko napada, brani, se umika
- **Polno funkcionalna AI ekonomija** — proizvodnja, trgovina, delavci
- **Smart building placement**
- **Defense response**
- **Difficulty adaptation**

## Tipke

Glej [KEYBINDS.md](KEYBINDS.md) za celovit seznam 50+ tipkovnih bližnjic (0 konfliktov po 14 krogih pregleda).

## Arhitektura

Glej [SYSTEMS.md](SYSTEMS.md) za popoln seznam vseh 130+ modulov.

## Razvoj

Glej [CONTRIBUTING.md](CONTRIBUTING.md) za vodič za razvijalce.

## Zgodovina razvoja

Glej [CHANGELOG.md](CHANGELOG.md) za vse verzije od v1.7.9 do v3.7.6 (135+ verzij, 90 krogov pregleda, 155+ popravkov).

## Ključne verzije

- **v3.7.6** — Royal Smith Advanced & Weapon Forge System (6 orožij, 8 zlitin, quality grades)
- **v3.7.5** — Royal Brewer Advanced & Distillery System (6 žganih pijač, 8 sestavin)
- **v3.7.4** — Royal Messenger & Postal System (6 sporočil, 8 kurirjev, relay)
- **v3.7.3** — Royal Tax Collector & Revenue System (6 metod, 8 okrožij, utaja)
- **v3.7.2** — Royal Surveyor & Land Measurement System (6 surveyjev, 8 instrumentov)
- **v3.7.1** — Royal Leatherworker & Tannery System (6 produktov, 8 kož)
- **v3.7.0** — Royal Metalworker & Bronze Casting System (6 produktov, 8 kovin, litje)
- **v3.6.9** — Royal Painter & Fresco System (6 slik, 8 pigmentov)
- **v3.6.8** — Royal Sculptor & Stone Carving System (6 kiparstev, 8 kamnov)
- **v3.6.7** — Royal Bookbinder & Library System (6 vezav, 8 kategorij)
- **v3.6.6** — Royal Dyer & Color System (8 virov barv, 6 barv)
- **v3.6.5** — Royal Perfumer & Fragrance System (8 sestavin, 6 parfumov)
- **v3.6.4** — Royal Embalmer & Funerary System (6 pogrebov, 8 balzamiranj)
- **v3.6.3** — Royal Calligrapher & Illumination System (6 rokopisov, 8 iluminacij)
- **v3.6.2** — Royal Jeweler & Gemstone System (8 kamnov, 6 nakita)
- **v3.6.1** — Royal Clockmaker & Timekeeping System (6 ur, 8 produktov)
- **v3.6.0** — Royal Glassmaker & Stained Glass System (6 stekel, 8 produktov, vitraji)
- **v3.5.9** — Royal Weaver & Textile System (6 tkanin, 8 produktov, tapiserije)
- **v3.5.8** — Royal Potter & Ceramics System (6 keramik, 8 produktov, žganje)
- **v3.5.7** — Royal Chandlery & Wax Works System (6 sveč, 8 produktov)
- **v3.5.6** — Royal Cupbearer & Taster System (6 pijač, 8 jedi, detekcija strupa)
- **v3.5.5** — Royal Jester Advanced & Court Comedy System (8 šal, 6 norčkov)
- **v3.5.4** — Royal Minstrel & Troubadour System (6 glasbenikov, 8 pesmi, turneje)
- **v3.5.3** — Royal Confessor & Spiritual Guidance System (6 grehov, 8 pokor)
- **v3.5.2** — Royal Master of Ceremonies & Protocol System (8 slovesnosti, 6 protokolov)
- **v3.5.1** — Royal Historian & Chronicle Advanced System (6 kronik, genealogija, legacy)
- **v3.5.0** — Royal Diplomat & Envoy System (6 odposlancev, 8 misij, ambasade)
- **v3.4.9** — Royal Engineer & Siege Works System (8 strojev, 6 utrdb)
- **v3.4.8** — Royal Astrologer Advanced System (12 zodiak, horoskopi)
- **v3.4.7** — Royal Physician & Health System (6 bolezni, 8 zdravljenj)
- **v3.4.6** — Royal Philosopher & Wisdom System (6 šol, 8 tem, raziskave)
- **v3.4.5** — Royal Composer & Music System (6 instrumentov, 8 kompozicij)
- **v3.4.4** — Royal Falconry Breeding & Genetics System (8 lastnosti, 6 linij)
- **v3.4.3** — Royal Forester & Woodland System (6 dreves, les, oglje)
- **v3.4.2** — Royal Master of Hunt & Game System (6 divjadi, 5 lovov, psi)
- **v3.4.1** — Royal Alchemist & Transmutation System (6 procesov, kamen modrosti)
- **v3.4.0** — Royal Gardener & Ornamental Gardens System (6 vrtov, 8 rastlin)
- **v3.3.9** — Royal Falconer & Hawking System (6 ptic, lov, vzreja)
- **v3.3.8** — Royal Vineyard & Wine System (6 sort, 4 vina, staranje)
- **v3.3.7** — Royal Beekeeper & Honey System (6 panjev, medovec)
- **v3.3.6** — Royal Master of Horse & Stables System (6 konjev, vzreja, dirke)
- **v3.3.5** — Royal Cartographer & Maps System (6 zemljevidov, raziskovanje)
- **v3.3.4** — Royal Apothecary & Medicine System (8 zelišč, 6 zdravil, strupi)
- **v3.3.3** — Royal Astrologer & Omens System (6 znamenj, 8 prerokb)
- **v3.3.2** — Royal Pet & Menagerie System (8 živali, vzreja, predstave)
- **v3.3.1** — Royal Feast & Banquet System (6 gostij, 8 jedi, katastrofe)
- **v3.3.0** — Royal Guard & Personal Security System (5 stražarjev, 6 groženj)
- **v3.2.9** — Medieval Law & Justice System (8 zločinov, sojenja)
- **v3.2.8** — Royal Progress & Tour System (6 ciljev, peticije)
- **v3.2.7** — Royal Archive & Records System (6 dokumentov, pogodbe)
- **v3.2.6** — Royal Court Entertainment System (6 zabavljačev, 11 predstav)
- **v3.2.5** — Court Intrigue & Spy Network System (6 vohunov, 8 misij)
- **v3.2.4** — Tournament & Jousting System (5 tipov, 6 prizorišč, stave)
- **v3.2.3** — Royal Mint & Currency System (5 kovancev, debasement)
- **v3.2.2** — Heraldry & Coat of Arms System (8 barv, 12 simbolov)
- **v3.2.1** — Chronicle & History System (8 kategorij, narrativno pisanje, legacy)
- **v3.2.0** — Royal Treasury & Taxation System (6 davkov, posojila, korupcija)
- **v3.1.9** — Winter Quarters & Hibernation System (4 letni časi, atricija)
- **v3.1.8** — Naval Combat & Trade System (5 ladij, pomorski boji, pirati)
- **v3.1.7** — Royal Marriage & Dynasty System (6 hiš, dediči, nasledstvo)
- **v3.1.6** — Cultural & Education System (5 ustanov, 6 umetnosti, slavni obiskovalci)
- **v3.1.5** — Royal Decrees & Edicts System (12 odlokov, 4 kategorije, verige)
- **v3.1.4** — Black Market & Smuggling System (8 kontraband, 4 metode, carina)
- **v3.1.3** — Treason & Rebellion System (6 tipov uporov, državljanska vojna)
- **v3.1.2** — Famine & Resource Scarcity System (6 eventov, racioniranje)
- **v3.1.1** — Prisoner & Ransom System (5 razredov, capture, exchange)
- **v3.1.0** — Mercenary Contract System (8 podjetij, izdaja, aukcije)
- **v3.0.9** — Trade Guild System (5 cehov, 4 stopnje, pogodbe)
- **v3.0.8** — Religion & Faith System (5 religij, 7 zgradb, herezija)
- **v3.0.7** — Disease & Health System (6 bolezni, karantena)
- **v3.0.6** — Court & Nobility System (6 svetovalcev, plemiške hiše)
- **v3.0.5** — Governor & Administration System (6 tipov, 12 lastnosti)
- **v3.0.4** — Trade Negotiation System (4 tipi, AI counter-offer)
- **v3.0.3** — Castle Siege System (4 faze, zidovi, predaja)
- **v3.0.2** — Stats Dashboard Widget (6 panojev)
- **v3.0.1** — Matchmaking System (ELO, 5 tipov, 7 stopenj)
- **v3.0.0** — Resource Forecast System (projekcija, opozorila)
- **v2.9.9** — Performance Auto-Tuner (8 parametrov)
- **v2.9.8** — Dynamic Difficulty Adjuster (5 faktorjev)
- **v2.9.7** — Enhanced Map Editor (plasti, undo/redo)
- **v2.9.1** — Game Summary Generator (6 sekcij, letter grade)
- **v2.9.0** — Procedural Map Generator (5 biomov, 4 velikosti)
- **v2.8.9** — Camera Enhancement (smooth, cinematic, 5 zoom)
- **v2.8.8** — Time Manager (8 hitrosti, auto-pause, schedule)
- **v2.8.7** — Hero Unit System (6 herojev, leveling, sposobnosti)
- **v2.8.6** — Weather Warfare (7 vremenskih sposobnosti)
- **v2.8.5** — Enhanced Modding API (5 sekcij, 6 tipov vsebine)
- **v2.8.4** — Replay Enhancement (timeline, zaznamki)
- **v2.8.3** — PROJECT RENAME: Castle Kingdoms 2027
- **v2.8.2** — Leaderboard System (8 kategorij)
- **v2.8.1** — Custom Scenario Editor (25+ API funkcij)
- **v2.8.0** — Tournament System (5 tipov turnirjev)
- **v2.7.9** — Prestige & Ranking (9 stopenj ugleda)
- **v2.7.8** — Tactical Map Overlay (5 strateških načinov)
- **v2.7.7** — Game Analytics Dashboard (25+ metrik)
- **v2.7.6** — Quest System (9 stranskih misij)
- **v2.7.5** — Supply Line Manager (logistika)
- **v2.7.4** — Achievement Tracker (15 achievementov, 4 redkosti)
- **v2.7.3** — Building Manager (7 kategorij zgradb)
- **v2.7.2** — Notification Center (4 prioritete, 6 kategorij)
- **v2.7.1** — Random Event System + 8 novih surovin
- **v2.7.0** — Trade Route Manager (persistentne trgovske poti)
- **v2.6.9** — Army Command System (7 tipov ukazov)
- **v2.6.8** — Diplomatic Relations (5 stopenj odnosov)
- **v2.6.7** — Espionage & Intelligence (5 tipov misij)
- **v2.6.6** — Production Chain System (7 verig)
- **v2.6.5** — Population & Happiness System
- **v2.6.4** — Technology Tree (14 tehnologij)
- **v2.6.3** — Daily Challenge System
- **v2.6.2** — 3 ekstremni vremenski tipi
- **v2.6.1** — 2 upgrade poti + 2 formaciji
- **v2.6.0** — giveResources fix + casualty tracking
- **v2.5.4** — 4 normanske enote + 3 zgradbe
- **v2.5.0** — 21 kampanjskih misij + Steam cloud
- **v2.3.0** — LuaJIT upvalue fix (kritično)
- **v2.0.0** — Final Release Candidate

## Licenca

Apache License 2.0 — glej [LICENSE](LICENSE)

## Avtorji

- **markec12345678** — razvoj
- **Stone Kingdoms** — osnovni codebase (Apache 2.0)
- **Kenney.nl** — CC0 asseti

## Povezave

- [GitHub](https://github.com/markec12345678/castlekingdoms2027)
- [LÖVE](https://love2d.org)
- [Stone Kingdoms](https://gitlab.com/stone-kingdoms/stone-kingdoms)
- [Kenney.nl](https://kenney.nl) — CC0 assets
