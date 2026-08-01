# Stronghold 2027 - LFS Fix Guide

## Problem: Črni kvadratki v gradbenem meniju

Če v gradbenem meniju (kjer so hiše, stockpile, drvar, kamnolom) vidiš **črne kvadratke** namesto pravih ikon, to pomeni da **Git LFS ni pravilno potegnil datotek**.

## Vzrok

Vsi PNG-ji in zvočne datoteke so shranjeni v Git LFS (Large File Storage) zaradi omejitve GitHuba na 100MB na datoteko. Ko kloniraš repozitorij brez LFS podpore, dobiš "LFS pointerje" (majhne besedilne datoteke) namesto pravih binarnih datotek.

LÖVE nato poskusi naložiti te besedilne datoteke kot slike - kar povzroči črne kvadrate.

## Diagnoza

Zaženi diagnostično skripto:

```bash
bash scripts/check_lfs.sh
```

Če vidiš "❌ LFS POINTER" za katerokoli datoteko, imaš ta problem.

## Popravek

### Korak 1: Namesti Git LFS

**Windows:**
1. Prenesi iz https://git-lfs.github.com/
2. Zaženi namestitveni program
3. Restartaj terminal

**macOS:**
```bash
brew install git-lfs
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install git-lfs
```

### Korak 2: Konfiguriraj Git LFS

```bash
git lfs install
```

### Korak 3: Potegni LFS datoteke

```bash
git lfs pull
```

To bo preneslo ~1.8GB binarnih datotek. Lahko traja nekaj minut.

### Korak 4: Preveri

```bash
bash scripts/check_lfs.sh
```

Vse datoteke morajo biti "✓ OK".

### Korak 5: Zaženi igro

```bash
love .
```

## Alternativa: Direkten download

Če `git lfs pull` ne deluje (npr. zaradi GitHub LFS quota omejitev):

1. Pojdi na https://github.com/markec12345678/stronghold2027/releases
2. Prenesi zadnji release zip (ko bo na voljo)
3. Razširi zip in zaženi `love .`

## GitHub LFS omejitve

Free GitHub plan vključuje:
- **1 GB LFS storage** (mi trenutno uporabljamo ~1.8GB - že preseženo!)
- **1 GB LFS bandwidth na mesec** (vsak download porabi bandwidth)

Če presežeš omejitve:
- GitHub bo blokiral nadaljnje LFS operacije
- Moraš kupiti **GitHub Pro ($4/mesec)** ali **Data Pack ($5/mesec za 50GB)**

## Dolgoročna rešitev

Za prihodnost premislek:
- Odstrani PNG-je iz LFS (samo .dds datoteke ostanejo)
- Ali pa preseli asset-e na drugi strežnik (npr. AWS S3, Cloudflare R2)

## Kontakt

Če imaš še vedno težave, odpri issue na GitHubu:
https://github.com/markec12345678/stronghold2027/issues

Priloži output `bash scripts/check_lfs.sh`.
