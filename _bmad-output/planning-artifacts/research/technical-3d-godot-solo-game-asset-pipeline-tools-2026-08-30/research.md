---
title: 'technical research: 3D Godot solo game asset pipeline tools and resources'
type: 'technical'
topic: '3D Godot solo game asset pipeline tools and resources'
decision: 'Choose a practical tool and asset stack for producing this game first 3D playable vertical slice without dedicated art staff'
source: 'online primary-source research'
status: complete
preset: 'standard'
validation: 'normal'
verification: '0 verified, 33 unverified, 1 disputed'
created: '2026-08-30'
updated: '2026-08-30'
---

# Executive summary

This is a fresh online tool/resource pass, current as of August 30, 2026. Hunyuan3D, Kenney, and Mixamo were previously treated as baseline context; they are now explicitly included as role-specific candidates, with cost and licensing marked alongside the newer options.

The strongest practical stack for the first 3D Godot slice is:

1. Blender 5.2.1 LTS as the canonical cleanup, material, rig-fix, and export tool for a new pipeline, with Blender 4.5.13 LTS retained as the compatibility fallback; MeshLab as a lightweight inspection/repair companion; AutoRemesher where generated topology is unusable. [39][40][41][43]
2. Tripo for custom creature generation and, importantly, its current non-humanoid rigging path. Its published v2.5 rig families cover quadrupeds, hexapods, octopods, serpentine, aquatic, and avian bodies. This is the best fit I found for enemies that do not behave like ordinary humanoids. [3]
3. Hunyuan3D-2.1 as the local, zero-subscription custom-mesh benchmark against Tripo. It can generate textured/PBR models, but the official path is CUDA-oriented, its documented VRAM requirements are significant, and it does not replace rigging or animation. [53][54]
4. Rodin Gen-2.5 for static props and environment pieces. Its official Godot bridge makes it unusually convenient for fast asset iteration, but the current public documentation does not make it a rigging solution. [6][7]
5. Meshy as an optional convenience tool for humanoids, Smart Topology, and fast one-click Godot import. Its API documentation is currently much less suitable for custom creatures than its web marketing suggests, so it should not own the creature pipeline. [10][11][12][13]
6. Mixamo as the first $0 humanoid auto-rig and motion-library baseline. It is valuable for the player and humanoid NPCs, but its official auto-rigger/library is biped-focused and is not a general creature solution. [56][57]
7. Rokoko Create/Studio for quick humanoid motion, and Cascadeur Indie for the few grapple/combat poses where visual quality matters more than raw clip volume. Use Tripo's non-humanoid retarget path or Blender/manual cleanup for creature rigs. [58][59][60]
8. Kenney, Quaternius, and KayKit for free/CC0 character, prop, world, and monster stand-ins; Poly Haven and ambientCG for CC0 surfaces and HDRIs; Fab only for deliberately selected paid hero assets. [55]
9. Material Maker or ArmorPaint for a coherent surface language, Effekseer for authored 2D/3D effects, and Sonniss for commercial-ready sound coverage.

The important architectural choice is GLB-first. Treat generated meshes, `.blend` sources, prompts, and raw textures as source material. Deliver only validated GLB/GLTF and animation libraries to Godot. Godot can import `.blend`, but that path requires a Blender installation and introduces avoidable DCC coupling. [15]

# What was researched and what was not

The research question was: which current tools and resources can reduce the art bottleneck for a solo developer building a stylized 3D Godot game with custom creatures, traversal/combat animation, environmental dressing, VFX, and sound?

I checked official product documentation, release notes, API references, repositories, pricing pages, license terms, and Godot integration documentation. The evaluation dimensions were:

- fit for non-artist production rather than demo-only generation;
- creature versus humanoid rigging capability;
- Godot/GLB/FBX interoperability;
- cleanup, retopology, UV, materials, and animation hand-off;
- hardware and platform requirements;
- commercial rights, privacy, retention, and redistribution restrictions;
- current price and likely iteration cost;
- failure modes that could block the first vertical slice.

Hunyuan3D, Kenney, and Mixamo are included in this refresh because they answer three different bottlenecks: custom model generation, free asset coverage, and humanoid animation. They are not interchangeable, so the comparison keeps each one in the running only for the role its current evidence supports.

# Decision matrix

