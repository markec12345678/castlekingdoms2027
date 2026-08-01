# Stronghold 2027

> Fork of [Stone Kingdoms](https://gitlab.com/stone-kingdoms/stone-kingdoms) — modernized edition targeting 2026-2027 release with HD graphics and improved gameplay.

[![Upstream](https://img.shields.io/badge/upstream-Stone%20Kingdoms-orange)](https://gitlab.com/stone-kingdoms/stone-kingdoms)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)
[![Status](https://img.shields.io/badge/status-pre--alpha-red)]()

---

## What is this?

**Stronghold 2027** is a fork of the open-source Stone Kingdoms project (an Apache 2.0 licensed remake of Firefly Studios' Stronghold 2001, developed with permission from Firefly Studios). Our goal is to modernize the game with:

- HD / 4K graphical assets (replacing original sprites)
- Modern UI/UX with cleaner visual design
- Performance optimizations for modern hardware
- Slovenian localization (in addition to existing languages)
- Bug fixes and gameplay improvements
- Optional new content (units, buildings, campaigns)

## Roadmap

- **Phase 1 (1-2 months):** Fork stabilization, dev environment setup, Slovenian localization
- **Phase 2 (2-4 months):** Bug fixes, performance optimizations
- **Phase 3 (4-8 months):** HD graphical asset replacement
- **Phase 4 (8-12 months):** New content and features
- **Phase 5 (12-14 months):** Beta, polish, release on Steam/GOG

## Prerequisites for development

1. Install [Git Large File Storage](https://git-lfs.github.com/)
2. Install LÖVE 11.4 from the [official website](https://love2d.org/)
3. Clone this repository: `git clone https://github.com/markec12345678/stronghold2027.git`
4. Run `git lfs install && git lfs pull` to fetch binary assets

## Run from source

1. Open terminal in the repository directory (where `main.lua` is located)
2. Run `love .` and play!

## How to contribute

This is a small-team fork. Two developers currently working on the project. To contribute:

1. Create an issue describing the change you want to make
2. Fork the repository, create a feature branch
3. Open a pull request with a clear description

## Upstream relationship

- **Upstream:** [gitlab.com/stone-kingdoms/stone-kingdoms](https://gitlab.com/stone-kingdoms/stone-kingdoms)
- **License:** Apache 2.0 (preserved from upstream)
- **Attribution:** All upstream contributors are acknowledged in `ATTRIBUTION.md`

To sync with upstream changes:
```bash
git fetch upstream
git merge upstream/main
```

## License

Apache 2.0 License — see [LICENSE](LICENSE) for details.

Original Stone Kingdoms uses image assets, property of Firefly Studios' Stronghold (2001), used with permission. This fork maintains the same permission scope.

Individual libraries in `/libraries` or root directory retain their original licenses — see respective files for details.
