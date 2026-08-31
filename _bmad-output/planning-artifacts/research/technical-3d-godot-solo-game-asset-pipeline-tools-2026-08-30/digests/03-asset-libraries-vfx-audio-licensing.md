---
title: 'Asset libraries, VFX, audio, and licensing digest'
type: 'technical'
updated: '2026-08-30'
---

# Findings

## New asset libraries

- Quaternius currently offers CC0 humanoid bases, modular fantasy outfits, a large fantasy prop kit, and animated monster packs with FBX/glTF delivery and Godot-oriented implementations. These are especially useful for placeholder bodies and environmental dressing while custom hero creatures are being solved.
- KayKit Series 6 is a newer, Godot-compatible, low-poly character pack with rigged/textured/animated characters and CC0 terms. The complete bundle is a paid convenience purchase with current and future-pack coverage; it is not required for the first test.
- Poly Haven and ambientCG are strong material/HDRI sources because their license pages explicitly allow commercial use and redistribution under CC0. They are suitable for creating a coherent surface language around generated meshes.
- Fab is useful for paid hero assets, but every listing's license still needs checking. The Fab Standard License allows commercial distribution when assets are incorporated into a larger project, while standalone resale/redistribution is prohibited.

## VFX and audio

- Effekseer is a free cross-platform 2D/3D effect authoring tool with a Godot 4 plug-in. It is a reasonable way to author grapple sparks, cyan energy, impacts, and fungal bursts without a custom VFX artist; verify the plug-in against the exact Godot release before production lock.
- Material Maker and ArmorPaint cover the style layer that AI meshes cannot reliably provide: repeatable procedural materials, PBR paint, emissive masks, and baked maps.
- Sonniss's GDC 2026 bundle is a large current royalty-free sound source with commercial use, no attribution, and no AI-training permission. The audio must be incorporated into the game rather than redistributed as a standalone sound library.
- The GDQuest Godot VFX collection is useful for study and prototyping, but its art assets are CC-BY-NC-SA 4.0 even though its code is MIT. It is not a safe default for a commercial release.

## Terrain and scatter

- Terrain3D is a mature-looking MIT Godot 4 terrain extension with editing, LOD, holes, texture painting, foliage instancing, and heightmap import. Use it for broad terrain and background dressing only after testing it with the project's grapple collision and navigation assumptions.
- ProtonScatter provides non-destructive editor scattering. A newer Scatter plug-in targets Godot 4.7+ and native MultiMeshInstance3D, but its API is still changing. Use scattering for visual dressing, not for gameplay-critical anchor points.

## Licensing cautions

- Tripo's terms distinguish paid and free use in ways that make free outputs a poor commercial default; paid/private generation with a saved plan record is the conservative choice. The terms also disclaim uniqueness and place rights responsibility on the user.
- Meshy says free outputs are CC BY 4.0 with attribution and paid content can be private, but its current terms also permit non-enterprise inputs/outputs to be used to improve services unless otherwise agreed. Do not upload confidential unreleased concepts without checking the current agreement.
- Rodin's API retention policy says API payloads/outputs are deleted after seven days and are not used to train, while its broader terms reserve service-improvement rights. Treat the endpoint, plan, and current terms as a package rather than assuming all Rodin surfaces share the API policy.
- Marketplace and generated content rights must be recorded alongside the asset. A URL alone is not enough: retain the plan, license version/date, prompt/reference rights, and the exact source/output identifier.

# Decision implication

Use CC0 sources to establish the vertical slice's style and fill the world; reserve paid/generative hero assets for the few objects that need to carry the game's identity. Keep a per-asset rights ledger from the first import.

# Primary sources

- [Quaternius Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html)
- [Quaternius Modular Character Outfits](https://quaternius.com/packs/modularcharacteroutfitsfantasy.html)
- [Quaternius Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html)
- [Quaternius Animated Monster](https://quaternius.com/packs/animatedmonster.html)
- [KayKit Series 6](https://kaylousberg.itch.io/kaykit-series-6)
- [KayKit Complete](https://kaylousberg.itch.io/kaykit-complete)
- [Poly Haven license](https://polyhaven.com/license)
- [ambientCG license](https://docs.ambientcg.com/license/)
- [Fab EULA](https://www.fab.com/eula?lang=en)
- [Effekseer download](https://effekseer.github.io/en/download.html)
- [Sonniss GDC 2026 bundle](https://gdc.sonniss.com/)
- [Sonniss bundle license](https://sonniss.com/gdc-bundle-license/)
- [GDQuest Godot VFX assets](https://github.com/gdquest-demos/godot-4-VFX-assets)
- [Terrain3D](https://github.com/TokisanGames/Terrain3D)
- [ProtonScatter](https://github.com/HungryProton/scatter)
- [Scatter for Godot](https://github.com/xiaowangxu/godot-scatter-plugin)
