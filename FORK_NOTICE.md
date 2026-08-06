# Fork Notice

This repository is a **fork** of the [Stone Kingdoms](https://gitlab.com/stone-kingdoms/stone-kingdoms) project.

## Origin
- **Upstream repository:** https://gitlab.com/stone-kingdoms/stone-kingdoms
- **Upstream license:** Apache 2.0
- **Original authors:** Stone Kingdoms contributors (see `ATTRIBUTION.md`)
- **Fork date:** 2026-08-01

## Purpose of this fork
This fork targets a **2026-2027 release** of a modernized edition of the Stronghold-style castle RTS game, with focus on:

1. HD / 4K graphical assets
2. Modern UI/UX redesign
3. Performance optimizations
4. Slovenian localization
5. Bug fixes and gameplay improvements

## Maintaining sync with upstream
To pull in future changes from the upstream Stone Kingdoms project:

```bash
# Fetch latest upstream commits
git fetch upstream

# Inspect what changed
git log upstream/main --oneline -20

# Merge into our main branch
git merge upstream/main

# Resolve any conflicts (especially in README.md, .gitattributes)
```

## Differences from upstream
- Branch renamed: `master` → `main`
- Git LFS configured for `*.dds` files in history (to bypass GitHub 100MB limit)
- README.md replaced with fork-specific documentation
- This `FORK_NOTICE.md` file added

## Credits
All credit for the original game design, code architecture, and assets goes to the Stone Kingdoms team. This fork builds upon their work.

Original image assets are property of Firefly Studios, used with their permission under the terms specified by the Stone Kingdoms project.
