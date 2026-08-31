---
title: 'Cleanup, animation, and local-tool digest'
type: 'technical'
updated: '2026-08-30'
---

# Findings

## Cleanup and canonical DCC

- Blender 4.5 LTS is the practical canonical DCC. It is supported through July 2027 and has broad GLB/GLTF, FBX, OBJ, USD, Alembic, PLY, and STL interoperability.
- Blender's native cleanup and baking tools cover loose geometry, duplicate vertices, degenerate faces, decimation, UV-dependent normal/AO/base-color baking, and export preparation.
- AutoRemesher is a current cross-platform automatic quad-remeshing project with Windows releases. The Blender bridge keeps the original object, runs the remesher, imports the result, and can attempt material-slot and UV transfer. The bridge is GPL-3.0-or-later while the upstream remesher is MIT, so this is a production tool, not an asset-license shortcut.
- MeshLab is a useful second opinion for inspection, repair, conversion, and triangle mesh cleanup when Blender's scene context is unnecessary.

## Animation

- Rokoko Create/Studio is the lowest-friction new motion option for the humanoid player: text/video-to-motion, FBX/BVH/CSV export, no capture hardware required, and a free Starter tier. Paid plans add custom character import, retargeting, and more AI seconds.
- Cascadeur is more useful than a generic mocap library for grapple and combat poses because it provides physics-assisted posing and correction. The current Indie plan includes common interchange formats and is aimed at projects below the stated revenue/funding threshold; Pro is the commercial/full-retargeting tier.
- AccuRIG is a free humanoid-oriented rig starter. It is appropriate for a player or ordinary humanoid NPC, not the game's unusual creature bodies.
- DeepMotion's free tier is personal/noncommercial; commercial use requires a paid plan. It is not the default recommendation for a commercial vertical slice.

## Local/open-source AI fit

- TRELLIS.2 is technically impressive but its official repository requires Linux and an NVIDIA GPU with at least 24 GB VRAM. It is not a sensible local path on the observed AMD RX 6800.
- Stability's Stable Fast 3D is a faster single-image prop reconstruction path, with roughly 6 GB default VRAM guidance and experimental Windows support. It produces mesh/material output, not a rigged creature. Its gated Community License has a revenue threshold for commercial use, so the license must be checked before shipping.
- TripoSR is MIT-licensed and lightweight by comparison, but it is also a static reconstruction tool rather than an animation solution.
- ArmorPaint and Material Maker are valuable local finishing tools: one for PBR paint/bake work and one for procedural materials. They reduce dependence on a hosted AI service even when the initial mesh comes from the cloud.

# Decision implication

Do not spend the first production cycle trying to force a local AI stack on the current AMD hardware. Spend that cycle validating GLB import, Blender cleanup, creature deformation, and humanoid motion. Add local reconstruction later for props if Stable Fast 3D or TripoSR passes a rights and quality test.

# Primary sources

- [Blender 4.5 LTS](https://www.blender.org/releases/4-5/)
- [Blender pipeline formats](https://www.blender.org/features/pipeline/)
- [Blender mesh cleanup](https://docs.blender.org/UATEST/manual/en/4.5/modeling/meshes/editing/mesh/cleanup.html)
- [Blender baking](https://docs.blender.org/manual/en/latest/render/cycles/baking.html)
- [AutoRemesher](https://github.com/huxingyi/autoremesher)
- [AutoRemesher Blender bridge](https://github.com/adriflex/autoremesher-blender-bridge)
- [MeshLab](https://www.meshlab.net/)
- [Rokoko Create](https://create.rokoko.com/)
- [Rokoko pricing](https://www.rokoko.com/pricing)
- [Cascadeur plans](https://cascadeur.com/plans)
- [AccuRIG](https://www.reallusion.com/auto-rig/accurig/default.html)
- [DeepMotion Animate 3D pricing](https://www.deepmotion.com/pricing-animate3d)
- [TRELLIS.2](https://github.com/microsoft/TRELLIS.2)
- [Stable Fast 3D](https://github.com/Stability-AI/stable-fast-3d)
- [Stable Fast 3D model license](https://huggingface.co/stabilityai/stable-fast-3d)
- [TripoSR](https://github.com/VAST-AI-Research/TripoSR)
- [ArmorPaint](https://armorpaint.org/)
- [ArmorPaint manual](https://armorpaint.org/manual)
- [Material Maker](https://www.materialmaker.org/)