| Tool/resource | Best role in this game | Recommendation | Main caveat |
|---|---|---|---|
| [Tripo](https://developers.tripo3d.com/en/docs/animations-rig) | Custom creatures, creature auto-rig, model automation | Test first for Rootstalker-like enemies and the boss | Rigging quality still requires Blender/game-camera QA; use paid/private generation for commercial work |
| [Hunyuan3D-2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) | Local image/text-to-3D and PBR custom-mesh benchmark | Keep in the running as the $0-software alternative to hosted model generation | Official tested setup is CUDA/NVIDIA-oriented; no documented rigging/animation workflow; Community License needs a shipping review |
| [Kenney](https://kenney.nl/) | Free props, world/UI coverage, and placeholder style tests | Keep in the running as the $0 coverage baseline; use individual packs before considering the paid convenience bundle | CC0 does not provide custom creature generation or a general creature-animation library; style may need a unifying pass |
| [Mixamo](https://www.mixamo.com/) | Free humanoid auto-rig and motion library | Keep in the running as the first player/humanoid-NPC animation baseline | Official auto-rigger and library are biped-focused; extra limbs, wings, and tails may fail; recheck older terms before release |
| [Rodin Gen-2.5](https://docs.hyper3d.ai/en/api-specification/rodin-gen2-5) | Static props, altars, weapons, fungal structures, environment variants | Test first for non-animated set dressing | Current docs do not establish a creature-rig workflow |
| [Meshy](https://docs.meshy.ai/en/api/rigging) | Humanoids, fast remesh/texture, one-click Godot bridge | Optional convenience layer | API docs reject quadrupeds for animation; web UI and API claims diverge |
| [Blender 5.2.1 LTS](https://www.blender.org/releases/5-2/) | Canonical DCC, cleanup, UVs, materials, rig fixes, export | Adopt as the pipeline anchor for a new stack; keep 4.5.13 if an existing add-on pipeline depends on it | Requires learning a small repeatable subset; `.blend` import into Godot requires Blender installed |
| [AutoRemesher](https://github.com/huxingyi/autoremesher) + [Blender bridge](https://github.com/adriflex/autoremesher-blender-bridge) | Automated quad topology pass | Add as an optional batch step | UV/material transfer is best-effort; bridge and upstream have different licenses |
| [Rokoko](https://create.rokoko.com/) | Humanoid text/video-to-motion and retargeting | Use for player/NPC motion experiments | Mostly humanoid; plan limits and commercial terms need recording |
| [Cascadeur](https://cascadeur.com/plans) | Grapple, combat, contact, and physics-assisted pose correction | Strong optional purchase after a playable rig exists | Cost and learning time are not justified before the first rig test |
| [Quaternius](https://quaternius.com/packs/universalbasecharacters.html) | CC0 humanoid/prop/monster placeholders | Use immediately for slice scaffolding | Style consistency still needs a color/material pass |
| [KayKit Series 6](https://kaylousberg.itch.io/kaykit-series-6) | CC0 rigged/animated character placeholders | Consider if Quaternius silhouettes do not fit | Paid pack; do not resell assets unmodified |
| [Poly Haven](https://polyhaven.com/license) + [ambientCG](https://docs.ambientcg.com/license/) | CC0 textures, materials, HDRIs | Use for environment surface coverage | Raw photoreal sources need stylization to match the game |
| [Material Maker](https://www.materialmaker.org/) + [ArmorPaint](https://armorpaint.org/) | Procedural materials, PBR paint, emissive masks | Use to unify generated/library assets | Validate GPU behavior on the AMD machine before building the whole material workflow |
| [Effekseer](https://effekseer.github.io/en/download.html) | Grapple sparks, impact bursts, cyan energy, fungal VFX | Prototype with it or native Godot particles | Confirm plug-in compatibility with the exact Godot release |
| [Sonniss GDC 2026 bundle](https://gdc.sonniss.com/) | Sound effects and ambience | Use for broad sound coverage | Audio must be incorporated into the game, not redistributed standalone |
| [Terrain3D](https://github.com/TokisanGames/Terrain3D) + [ProtonScatter](https://github.com/HungryProton/scatter) | Broad terrain and visual dressing | Optional after grapple/nav tests | Do not place gameplay-critical grapple anchors on unvalidated generated/scattered geometry |
| [Stable Fast 3D](https://github.com/Stability-AI/stable-fast-3d) | Local single-image static props | Secondary experiment only | Windows support is experimental and the model license has commercial thresholds |
| [TRELLIS.2](https://github.com/microsoft/TRELLIS.2) | High-fidelity local image-to-3D research | Do not prioritize locally | Official path requires Linux and NVIDIA GPU with at least 24 GB VRAM; poor fit for the current AMD RX 6800 |

# Findings by production stage

## 1. Model generation: separate creatures from props

### Tripo is the most relevant new creature option

Tripo's current developer surface is unusually suited to an AI-assisted pipeline: its CLI is explicitly designed for use by AI agents and coding tools, while its API exposes generation, conversion, low-poly, quad, texture, and animation operations. The current standard text-to-model documentation identifies `v3.1-20260211` as the latest model and lists game-relevant face-limit guidance. Its smart low-poly mode exposes bounded triangle or quad budgets, which is more useful for a game pipeline than a beautiful but unbounded preview mesh. See the [CLI documentation](https://developers.tripo3d.com/en/docs/cli) [1], [generation documentation](https://developers.tripo3d.com/en/docs/generation-text-to-model/standard) [2], and [pricing](https://developers.tripo3d.com/en/pricing) [4].

The decisive discovery is the current [rig and animation documentation](https://developers.tripo3d.com/en/docs/animations-rig) [3]. Tripo's v2.5 rig path lists biped, quadruped, hexapod, octopod, serpentine, aquatic, and avian types. That maps much better to a game with Rootstalker-, Spore Kite-, or other custom-body silhouettes than a humanoid-only service. The workflow still needs a rig-check, deformation review, foot/wing/segment contact tests, and manual fallback planning. “The service accepts this body plan” is not the same as “the resulting rig is production-ready.”

Tripo's pricing is usage-based: one credit is listed as $0.01; standard text-to-3D with texture is listed at 20 credits, and auto-rig at 25 credits, before any further retopology, texture, or retry costs. That makes targeted experiments inexpensive, but repeated failed generations can still become a meaningful budget. [Pricing details](https://developers.tripo3d.com/en/pricing) [4].

Tripo also belongs in the animation comparison, not only the model/rig comparison. Its current [Animation Retarget documentation](https://developers.tripo3d.com/en/models/animation) describes applying preset motions to a rigged model, with more than 100 presets overall and a smaller universal set for non-humanoid v2.5 rigs. The API pricing page lists Animation Retarget at 10 credits per animation, so the current planning price is about $0.10 per retargeted clip before retries. This makes Tripo a plausible creature-animation bootstrap, but not proof of bespoke combat quality: test idle, locomotion, attack, and contact/deformation in Blender and Godot. [58][59][60]

### Hunyuan3D stays in the custom-model comparison

[Hunyuan3D-2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) is worth keeping as the local, zero-subscription benchmark against hosted generation. Its official repository describes an open framework with model weights/training code and PBR texture synthesis, and the README gives roughly 10 GB VRAM for shape generation, 21 GB for texture generation, or 29 GB combined. The documented installation/test path is CUDA/PyTorch-oriented even though the project lists Windows support, so the current AMD RX 6800 should be treated as a compatibility experiment or cloud option rather than an assumed local solution. The repository documents generation and texture synthesis, not automatic rigging or animation, so Hunyuan does not replace Tripo/Blender for the creature pipeline. [53]

Hunyuan's “free/open” status also needs a stronger qualification than CC0. The official [Community License](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1/blob/main/LICENSE) includes territory, large-service/MAU, downstream-notice, acceptable-use, and AI/ML restrictions. Treat the weights, code, and outputs as a candidate pending a project-specific license review; record the exact repository commit, model-weight version, environment, and license file with any accepted asset. [54]

### Rodin is better positioned for static worldbuilding

[Rodin Gen-2.5](https://docs.hyper3d.ai/en/api-specification/rodin-gen2-5) [6] supports text/image-to-3D, up to five images, GLB/FBX/OBJ/STL output, PBR modes, raw/quad mesh modes, and multiple texture-quality options. For this game, the high-value use is fast variation of altars, industrial/fungal structures, traversal anchors, weapons, rocks, and room dressing—not an attempt to generate a final animated hero.

The [official Godot add-on](https://docs.hyper3d.ai/en/addons/godot-addon) [7] supports Godot 4.4+ and sends generated assets into Godot through a browser bridge. This makes Rodin a strong iteration tool for static assets, provided the imported mesh is still normalized, collision-authored, and performance-checked locally.

### Meshy is convenient but has a creature-specific red flag

Meshy's current product surface is moving quickly: official changelogs list Meshy-7, Smart Topology, 8K base-color textures, and Text-to-Motion [10]. It also has an [official Godot plug-in](https://docs.meshy.ai/en/webapp/plugins/godot/introduction) [16] and a bridge that can download/import models from the Meshy workspace.

However, the current [API rigging documentation](https://docs.meshy.ai/en/api/rigging) [11] says the rigging path works well with standard textured humanoid/biped assets and is unsuitable for unclear or non-humanoid structures. The [API animation documentation](https://docs.meshy.ai/en/api/animation) [12] says quadrupeds are rejected for the text-to-motion path, while the [web animation guide](https://docs.meshy.ai/en/webapp/guides/animate) [13] advertises humanoid/quadruped auto-rigging. This is an important product-surface conflict. Meshy remains attractive for humanoid prototypes and fast asset import, but it should not be selected as the core creature solution until a real quadruped or multi-limb test passes.

## 2. Cleanup and export: Blender is still the control point

[Blender 5.2.1 LTS](https://www.blender.org/releases/5-2/) [39] is the best neutral control point for a new generated/marketplace asset pipeline, with support listed through July 2028. Blender 4.5.13 LTS remains a valid fallback through July 2027 if a plug-in or existing source library has already been validated on that line. Blender's [pipeline documentation](https://www.blender.org/features/pipeline/) covers the formats needed here. Its native mesh cleanup tools handle loose geometry, duplicate vertices, degenerate faces, decimation, and related repair operations; its [baking workflow](https://docs.blender.org/manual/en/latest/render/cycles/baking.html) can produce normal, AO, base-color, and other maps once UVs exist.

For a non-artist, [AutoRemesher](https://github.com/huxingyi/autoremesher) is worth testing because it has Windows releases and focuses on automatic quad remeshing. The [Blender bridge](https://github.com/adriflex/autoremesher-blender-bridge) [17] preserves the original object, runs the remesh, imports the result, and attempts to transfer material slots and UVs. Keep the original and compare the output: automatic remeshing can improve deformation topology while also damaging silhouette-critical details or UV quality. [MeshLab](https://www.meshlab.net/) [18] is a useful inspection/repair fallback when a mesh needs a quick standalone check.

Use GLB as the canonical game hand-off. Godot's [3D import pipeline](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/index.html) and [import configuration guidance](https://docs.godotengine.org/en/latest/tutorials/assets_pipeline/importing_3d_scenes/import_configuration.html) provide the relevant controls. The [Blender importer documentation](https://docs.godotengine.org/en/stable/classes/class_editorsceneformatimporterblend.html) confirms that `.blend` import depends on Blender 3.0+ being installed, so `.blend` should remain source, not the production interchange contract. Separate animation libraries are preferable when multiple characters share clips or when animation needs to be revised independently. [15]

## 3. Animation: one path for humanoids, another for creatures

For the player and ordinary humanoid NPCs, [Rokoko Create](https://create.rokoko.com/) [19] offers text/video-to-motion and export to FBX/BVH/CSV without requiring capture hardware. The [current pricing page](https://www.rokoko.com/pricing) lists a free Starter tier and paid tiers that add custom character import, retargeting, and additional AI usage. It is a fast way to get locomotion and rough combat motion into a humanoid rig, not a solution for arbitrary creature anatomy.

[Cascadeur](https://cascadeur.com/plans) [20] is a better targeted tool for grapple and combat polish. Its value is physics-assisted posing and correction: contacts, swings, arcs, and weight transfer can be tuned instead of accepting a generic motion clip. The current Indie plan lists FBX/DAE/USD/GLTF export and a stated revenue/funding threshold; the Pro plan is the safer full-commercial/retargeting tier. Buy it only after a first rig and basic motion import work, because the cost is wasted if the creature/player skeleton is not yet stable.

[AccuRIG](https://www.reallusion.com/auto-rig/accurig/default.html) and [DeepMotion](https://www.deepmotion.com/pricing-animate3d) [21] are useful to know about: AccuRIG is a free humanoid rig starter, while DeepMotion's free tier is personal/noncommercial and commercial use needs a paid plan. Neither should be assumed to solve the game's custom-body enemies.

### Mixamo remains the free humanoid baseline

[Mixamo](https://www.mixamo.com/) stays in the running for the player and humanoid NPCs. Adobe's official FAQ says the service is free with an Adobe ID and does not require a Creative Cloud subscription, and describes the characters and animations as royalty-free for personal, commercial, and non-profit use, including video games. The same FAQ describes the auto-rigger and animation library as humanoid/biped-focused: the mesh needs a recognizable head, body, arms, and legs, while extra limbs, wings, or tails may make the process fail. That makes Mixamo the first $0 motion baseline for a conventional humanoid, not a general quadruped/avian/segmented-creature solution. [56]

The FAQ is an older official page, so its rights language should be rechecked before release. Adobe's additional Mixamo terms also prohibit using Mixamo services, content, data, or output to directly or indirectly create, train, test, or improve ML/AI systems. For this project, download accepted FBX/animation files locally, keep the character/clip names in the asset ledger, and do not treat Mixamo as a source for training a custom motion model. [57]

For non-humanoids, the recommended sequence is Tripo rig check → Blender deformation test → a small set of manually corrected actions. If a generated rig cannot pass a walk/attack/contact test, fall back to a segmented or procedural creature animation rather than letting an AI rig block the game architecture.

## 4. Local and open-source tools: use them where they fit the machine

The current machine context includes an AMD RX 6800. That changes the recommendation. Microsoft's [TRELLIS.2](https://github.com/microsoft/TRELLIS.2) [22] is a strong research option, but the official repository documents a Linux path and NVIDIA GPU requirement of at least 24 GB VRAM. It is not a sensible local-first investment here.

[Stable Fast 3D](https://github.com/Stability-AI/stable-fast-3d) [23] is more plausible for occasional static props: the project documents roughly 6 GB default VRAM and experimental Windows support. It does not provide creature rigging or animation, and the [gated model license](https://huggingface.co/stabilityai/stable-fast-3d) [24] has a commercial revenue threshold. [TripoSR](https://github.com/VAST-AI-Research/TripoSR) [25] is MIT-licensed and lightweight by comparison, but similarly static.

[ArmorPaint](https://armorpaint.org/) and [Material Maker](https://www.materialmaker.org/) [26] can keep PBR painting and procedural materials local and repeatable. Both are more reliable ways to own the final style language than repeatedly prompting each asset to look consistent. Test Vulkan/GPU behavior before committing to either as the only material authoring tool.

## 5. Libraries: use CC0 coverage to buy time

[Quaternius Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) provides CC0 humanoid bases with animation-friendly topology, rigging, FBX/glTF delivery, and Godot-oriented examples. Its [modular fantasy outfits](https://quaternius.com/packs/modularcharacteroutfitsfantasy.html) extend that into customizable player/NPC silhouettes. Its [Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html) and [Animated Monster](https://quaternius.com/packs/animatedmonster.html) pages provide useful CC0 environmental and creature stand-ins. [27]

[KayKit Series 6](https://kaylousberg.itch.io/kaykit-series-6) is another new option for low-poly rigged/textured/animated characters and is explicitly Godot-compatible. Its CC0 terms make it suitable for commercial use without attribution, while the [complete bundle](https://kaylousberg.itch.io/kaykit-complete) is a paid convenience purchase rather than a requirement. [28] The practical use of both libraries is to make the vertical slice playable while only the identity-carrying hero creature assets receive custom generation and cleanup.

### Kenney stays in the free asset-library comparison

[Kenney](https://kenney.nl/) remains a strong $0 coverage baseline for props, environment dressing, UI, and placeholder characters/creatures. The current official asset page offers individual assets under [CC0](https://kenney.itch.io/kenney-game-assets), with unlimited commercial-project use and no attribution required; it also lists game-friendly formats including OBJ, FBX, GLTF, PNG, SVG, and OGG. The All-in-1 download is an optional paid convenience bundle, currently listed at $19.95 or more, rather than a requirement for using the free library. [55]

Kenney is not a custom creature generator, rigging service, or general creature-animation source. Keep it in the running for rapid level dressing, UI, placeholder enemies, and a consistent low-poly style test; use a material/color pass if its friendly aesthetic needs to be brought closer to the game's darker target. For animated creatures, prefer a pack that explicitly includes rigs/clips, or use Kenney only as the visual placeholder while Tripo/Blender/hand-authored animation handles the final creature.

For surfaces and HDRIs, [Poly Haven's license](https://polyhaven.com/license) [29] and [ambientCG's license](https://docs.ambientcg.com/license/) [30] both provide unusually clear CC0 commercial terms. [Fab's EULA](https://www.fab.com/eula?lang=en) [31] supports commercial use of incorporated assets under its Standard License, but individual listings can have other licenses and standalone resale is prohibited. Use Fab after the style gate, not as an unfiltered asset dump.

## 6. VFX, material language, and audio

[Effekseer](https://effekseer.github.io/en/download.html) [32][42] is a current free 2D/3D effect authoring tool with a Godot 4 plug-in. The checked Windows release is 1.80.7. It is a good fit for hand-authored grapple sparks, cyan energy trails, impact flashes, fungal bursts, and boss telegraphs; verify the plug-in against the exact Godot version before locking the dependency.

[Sonniss's GDC 2026 bundle](https://gdc.sonniss.com/) [33] is a current high-volume source for sound effects and ambience. Its [license](https://sonniss.com/gdc-bundle-license/) permits worldwide royalty-free personal/commercial use, unlimited projects, and no attribution, while prohibiting standalone redistribution and AI training. This is a useful way to avoid spending the first slice's time on sound sourcing.

The [GDQuest Godot VFX collection](https://github.com/gdquest-demos/godot-4-VFX-assets) [34] is useful for study and prototyping, but its art files are CC-BY-NC-SA 4.0. Do not assume the MIT code license covers the included textures/models.

## 7. Terrain and dressing

[Terrain3D](https://github.com/TokisanGames/Terrain3D) [35][49] is an MIT Godot 4 terrain extension with editing, LOD, holes, texture painting, foliage instancing, and heightmap import. The current v1.0.2 release notes document support for Godot 4.4–4.6+, not a confirmed Godot 4.7 target. It may help with broad terrain slabs, but the game has grapple traversal and navigation concerns: test collision, grapple targeting, and navmesh behavior before using it for any route-critical surface.

[ProtonScatter](https://github.com/HungryProton/scatter) [36][50] is a useful non-destructive scatter tool for fungal dressing and foliage, but its 4.0 release notes describe Godot 4.0–4.2 compatibility at the time of writing. The newer [Scatter plug-in](https://github.com/xiaowangxu/godot-scatter-plugin) [37] targets Godot 4.7+ and native `MultiMeshInstance3D`, but its API is still changing. Use scatter for presentation; author grapple anchors and traversal surfaces explicitly.

# Cross-dimension insights

## The bottleneck is consistency, not the ability to make one attractive mesh

Generation services can produce a promising isolated asset, but a playable game needs consistent scale, topology, materials, skeleton conventions, animation names, collisions, and licensing records across dozens of assets. That is why the recommended stack pairs a generator with Blender, a style layer, and CC0 coverage instead of adding more generators. Hunyuan3D, Kenney, and Mixamo stay in the running because they cover different jobs rather than duplicating Tripo: local/custom mesh generation, free content coverage, and humanoid motion. This is a synthesis from the generation, interchange, and asset-license evidence; the exact time saved is unverified until the slice test is run.

## The creature rig is the highest-risk dependency

Tripo is the only researched service whose current public rig documentation explicitly covers the major non-humanoid families relevant to this project, and its current animation docs add preset retargeting for rigged models [3][58][59]. Mixamo is a useful free counterpoint for humanoid player/NPC motion, but its documented biped focus does not cover the game's arbitrary creatures [56]. Hunyuan3D documents model/texture generation rather than rigging or animation, while Kenney is a premade asset library rather than a creature-animation system [53][55]. Meshy's current web/API disagreement makes it a poor architectural dependency for custom enemies [11][12][13]. The first creature test should therefore happen before a large environment-art purchase or a custom animation library is built.

## Godot bridges are useful, but a file contract is more durable

Rodin and Meshy both advertise direct Godot paths [7][16], but the project still needs deterministic source retention, import settings, version control, and recovery when a hosted service changes. GLB/GLTF as the runtime contract, with Blender sources retained separately, is the most portable choice [15].

## Free and open-source does not mean universally shippable

CC0 libraries are the safest way to establish coverage [27][28][29][30][55]. By contrast, Hunyuan3D uses a Community License with additional territory, service-size, downstream, and AI/ML conditions [54]; Stable Fast 3D has a gated license [24]; GDQuest's sample art is noncommercial [34]; and hosted generators have different privacy/data-use terms [5][8][14]. License evidence is therefore a production input, not a legal footnote.

# Contrary evidence and unresolved vendor claims

- Tripo's non-humanoid rig families are a capability claim, not a quality guarantee. I found no independent benchmark proving that a generated quadruped, avian, or serpentine rig will deform acceptably for this game's combat and grapple contacts. Treat the claim as **unverified** until the acceptance pack passes.
- Meshy's official surfaces disagree about quadruped support: the web guide advertises it, while the API rigging/animation documentation narrows or rejects it [11][12][13]. This is recorded as **disputed**, not averaged into a positive recommendation.
- Rodin's API retention policy says API payloads and outputs are deleted after seven days and not used to train, but the broader service terms still govern other workflows [8][9]. The safe conclusion is endpoint-specific, not “all Rodin content is private.”
- AI model output rights remain subject to the service terms and the rights to any reference image. Tripo disclaims uniqueness [5]; Meshy's terms and pricing surface distinguish free/paid treatment [14]; a generator's promise cannot clear a third-party concept image.
- The current local-AI recommendation is constrained by hardware rather than model quality. TRELLIS.2 may be excellent on its supported stack, but its documented Linux/NVIDIA/VRAM requirements make it a poor local choice for the current AMD machine [22].
- Hunyuan3D is promising as a free local model-generation benchmark, but its official examples are CUDA/PyTorch-oriented and its license is not an unqualified permissive/CC0 license. It remains a candidate, not a locked dependency, until the current machine and intended commercial use are tested [53][54].
- Mixamo's free/commercial-use evidence comes from an older official FAQ and older additional terms. Keep it in the running for humanoid experiments, but save local outputs and recheck the terms before release [56][57].

# Recommendations and downstream bindings

| Recommendation | Immediate downstream artifact | Confidence basis |
|---|---|---|
| Adopt GLB-first import, with Blender 5.2.1 LTS as the canonical cleanup/export stage for a new pipeline | Godot import conventions, asset folder rules, and the first import test | Medium: supported by official Godot and Blender documentation [15][39] |
| Run one Tripo non-humanoid creature experiment before buying a broad asset subscription | A creature test story and the vertical-slice risk register | Medium for feature availability, low for final deformation quality [3] |
| Keep Hunyuan3D in the custom-model bake-off, but not as the rig/animation owner | A local-vs-hosted generation comparison with hardware and license notes | Medium for documented generation/PBR capability; low for current AMD compatibility and shippability [53][54] |
| Use Rodin for static set dressing and Meshy only for humanoid convenience | Art-production checklist and prop/player asset backlog | Medium for current feature/integration pages; Meshy creature support is disputed [6][7][11][12][13] |
| Keep Kenney alongside Quaternius/KayKit for $0 slice coverage and style exploration | Art direction/style gate and placeholder asset manifest | Medium: Kenney's CC0 terms are clear, but visual consistency and animation coverage are project-level judgments [27][28][29][30][55] |
| Test Mixamo before paid humanoid motion tiers | Player/NPC animation bake-off and local clip manifest | Medium for the older official free/commercial-use evidence; low for non-humanoid coverage [56][57] |
| Defer Cascadeur and paid motion tiers until a real player rig and grapple action exist | Animation-polish story, not a prerequisite for gameplay architecture | Medium for exports/features; value is an inference that needs an in-game comparison [19][20] |
| Do not prioritize local TRELLIS.2 or a hardware purchase on the current machine | Technical-debt note and tool budget | High for documented hardware mismatch; model-quality comparison remains untested [22] |

# Licensing, privacy, and cost reality

The new tool list is only useful if its outputs can ship. The following are the conservative decisions from the current official pages:

| Source | Current evidence | Safe working rule |
|---|---|---|
| Tripo | The current [Studio pricing page](https://www.tripo3d.ai/pricing) lists Free as public/noncommercial and Pro as private/commercial; a separate [production page](https://www.tripo3d.ai/media-production/generate-film-ready-3d-assets) shows a different Free credit figure | Use Free for look-development only; use a paid/private plan or separately verified API terms for commercial hero assets, retain plan evidence, and do not assume uniqueness |
| Meshy | Current [pricing docs](https://docs.meshy.ai/en/webapp/pricing) list 100 free credits/month with CC BY 4.0 attribution and a Pro tier with private/full-commercial treatment; the [terms](https://www.meshy.ai/terms-of-use) still govern data use | Free can be shipped only with deliberate attribution/license acceptance; paid is cleaner for hero assets; do not upload confidential concepts without checking the current agreement |
| Rodin | Current [pricing](https://hyper3d.ai/pricing?lang=en) separates a limited Free tier from Creator's unlimited-export/any-use terms. The [API retention policy](https://docs.hyper3d.ai/en/legal/data-retention-policy) says API payloads/outputs are deleted after seven days and are not used to train; broader [terms](https://hyper3d.ai/legal/terms) still govern the service | Use Free for previews/exploration; record the exact endpoint/plan and current terms before shipping; do not generalize API privacy or Creator rights to every web workflow |
| Hunyuan3D-2.1 | Official code/weights are available, but the [Community License](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1/blob/main/LICENSE) includes territory, large-service/MAU, downstream-notice, acceptable-use, and AI/ML restrictions | Keep it as a free local benchmark only after checking the license against the intended release territory, audience scale, and workflow; retain the exact repository/model snapshot |
| Kenney | Individual assets on the [official asset page](https://kenney.itch.io/kenney-game-assets) are CC0, with unlimited commercial use and no attribution; the All-in-1 download is an optional paid convenience bundle | Use individual packs freely for incorporated game content; preserve the source/license snapshot and do not treat the $19.95 bundle as a required cost |
| Mixamo | Adobe's [official FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html) describes free Adobe-ID access and royalty-free commercial game use; [additional terms](https://wwwimages2.adobe.com/content/dam/cc/en/legal/servicetou/Mixamo-Addl-Terms-en_US-20210623.pdf) restrict AI/ML training use | Keep downloaded humanoid outputs with a local manifest; recheck the older official rights language before release and do not use Mixamo output to train/improve an AI system |
| Stable Fast 3D | [Model card](https://huggingface.co/stabilityai/stable-fast-3d) uses a gated Community License with a commercial revenue threshold | Avoid for a commercial project unless the project qualifies or an enterprise license is obtained |
| Quaternius/KayKit | Published CC0 pages | Keep the source page/license snapshot; do not resell raw packs as a standalone product |
| Poly Haven/ambientCG | Published CC0 pages | Safe for incorporated commercial materials; preserve source URLs in the asset ledger |
| Fab | [Fab Standard License](https://www.fab.com/eula?lang=en) allows incorporated commercial distribution, not standalone redistribution | Check each listing before import and retain the listing/license version |
| Sonniss | [GDC bundle license](https://sonniss.com/gdc-bundle-license/) allows commercial use with no attribution, prohibits standalone redistribution and AI training | Use only as synchronized/incorporated game audio |

Listed prices are a planning snapshot checked on August 30, 2026, not a promise. Hunyuan3D has no hosted subscription in the checked open repository, but local use shifts cost to compatible hardware/electricity or cloud compute [53]. Kenney's individual assets are $0 under CC0; its All-in-1 download is an optional $19.95-or-more convenience bundle [55]. Mixamo is described by Adobe as free with an Adobe ID and no Creative Cloud subscription [56]. Tripo API lists $0.01 per credit, including 10 credits for an animation retarget and itemized generation/rigging costs [51][60]; Tripo Studio Pro lists $20/month billed annually ($240/year) [45]. Meshy lists Free at 100 credits/month and Pro at $20/month or $240/year [46]. Rokoko lists a free Starter tier and Basic at $10/month billed annually or $12 month-to-month [47]. Cascadeur lists Free, Indie at $19/month or $8/month billed annually, and Pro at $49/month or $33/month billed annually [48]. Re-check pricing, terms, and rights immediately before purchase or release.

# Free-first budget and version-freeze plan

The research now includes costs as a first-class decision variable. For a solo developer, the sensible target is a **$0 baseline** until the first playable slice proves that a paid service removes a real bottleneck. Free tiers are not interchangeable with free/open-source tools: some are genuinely shippable with conditions, while others are previews, noncommercial trials, or public-only outputs.

## What can stay at $0

| Need | Free-first choice | Important condition |
|---|---|---|
| Engine and export | Godot `4.7.2-stable` plus matching export templates [38] | Freeze the exact editor/template build; do not track “4.7” loosely |
| DCC and canonical export | Blender `5.2.1 LTS` for a new pipeline, or `4.5.13 LTS` if the existing add-on/source stack is already validated [39] | Pick one Blender line for the slice; do not mix `.blend` saves across major lines casually |
| Cleanup, materials, VFX | Material Maker `1.7`, MeshLab `MeshLab-2025.07`, AutoRemesher `1.2.0` plus bridge `v0.1.3`, and Effekseer `1.80.7` [40][41][42][43] | Keep the exact releases/installers locally; check each plug-in against the pinned Godot build |
| Local custom-mesh experiment | Hunyuan3D-2.1, if the CUDA/PyTorch path is compatible with the machine or a bounded cloud instance is available [53] | $0 software does not mean $0 compute; freeze the repo/weights/environment and review the Community License before accepting outputs |
| Placeholder characters, props, materials, HDRIs | Kenney, Quaternius, KayKit free packs, Poly Haven, and ambientCG [27][28][29][30][55] | Kenney individual assets are CC0; keep the source/license snapshot and do not resell raw packs |
| Prototype audio | Sonniss GDC bundle [33] | Incorporate sounds into the game; do not redistribute the source library standalone |
| Humanoid motion experiments | Mixamo, Rokoko Starter, AccuRIG, Blender/manual animation [21][47][56][57] | Mixamo is the first $0 humanoid baseline; download clips locally and recheck the older terms before release |
| Terrain and dressing | Native Godot tools first; Terrain3D/Scatter only after a Godot 4.7 compatibility spike [49][50] | Keep traversal-critical geometry and grapple anchors explicitly authored |

This stack is sufficient to prove import, scale, materials, one humanoid, one creature placeholder, animation hand-off, VFX, audio, collision, and camera readability without a recurring subscription. Hunyuan3D is optional in that $0 baseline because its compute and hardware path may not be $0 on the current machine.

## Free tiers that need a rights or export decision

| Service | Current free tier | Paid trigger |
|---|---|---|
| Tripo Studio | The current pricing page lists 200 monthly credits, public models, noncommercial use, and limited exports. A separate Tripo production page currently shows 300 free credits, so the exact allowance is a vendor-page discrepancy [45][52]. | Use Free for previews/look-development only. Studio Pro lists $20/month billed annually ($240/year), 3,000 credits, private models, commercial use, and the DCC bridge [45]. |
| Rodin/Hyper3D | Free generation/exploration, legacy-model exports, 10 private assets, public-gallery and pay-by-result behavior; the page does not give the same unlimited-export/any-use promise as Creator [44]. | Creator lists $30/month or $24/month billed annually, with unlimited export/any use and private assets [44]. |
| Meshy | Free lists 100 credits/month, no card required, and CC BY 4.0 output that can be used commercially with attribution [46]. | Pro lists $20/month or $240/year, 1,000 credits/month, private output, and full commercial use [46]. |
| Cascadeur | Free forever, but noncommercial and CASC-only export [48]. | Indie lists $19/month or $8/month billed annually, export formats, and a stated revenue/funding limit below $100,000/year; Pro lists $49/month or $33/month billed annually with unrestricted commercial use [48]. |

The conservative rule is simple: do not put Tripo Free or Rodin Free output in a commercial build without a current, asset-specific rights check. Meshy Free is the exception only when CC BY 4.0 attribution and the current terms are acceptable. Cascadeur Free is for learning/noncommercial work unless the project qualifies for a paid commercial tier.

## Small, deliberate paid spend

| If the bottleneck is… | First paid experiment | Cost evidence and stop rule |
|---|---|---|
| A final custom creature | Tripo Studio Pro or Tripo API | Studio Pro is $20/month billed annually ($240/year); the API is separate and lists $0.01/credit, with standard textured text-to-3D at 20 credits and auto-rig at 25 credits before retries [45][51]. Buy only after a free creature test passes silhouette and deformation gates. |
| A humanoid/player pipeline | Meshy Pro | $20/month or $240/year with 1,000 credits/month and private/full-commercial treatment [46]. Compare one real player asset against the Blender/Rokoko baseline before renewing. |
| Static prop variation | Rodin Creator or pay-by-result | Start with Rodin Free previews; Creator is $30/month or $24/month billed annually and adds the clearer unlimited-export/any-use boundary [44]. Stop if Blender cleanup takes longer than manual blockout. |
| Grapple/combat pose polish | Cascadeur Indie, or Pro if the revenue/funding cap does not fit | Indie is $19/month or $8/month billed annually; Pro is $49/month or $33/month billed annually [48]. Do not buy before a stable player/creature skeleton and a real in-game action exist. |
| More AI mocap/retargeting | Rokoko Basic | $10/month billed annually or $12 month-to-month [47]. Stay on Starter if the free monthly allowance covers the current slice. |

Do not subscribe to Tripo, Rodin, Meshy, Rokoko, and Cascadeur at once. Choose one paid bottleneck, record the result, and cancel or stop buying when it fails the same acceptance test that justified the spend. The likely first exception is a single creature-generation purchase; it is not a reason to fund the entire art stack.

## Freeze policy

Freeze the reproducible parts of the pipeline, and freeze evidence for the hosted parts:

1. Record the exact Godot editor version, export-template version, renderer, project settings, and downloaded installer/archive. If the current project is already on an earlier 4.7 patch and imports are passing, test `4.7.2-stable` in a branch rather than upgrading the working slice silently. [38]
2. Record the exact Blender line and release. Use `5.2.1 LTS` for a new pipeline; retain `4.5.13 LTS` when a validated plug-in/source library depends on it. [39]
3. Vendor Godot add-ons or pin Git commits. For local tools, keep the downloaded release and a checksum; for Material Maker, AutoRemesher, MeshLab, and Effekseer, use the versions in the table above. [40][41][42][43]
4. If Hunyuan3D is tested, save the exact Git commit, model-weight version, Python/PyTorch/CUDA environment, launch settings, hardware result, and a copy of the Community License. For Kenney, archive the exact pack/version and its license page; for Mixamo, archive the downloaded character and animation files plus a manifest of clip names and the access/terms snapshot. [54][55][56][57]
5. For every other hosted asset, save provider, model ID, plan, date, prompt, reference-image provenance, settings, raw output, processed output, and a license/terms snapshot. A SaaS model cannot be frozen, but the asset and the evidence used to accept it can be.
6. Never auto-regenerate accepted assets when a provider changes its web model. New versions are new experiments; they do not silently replace old meshes, textures, rigs, or animation clips.
7. Re-run the import, deformation, collision, grapple-targeting, nav, performance, and rights checks after any engine, DCC, add-on, model, plan, or terms change.

Terrain3D `v1.0.2` currently documents Godot 4.4–4.6+ support, and ProtonScatter 4.0's notes describe Godot 4.0–4.2 compatibility [49][50]. Treat both as **hold/test** items on Godot 4.7; use native tools or the newer Godot 4.7-targeted Scatter alternative until a small scene proves they work.

# Recommended stack and asset flow

## Base stack

- Godot 4.7.2-stable project import pipeline using GLB/GLTF as the production hand-off; if the current project is already stable on an earlier 4.7 patch, upgrade only through a branch test. [38]
- Blender 5.2.1 LTS for a new pipeline, or pinned 4.5.13 LTS when an existing add-on/source library requires it, for cleanup, UV/material edits, rig fixes, animation assembly, and export. [39]
- MeshLab `2025.07` for quick inspection/repair; AutoRemesher `1.2.0` plus bridge `v0.1.3` only when topology is the bottleneck. [41][43]
- Kenney/Quaternius/KayKit for CC0 placeholders and free coverage; Poly Haven/ambientCG for CC0 surface coverage. [27][28][29][30][55]
- Hunyuan3D-2.1 as an optional local custom-mesh benchmark when the machine/cloud path and license pass; Tripo for the first custom creature experiments; Rodin for static props/environment variants. [53][54]
- Mixamo as the first free humanoid motion baseline, then Rokoko for additional motion; Cascadeur only when grapple/combat polish proves it is worth the time. [56][57]
- Material Maker `1.7`/ArmorPaint, Effekseer `1.80.7`, and Sonniss for style/VFX/audio coverage. [40][42]

## Suggested flow

```text
rights-cleared concept/reference
        ↓
Hunyuan3D: local custom mesh OR Tripo: custom creature       Rodin: static prop/environment
        ↓                               ↓
Blender 5.2.1 (or pinned 4.5.13) + optional AutoRemesher/MeshLab cleanup
        ↓
Material Maker/ArmorPaint style pass
        ↓
Tripo creature rig/retarget OR Mixamo/AccuRIG/Rokoko humanoid rig
        ↓
Tripo creature presets or Blender/manual actions; Mixamo/Rokoko/Cascadeur humanoid actions
        ↓
GLB + separate animation libraries
        ↓
Godot import, collision/nav setup, game-camera and performance QA
```

## First vertical-slice validation pack

This is the smallest test that can falsify the pipeline before a large content commitment:

1. One Kenney, Quaternius, or KayKit humanoid/prop placeholder as a visual coverage baseline.
2. One Hunyuan3D static mesh experiment if the local/cloud hardware path passes; record the result even if it is rejected for licensing or compatibility.
3. One custom Tripo creature with a non-humanoid body plan, ideally a quadruped or segmented enemy rather than a generic biped.
4. One Rodin or Kenney/Quaternius altar/traversal prop with an explicit collision setup.
5. Three player clips—idle, locomotion, and grapple/combat action—using Mixamo first where the body is humanoid; and three creature clips—idle, locomotion, and attack/contact.
6. One Material Maker or ArmorPaint material language test covering matte dark surfaces, cyan emissive, and amber industrial accents.
7. One Effekseer or native-Godot grapple effect and roughly ten Sonniss sound effects wired into gameplay.
8. An import checklist: meter scale, forward/up orientation, skeleton rest pose, animation names, root motion policy, collision, navigation, grapple targeting, texture memory, and in-game camera deformation.

The test passes only if the assets are usable in gameplay, not merely attractive in a web viewer. The creature test is the key gate. If it fails, use a static or segmented/procedural enemy for the first slice and keep the custom AI creature as a later content experiment.

# Failure gates and operational rules

- Reject any generated asset that arrives with an unclear license, untracked reference image, or no saved plan/account evidence.
- Reject or remesh meshes that exceed the slice's performance budget, have broken UVs, duplicate/loose geometry, or use dozens of accidental materials.
- Do not let automatic rigging determine gameplay skeleton architecture before a real animation/contact test.
- Do not place traversal-critical grapple anchors on automatically scattered or terrain-generated geometry until targeting and collision are verified.
- Keep source `.blend` files, raw downloads, prompts, licenses, and generated outputs in an `art_source`/ledger area; keep only validated runtime assets in `res://`.
- Treat all pricing, licensing, model versions, and plug-in compatibility as volatile. Recheck them 30 days before a purchase or release.

# Prioritized buying order

1. Lock the exact Godot patch/templates and one Blender line; buy no subscription for this step.
2. Use Kenney/Quaternius/KayKit plus the free/open-source stack to validate import, materials, VFX, audio, collision, and a playable placeholder.
3. Test Mixamo on the actual humanoid player/NPC skeleton before paying for motion capture or retargeting; keep the accepted clips locally with a terms snapshot.
4. Test Hunyuan3D only as a bounded local/cloud custom-mesh experiment if the hardware and Community License pass; do not make it a rig/animation dependency.
5. Use Tripo Free, Rodin Free, and Meshy Free only for bounded look/rig experiments, recording their tier and rights restrictions; do not ship restricted output by assumption.
6. After the creature/player acceptance test passes, pay for one bottleneck only: Tripo Studio/API for the custom creature or Meshy Pro for a humanoid pipeline.
7. Consider Rodin Creator, Rokoko Basic, or Cascadeur only when a measured in-game problem remains; compare the paid result against the free baseline before renewing.
8. Avoid hardware purchases and NVIDIA-only local stacks until the game has proven a content bottleneck that hosted tools cannot solve.

# Open questions for the next test

- Can Tripo v2.5 produce a stable skeleton for the exact Rootstalker/Spore Kite body plans, or is procedural/segmented animation cheaper?
- Does Tripo's current non-humanoid Animation Retarget output provide usable idle/locomotion/attack/contact clips, or is manual Blender animation still faster? [58][59]
- Does Hunyuan3D-2.1 run acceptably on the current AMD RX 6800, through a compatible backend/cloud instance, and under the intended commercial territory/use? [53][54]
- Does Mixamo successfully auto-rig the intended player/NPC meshes and preserve usable clip names/orientation through Godot import? [56][57]
- Which Kenney pack/version provides the best $0 placeholder coverage, and does its style need a material/color unification pass? [55]
- Does the chosen Tripo/Rodin/Meshy export preserve meter scale, material slots, and animation names through Godot 4.7 without manual repair every time?
- Which stylization pass—Material Maker procedural materials or ArmorPaint hand-painted masks—best unifies CC0, generated, and primitive assets?
- Does Effekseer's Godot 4 plug-in work cleanly with the exact Godot build and renderer settings?
- What triangle/material/texture budgets are acceptable on the target camera and hardware after the first real room is assembled?

# Staleness map

Research date: August 30, 2026.

- The following table is the output of `recon_kit.py staleness claims.json --windows {"capability":3,"compatibility":1,"hardware":6,"licensing":1,"pricing":1} --today 2026-08-30`, using the claims ledger in this run.

| Claim | Class | Source pub. date | Recheck date | Stale on research date? |
|---|---|---:|---:|---|
| Tripo documents non-humanoid rig families | capability | 2026-02 | 2026-05-01 | yes |
| Meshy web/API quadruped support disagreement | capability | 2026-08 | 2026-11-01 | no |
| Godot GLB hand-off and Blender importer behavior | compatibility | 2026-08 | 2026-09-01 | no |
| Historical Blender 4.5 LTS support window | compatibility | 2026-08 | 2026-09-01 | no |
| Rokoko/Cascadeur animation workflow fit | capability | 2026-08 | 2026-11-01 | no |
| TRELLIS.2 local hardware requirements | hardware | 2026-08 | 2027-02-01 | no |
| CC0 and compatible asset-library coverage | licensing | 2026-08 | 2026-09-01 | no |
| Sonniss GDC 2026 commercial audio terms | licensing | 2026-08 | 2026-09-01 | no |
| Tripo usage-based price | pricing | 2026-08 | 2026-09-01 | no |
| Meshy free/paid output and data-use terms | licensing | 2026-03 | 2026-04-01 | yes |
| Rodin API retention and training policy | licensing | 2026-08 | 2026-09-01 | no |
| Godot 4.7.2 is the current stable 4.7 patch | compatibility | 2026-08 | 2026-09-01 | no |
| Blender 5.2.1 LTS is the current LTS with 4.5.13 as a supported fallback | compatibility | 2026-08 | 2026-09-01 | no |
| Free local pipeline release pins are Material Maker 1.7, AutoRemesher 1.2.0, bridge v0.1.3, MeshLab 2025.07, and Effekseer 1.80.7 | compatibility | 2026-08 | 2026-09-01 | no |
| Tripo Studio Free and Pro have different credit, privacy, export, and commercial-use boundaries | pricing | 2026-08 | 2026-09-01 | no |
| Tripo Studio free-credit figures differ between current vendor pages | pricing | 2026-08 | 2026-09-01 | no |
| Tripo API uses pay-as-you-go credits at $0.01 per credit | pricing | 2026-08 | 2026-09-01 | no |
| Rodin Free and Creator have different export and use-rights boundaries | pricing | 2026-08 | 2026-09-01 | no |
| Meshy Free lists 100 monthly credits with CC BY 4.0 attribution and Pro lists 1000 credits with private/full-commercial treatment | pricing | 2026-08 | 2026-09-01 | no |
| Rokoko Starter is free and Basic adds paid AI/retargeting capacity | pricing | 2026-08 | 2026-09-01 | no |
| Cascadeur Free is noncommercial/CASC-only while Indie and Pro add export and commercial rights | licensing | 2026-08 | 2026-09-01 | no |
| Terrain3D v1.0.2 documents Godot 4.4-4.6+ support | compatibility | 2026-05 | 2026-06-01 | yes |
| ProtonScatter 4.0 release notes describe Godot 4.0-4.2 compatibility | compatibility | 2026-08 | 2026-09-01 | no |
| Hunyuan3D-2.1 open PBR model-generation pipeline and CUDA-oriented requirements | capability | 2026-08 | 2026-11-01 | no |
| Hunyuan3D-2.1 Community License restrictions | licensing | 2026-08 | 2026-09-01 | no |
| Kenney individual assets are CC0 and commercially usable while the All-in-1 bundle is optional paid convenience | licensing | 2026-08 | 2026-09-01 | no |
| Mixamo is free with an Adobe ID, supports commercial games, and is biped-focused | capability | 2021-09 | 2021-12-01 | yes |
| Mixamo Additional Terms prohibit AI/ML training use | licensing | 2021-06 | 2021-07-01 | yes |
| Tripo Animation Retarget preset capability and smaller nonhumanoid set | capability | 2026-08 | 2026-11-01 | no |
| Tripo current nonhumanoid rig types | capability | 2026-08 | 2026-11-01 | no |
| Tripo Animation Retarget and Auto Rig credit costs | pricing | 2026-08 | 2026-09-01 | no |

The checker flags five source-age candidates: Tripo rig documentation, Meshy terms, Terrain3D compatibility, and the older Mixamo FAQ/additional terms. The mechanically earliest recheck date is July 1, 2021. The Tripo and Meshy pages were checked again during this run but retain older publication dates in the ledger, so they remain mechanically age-flagged; Terrain3D remains a real hold/test item for Godot 4.7; Mixamo remains a useful free baseline but its older rights/capability pages must be rechecked before release. Independent of the computed dates, recheck pricing, terms, retention, and plug-in compatibility before purchase/release; re-run the vertical-slice acceptance pack after any major generator, Blender, Godot, or plug-in version change.

# Source appendix

Every inline `[n]` marker resolves to one row below. For living documentation with no explicit publication date, `2026-08` means the current page was checked on August 30, 2026 rather than claiming that the page was first published that month.

| [n] | Finding supported | Publisher/source | Pub. date | Accessed | Confidence |
|---:|---|---|---:|---:|---|
| 1 | Agent-oriented CLI and automation surface | [Tripo CLI](https://developers.tripo3d.com/en/docs/cli) | 2026-08 | 2026-08-30 | medium |
| 2 | v3.1 generation, game-facing topology/size controls | [Tripo generation docs](https://developers.tripo3d.com/en/docs/generation-text-to-model/standard) | 2026-08 | 2026-08-30 | medium |
| 3 | Non-humanoid rig families and rig workflow | [Tripo rig docs](https://developers.tripo3d.com/en/docs/animations-rig) | 2026-02 | 2026-08-30 | medium, unverified for output quality |
| 4 | Usage-based generation and auto-rig pricing | [Tripo pricing](https://developers.tripo3d.com/en/pricing) | 2026-08 | 2026-08-30 | medium |
| 5 | Free/paid output rights and uniqueness caveat | [Tripo terms](https://www.tripo3d.ai/terms) | 2025-07 | 2026-08-30 | medium, recheck |
| 6 | Rodin Gen-2.5 static generation formats and quality modes | [Rodin Gen-2.5 API](https://docs.hyper3d.ai/en/api-specification/rodin-gen2-5) | 2026-08 | 2026-08-30 | medium |
| 7 | Direct Godot bridge and supported Godot range | [Rodin Godot add-on](https://docs.hyper3d.ai/en/addons/godot-addon) | 2026-08 | 2026-08-30 | medium |
| 8 | Rodin API retention and training statement | [Rodin API retention policy](https://docs.hyper3d.ai/en/legal/data-retention-policy) | 2026-08 | 2026-08-30 | medium, endpoint-specific |
| 9 | Broader Rodin service terms | [Rodin terms](https://hyper3d.ai/legal/terms) | 2026-08 | 2026-08-30 | medium, recheck |
| 10 | Meshy-7, Smart Topology, 8K textures, Text-to-Motion | [Meshy API/web changelogs](https://docs.meshy.ai/en/api/changelog) and [web changelog](https://docs.meshy.ai/en/webapp/changelog) | 2026-08 | 2026-08-30 | medium |
| 11 | Meshy API rigging constraints | [Meshy API rigging](https://docs.meshy.ai/en/api/rigging) | 2026-08 | 2026-08-30 | medium |
| 12 | Meshy API animation and quadruped rejection | [Meshy API animation](https://docs.meshy.ai/en/api/animation) | 2026-08 | 2026-08-30 | medium |
| 13 | Meshy web quadruped auto-rig claim | [Meshy web animate guide](https://docs.meshy.ai/en/webapp/guides/animate) | 2026-08 | 2026-08-30 | medium, conflicts with API docs |
| 14 | Meshy pricing and data-use terms | [Meshy terms](https://www.meshy.ai/terms-of-use) and [pricing](https://www.meshy.ai/pricing) | 2026-03 | 2026-08-30 | medium, recheck |
| 15 | Godot import, configuration, and `.blend` behavior | [Godot 4.7 import pipeline](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/index.html), [configuration](https://docs.godotengine.org/en/latest/tutorials/assets_pipeline/importing_3d_scenes/import_configuration.html), and [Blender importer](https://docs.godotengine.org/en/stable/classes/class_editorsceneformatimporterblend.html) | 2026-08 | 2026-08-30 | medium, unverified |
| 16 | Blender 4.5 LTS, formats, cleanup, and baking (historical line) | [Blender release](https://www.blender.org/releases/4-5/), [pipeline](https://www.blender.org/features/pipeline/), [cleanup](https://docs.blender.org/UATEST/manual/en/4.5/modeling/meshes/editing/mesh/cleanup.html), and [baking](https://docs.blender.org/manual/en/latest/render/cycles/baking.html) | 2026-08 | 2026-08-30 | medium, unverified; superseded for new installs by [39] |
| 17 | Automatic quad remeshing and Blender bridge | [AutoRemesher](https://github.com/huxingyi/autoremesher) and [Blender bridge](https://github.com/adriflex/autoremesher-blender-bridge) | 2026-08 | 2026-08-30 | medium |
| 18 | Open mesh inspection and repair | [MeshLab](https://www.meshlab.net/) | 2025-09 | 2026-08-30 | medium |
| 19 | Rokoko humanoid motion generation/export/pricing | [Rokoko Create](https://create.rokoko.com/) and [pricing](https://www.rokoko.com/pricing) | 2026-08 | 2026-08-30 | medium |
| 20 | Cascadeur plans and interchange formats | [Cascadeur plans](https://cascadeur.com/plans) | 2026-08 | 2026-08-30 | medium |
| 21 | Humanoid rig/motion alternatives | [AccuRIG](https://www.reallusion.com/auto-rig/accurig/default.html) and [DeepMotion](https://www.deepmotion.com/pricing-animate3d) | 2026-08 | 2026-08-30 | medium |
| 22 | TRELLIS.2 platform and VRAM requirements | [Microsoft TRELLIS.2](https://github.com/microsoft/TRELLIS.2) | 2026-08 | 2026-08-30 | medium, unverified |
| 23 | Stable Fast 3D local static reconstruction | [Stable Fast 3D](https://github.com/Stability-AI/stable-fast-3d) | 2026-08 | 2026-08-30 | medium |
| 24 | Stable Fast 3D commercial model license | [Stable Fast 3D model card](https://huggingface.co/stabilityai/stable-fast-3d) | 2026-08 | 2026-08-30 | medium, gated/recheck |
| 25 | MIT-licensed lightweight static reconstruction alternative | [TripoSR](https://github.com/VAST-AI-Research/TripoSR) | 2026-08 | 2026-08-30 | medium |
| 26 | Local PBR paint and procedural material tools | [ArmorPaint](https://armorpaint.org/) and [Material Maker](https://www.materialmaker.org/) | 2026-08 | 2026-08-30 | medium |
| 27 | CC0 character, prop, and monster coverage | [Quaternius characters](https://quaternius.com/packs/universalbasecharacters.html), [outfits](https://quaternius.com/packs/modularcharacteroutfitsfantasy.html), [props](https://quaternius.com/packs/fantasypropsmegakit.html), and [monsters](https://quaternius.com/packs/animatedmonster.html) | 2025-2026 | 2026-08-30 | medium |
| 28 | CC0 rigged/animated character coverage | [KayKit Series 6](https://kaylousberg.itch.io/kaykit-series-6) and [Complete](https://kaylousberg.itch.io/kaykit-complete) | 2026-08 | 2026-08-30 | medium |
| 29 | CC0 HDRI/material license | [Poly Haven license](https://polyhaven.com/license) | 2026-08 | 2026-08-30 | medium, unverified |
| 30 | CC0 material/asset license | [ambientCG license](https://docs.ambientcg.com/license/) | 2026-08 | 2026-08-30 | medium, unverified |
| 31 | Fab Standard License boundaries | [Fab EULA](https://www.fab.com/eula?lang=en) | 2026-08 | 2026-08-30 | medium, listing-specific |
| 32 | Effekseer tool and Godot plug-in | [Effekseer download](https://effekseer.github.io/en/download.html) | 2026-08 | 2026-08-30 | medium |
| 33 | Sonniss GDC 2026 audio and commercial license | [GDC 2026 bundle](https://gdc.sonniss.com/) and [license](https://sonniss.com/gdc-bundle-license/) | 2026-08 | 2026-08-30 | medium, unverified |
| 34 | Godot VFX sample code/art licenses | [GDQuest VFX assets](https://github.com/gdquest-demos/godot-4-VFX-assets) | 2026-08 | 2026-08-30 | medium |
| 35 | Terrain editing, LOD, holes, and foliage | [Terrain3D](https://github.com/TokisanGames/Terrain3D) | 2026-08 | 2026-08-30 | medium |
| 36 | Non-destructive Godot scattering | [ProtonScatter](https://github.com/HungryProton/scatter) | 2026-08 | 2026-08-30 | medium |
| 37 | Godot 4.7 native scatter alternative | [Scatter for Godot](https://github.com/xiaowangxu/godot-scatter-plugin) | 2026-08 | 2026-08-30 | low-to-medium, active development |
| 38 | Godot 4.7.2 current stable patch | [Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 39 | Blender current LTS lines and support windows | [Blender active LTS](https://www.blender.org/download/lts/) and [Blender 5.2.1](https://www.blender.org/releases/5-2/) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 40 | Material Maker 1.7 release | [Material Maker releases](https://github.com/RodZill4/material-maker/releases) | 2026-07 | 2026-08-30 | medium |
| 41 | AutoRemesher 1.2.0 and Blender bridge v0.1.3 releases | [AutoRemesher releases](https://github.com/huxingyi/autoremesher/releases) and [bridge releases](https://github.com/adriflex/autoremesher-blender-bridge/releases) | 2026-08 | 2026-08-30 | medium |
| 42 | Effekseer 1.80.7 and Godot 4 plug-in availability | [Effekseer downloads](https://effekseer.github.io/en/download.html) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 43 | MeshLab 2025.07 release | [MeshLab releases](https://github.com/cnr-isti-vclab/meshlab/releases) | 2025-07 | 2026-08-30 | medium |
| 44 | Rodin Free/Creator tier, export, and use-right boundaries | [Rodin pricing](https://hyper3d.ai/pricing?lang=en) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 45 | Tripo Studio Free/Pro credits, privacy, export, and commercial-use boundaries | [Tripo Studio pricing](https://www.tripo3d.ai/pricing) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 46 | Meshy Free/Pro credits, attribution, privacy, and commercial-use terms | [Meshy pricing](https://www.meshy.ai/pricing) and [pricing documentation](https://docs.meshy.ai/en/webapp/pricing) | 2026-08 | 2026-08-30 | medium, current-page snapshot; terms recheck |
| 47 | Rokoko Starter/Basic prices and limits | [Rokoko pricing](https://www.rokoko.com/pricing) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 48 | Cascadeur Free/Indie/Pro prices, export, and commercial boundaries | [Cascadeur plans](https://cascadeur.com/plans) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 49 | Terrain3D v1.0.2 Godot support range | [Terrain3D releases](https://github.com/TokisanGames/Terrain3D/releases) | 2026-05 | 2026-08-30 | medium, compatibility recheck |
| 50 | ProtonScatter 4.0 Godot compatibility note | [ProtonScatter releases](https://github.com/HungryProton/scatter/releases) | 2026-08 | 2026-08-30 | medium, compatibility recheck |
| 51 | Tripo API pay-as-you-go credit pricing | [Tripo API pricing](https://developers.tripo3d.com/en/pricing) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 52 | Tripo Studio free-tier commercial-use explanation and credit discrepancy | [Tripo production pricing explanation](https://www.tripo3d.ai/media-production/generate-film-ready-3d-assets) | 2026-08 | 2026-08-30 | medium, conflicts with current Studio pricing page |
| 53 | Hunyuan3D-2.1 open model/PBR generation, VRAM figures, and CUDA-oriented setup | [Tencent Hunyuan3D-2.1 repository](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) | 2026-08 | 2026-08-30 | medium, current-page snapshot; local AMD compatibility unverified |
| 54 | Hunyuan3D-2.1 Community License restrictions | [Hunyuan3D-2.1 license](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1/blob/main/LICENSE) | 2026-08 | 2026-08-30 | medium, project-specific legal review required |
| 55 | Kenney free/CC0 asset coverage, formats, commercial use, and optional All-in-1 bundle | [Kenney Game Assets](https://kenney.itch.io/kenney-game-assets) and [Kenney](https://kenney.nl/) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
| 56 | Mixamo free access, commercial game use, biped-focused auto-rig/library, and mesh requirements | [Adobe Mixamo FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html) | 2021-09 | 2026-08-30 | medium, older official page; recheck |
| 57 | Mixamo AI/ML training restriction and additional terms | [Adobe Mixamo Additional Terms](https://wwwimages2.adobe.com/content/dam/cc/en/legal/servicetou/Mixamo-Addl-Terms-en_US-20210623.pdf) | 2021-06 | 2026-08-30 | medium, older official terms; recheck |
| 58 | Tripo Animation Retarget preset library and animated-model output | [Tripo animation docs](https://developers.tripo3d.com/en/models/animation) | 2026-08 | 2026-08-30 | medium, current-page snapshot; output quality unverified |
| 59 | Tripo current non-humanoid rig types and auto-rig workflow | [Tripo rig docs](https://developers.tripo3d.com/en/models/rig) | 2026-08 | 2026-08-30 | medium, current-page snapshot; output quality unverified |
| 60 | Tripo Animation Retarget and Auto Rig credit costs | [Tripo API pricing](https://developers.tripo3d.com/en/pricing) | 2026-08 | 2026-08-30 | medium, current-page snapshot |
