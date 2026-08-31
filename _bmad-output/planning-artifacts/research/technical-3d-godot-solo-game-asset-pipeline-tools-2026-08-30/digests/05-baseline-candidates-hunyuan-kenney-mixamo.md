---
title: 'Baseline candidate delta: Hunyuan3D, Kenney, and Mixamo'
type: 'technical'
updated: '2026-08-30'
---

# Scope

The original research treated Hunyuan, Kenney, and Mixamo as prior baseline context. This delta puts them back into the comparison and marks exactly where each remains viable for a solo, non-artist Godot pipeline. They are not substitutes for one another:

| Candidate | Keep in the running for | Do not assign it |
|---|---|---|
| Hunyuan3D-2.1 | Local/custom static mesh and PBR generation benchmark | Creature rigging, retargeting, or final animation ownership |
| Kenney | $0 props, world/UI dressing, placeholder coverage, and style tests | Custom creature generation or a general creature-animation library |
| Mixamo | $0 humanoid auto-rig and player/NPC motion baseline | Arbitrary quadruped, avian, serpentine, or multi-limb creature animation |

# Evidence delta

## Hunyuan3D-2.1

The [official Tencent repository](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) describes an open framework with model weights/training code and PBR texture synthesis. Its README gives approximately 10 GB VRAM for shape generation, 21 GB for texture generation, and 29 GB for combined shape-plus-texture generation. The tested installation path is CUDA/PyTorch-oriented even though Windows is listed, so the current AMD RX 6800 needs an explicit compatibility test or a bounded cloud run.

The repository documents image/text-to-3D and texture synthesis, not automatic rigging or animation. Hunyuan is therefore a fair $0-software benchmark against hosted model generation, but Tripo/Blender still own the current creature rig/animation experiment.

The [Community License](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1/blob/main/LICENSE) is not CC0/MIT. It includes territory, service-size/MAU, acceptable-use, downstream-notice, and AI/ML restrictions. A Hunyuan result should remain an experiment until the exact release territory, audience scale, and use of outputs are checked.

## Kenney

The [official Kenney asset page](https://kenney.itch.io/kenney-game-assets) says the individual assets are CC0, usable in unlimited commercial projects, and usable without attribution. The page lists OBJ, FBX, GLTF, PNG, SVG, and OGG among the available formats. The current All-in-1 ZIP is listed as an optional $19.95-or-more convenience bundle; buying it is not required to use the free library.

Kenney is the strongest of the three for immediate $0 breadth: props, environment dressing, UI, and placeholders can get a slice playable before custom art exists. The trade-off is role, not license: Kenney is a premade library, not a custom creature generator, rigging service, or general animation solution. Use a material/color pass to reconcile its friendly low-poly look with the game's darker target.

## Mixamo

Adobe's [official Mixamo FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html) says Mixamo is free with an Adobe ID and does not require a Creative Cloud subscription. It describes characters and animations as royalty-free for personal, commercial, and non-profit use, including video games. The FAQ also describes the auto-rigger and animation library as humanoid/biped-oriented: the mesh needs a recognizable head, body, arms, and legs, and extra limbs, wings, or tails may cause failure.

This keeps Mixamo in the running as the first $0 test for a conventional player or humanoid NPC. It does not answer the game's custom-creature problem. Download accepted files locally and preserve a clip manifest because the service is hosted. The older [additional terms](https://wwwimages2.adobe.com/content/dam/cc/en/legal/servicetou/Mixamo-Addl-Terms-en_US-20210623.pdf) also prohibit using Mixamo services, content, data, or output to create, train, test, or improve ML/AI systems. Recheck these older pages before release.

# Comparison against the current stack

| Decision dimension | Hunyuan3D-2.1 | Kenney | Mixamo | Tripo current comparison |
|---|---|---|---|---|
| Software/access cost | $0 software; compute/hardware is the cost | $0 for individual CC0 assets; optional $19.95-or-more bundle | $0 with an Adobe ID; no CC subscription required per FAQ | Hosted credits; current API lists $0.01/credit |
| Custom model generation | Yes, local image/text-to-3D/PBR | No; premade assets | No; premade characters/animations | Yes; hosted model generation |
| Creature rigging | No documented rigging workflow in checked repo | Only what a particular pack includes | Humanoid/biped-focused; extra anatomy may fail | Current rig docs list quadruped, hexapod, octopod, avian, serpentine, and aquatic types |
| Creature animation | No documented animation workflow | Pack-specific clips only, if included | Not a general creature solution | Animation Retarget applies presets to a rigged model; current docs expose a smaller universal nonhumanoid set |
| Best vertical-slice role | Static/custom asset benchmark if hardware and license pass | Free visual breadth and placeholders | Player/humanoid NPC motion baseline | Custom creature bootstrap, with Blender/Godot QA |
| Main freeze item | Commit, weights, environment, license | Pack ZIP/version and license snapshot | Downloaded outputs, clip manifest, terms snapshot | Provider/model/plan/prompt/raw output/processed output |

Tripo's current [animation documentation](https://developers.tripo3d.com/en/models/animation) is why it remains ahead of Hunyuan for creature bootstrap: it accepts a rigged model and retargets preset motions. The current [API pricing](https://developers.tripo3d.com/en/pricing) lists Animation Retarget at 10 credits per animation and Auto Rig at 25 credits. This is cheap enough for a bounded test, but not a substitute for checking contacts, deformation, and combat readability in-engine.

# Recommended bake-off

1. Use Kenney plus Quaternius/KayKit for the first $0 level/placeholder pass.
2. Use Mixamo on the actual humanoid player/NPC mesh and compare import, orientation, root motion, and clip cleanup against Blender/Rokoko.
3. Run Hunyuan3D only if the AMD/cloud hardware path is viable; compare one static prop/custom mesh against Tripo on cleanup time, visual consistency, and rights evidence.
4. Run one Tripo nonhumanoid creature through rig check, Animation Retarget, Blender deformation review, and Godot gameplay QA.
5. Keep all three candidates in the shortlist, but choose by role: Kenney for breadth, Mixamo for humanoids, and Hunyuan3D for a local model-generation benchmark.

