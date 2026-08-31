---
title: 'Generation, rigging, and Godot integration digest'
type: 'technical'
updated: '2026-08-30'
---

# Scope

This digest records new online findings for a solo/non-artist 3D Godot pipeline. Hunyuan, Kenney, Mixamo, and the existing primitive prototype were treated as project baseline rather than new discoveries.

# Findings

## Tripo

- Tripo publishes an agent-oriented CLI for natural-language and image workflows, including generation, conversion, and animation operations. Its current generation documentation lists v3.1 as the latest model and exposes game-relevant controls such as face limits, automatic sizing, quad output, and smart low-poly settings.
- Its current rigging documentation is unusually relevant to a creature-heavy game: v2.5 supports biped, quadruped, hexapod, octopod, serpentine, aquatic, and avian rig families. The workflow is asynchronous and accepts GLB/GLTF/FBX/OBJ/STL inputs.
- The important limitation is quality, not feature presence. A generated creature still needs deformation, foot/wing/segment, material, and animation QA in the actual game camera.

## Rodin / Hyper3D

- Rodin Gen-2.5 is a strong static asset candidate: text/image-to-3D, multi-view inputs, GLB/FBX/OBJ/STL output, PBR options, quad/raw mesh modes, and multiple texture quality tiers.
- Hyper3D publishes a Godot add-on for Godot 4.4+ that can send generated assets into Godot through a browser bridge. This is a genuine convenience advantage for props and environment dressing.
- Current public documentation does not make Rodin a rigging solution. Use it for altars, weapons, fungus structures, rocks, props, and static set pieces.

## Meshy

- Meshy has current Meshy-7, Smart Topology, 8K texture, and Text-to-Motion announcements, plus an official Godot plug-in and DCC bridge.
- Its API rigging and animation documentation currently limits reliable rigging to standard textured humanoid/biped assets and explicitly rejects quadrupeds for the text-to-motion path. The web application documentation advertises humanoid/quadruped auto-rigging, so the web/API behavior is not aligned.
- Meshy is therefore a useful convenience layer for player prototypes and humanoid assets, but should not be the foundation for custom multi-limbed enemies until a test asset passes.

## Godot interchange

- Godot's current 4.x import guidance supports GLB/GLTF, FBX, OBJ, and other formats, but `.blend` import requires Blender to be installed because Godot routes it through Blender's glTF exporter.
- A GLB-first delivery convention minimizes tool coupling. Keep `.blend`, raw generated files, prompts, and source references outside `res://`; import only validated GLB/GLTF and animation libraries into the game.
- Godot's import dock, post-import scripts, animation-library workflow, LOD settings, and custom `GLTFDocument` extensions provide the right integration points for repeatable cleanup.

# Decision implication

For the first vertical slice, use Tripo as the first experiment for custom creature bodies, Rodin for static props, and Meshy only where its humanoid workflow is a measurable time saver. Make GLB the canonical hand-off format and retain Blender as the canonical cleanup/export DCC.

# Primary sources

- [Tripo CLI](https://developers.tripo3d.com/en/docs/cli)
- [Tripo text-to-model](https://developers.tripo3d.com/en/docs/generation-text-to-model/standard)
- [Tripo rig and animation](https://developers.tripo3d.com/en/docs/animations-rig)
- [Tripo pricing](https://developers.tripo3d.com/en/pricing)
- [Rodin Gen-2.5 API](https://docs.hyper3d.ai/en/api-specification/rodin-gen2-5)
- [Rodin Godot add-on](https://docs.hyper3d.ai/en/addons/godot-addon)
- [Meshy API](https://www.meshy.ai/api)
- [Meshy API rigging](https://docs.meshy.ai/en/api/rigging)
- [Meshy API animation](https://docs.meshy.ai/en/api/animation)
- [Meshy Godot plug-in](https://docs.meshy.ai/en/webapp/plugins/godot/introduction)
- [Godot 4.7 3D import pipeline](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/index.html)
- [Godot import configuration](https://docs.godotengine.org/en/latest/tutorials/assets_pipeline/importing_3d_scenes/import_configuration.html)
- [Godot Blender importer](https://docs.godotengine.org/en/stable/classes/class_editorsceneformatimporterblend.html)
