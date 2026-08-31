---
title: 'Free-first costs and freeze manifest digest'
type: 'technical'
updated: '2026-08-30'
---

# Scope

This is a live pricing and release recheck for the solo-developer constraint. It supersedes the earlier generic cost summary where the current product pages provide more specific tier details.

# Free/open-source core

- Godot 4.7.2 is the current stable 4.7 maintenance release. Freeze the exact editor build and matching export templates rather than tracking “4.7” loosely.
- Blender 5.2.1 LTS is the current LTS release and is supported through July 2028. Blender 4.5.13 LTS remains supported through July 2027, so an already-working 4.5 pipeline should not be upgraded mid-slice solely to chase the newer major line.
- Material Maker 1.7, MeshLab 2025.07, AutoRemesher 1.2.0, the AutoRemesher Blender bridge v0.1.3, and Effekseer 1.80.7 provide a free/open-source or free-tool cleanup/material/VFX path. Freeze their exact tags/releases and store installers or checksums locally.
- Quaternius, KayKit free packs, Poly Haven, ambientCG, and the Sonniss GDC bundle can cover a large part of prototype art, materials, and sound without recurring fees, subject to their license conditions.

# Hosted free tiers

- Tripo Studio Free currently lists 200 monthly credits, public models, non-commercial use, and limited exports. A separate Tripo production page currently shows 300 free credits, so the allowance is a vendor-page discrepancy; treat Free as testing-only, not a final commercial game asset. Pro lists $20/month billed annually at $240/year, 3,000 credits, private models, commercial use, and the DCC bridge. Tripo API is separate and pay-as-you-go at $0.01 per credit.
- Rodin Free currently lists $0, basic image/text exploration, free generation before confirmation, legacy-model exports, 10 private assets, and public-gallery/pay-by-result behavior. Creator lists $30/month or $24/month billed annually and adds unlimited export/any use, private assets, Smart Low-Poly, HD/custom texture, and redos. Business adds API access at a substantially higher tier.
- Meshy Free lists 100 credits/month, no card required, and CC BY 4.0 output with attribution for commercial use. Pro lists $20/month or $240/year, 1,000 credits/month, private ownership, and full commercial use. Free output is acceptable for attributable prototypes or shipping only when the current license is intentionally accepted; paid is cleaner for hero assets.
- Rokoko Starter is free forever and includes FBX export, 30 seconds/month of Vision AI processing, unlimited text-to-motion generation, and five text-to-motion Studio imports/month. Basic starts at $10/month when billed annually or $12 month-to-month and adds custom-character import/retargeting.
- Cascadeur Free is free forever but non-commercial and CASC-only. Indie lists $19/month or $8/month billed annually, with export and a stated revenue/funding limit below $100,000/year; Pro is the unrestricted commercial tier.

# Recommended cash policy

- Keep the baseline at $0: Godot, Blender, Material Maker, MeshLab, AutoRemesher, Effekseer, CC0 libraries, Rokoko Starter, and manual/procedural animation.
- Spend only after the free validation pack passes. The first likely paid exception is a small Tripo API batch or one paid Studio billing period for final creature generation, or one billing period of Meshy Pro for a humanoid/player pipeline; note that the current Tripo Pro listing shows $20/month billed annually ($240/year). Do not subscribe to both before comparing outputs.
- Use Rodin Free for previews and static-prop exploration, but do not assume the free tier includes the same commercial/unlimited-use rights shown for Creator.
- Use Cascadeur Free only for noncommercial learning/prototyping; if the grapple/combat polish proves valuable, budget Indie or Pro based on the project's revenue/funding status.

# Freeze manifest

| Component | Freeze recommendation | Why |
|---|---|---|
| Godot | `4.7.2-stable` plus matching export templates | Current stable patch; avoids accidental 4.8-dev adoption |
| Blender | `5.2.1 LTS` for a new pipeline; retain `4.5.13 LTS` if the validated add-on stack depends on it | Current LTS lasts to July 2028; both current LTS lines remain available |
| Material Maker | Tag `1.7` | Current released tag; local and MIT-licensed |
| AutoRemesher | Release `1.2.0`; Blender bridge `v0.1.3` | Explicit release tags, Windows binaries, and separate licenses |
| MeshLab | `MeshLab-2025.07` installer or portable archive | Latest official release found; keep the downloaded binary locally |
| Effekseer | Tool `1.80.7` plus the Godot 4 plug-in commit/release used by the project | Exact current tool version and matching runtime |
| Godot add-ons | Vendor the tested files or pin a Git commit; do not install “latest” from AssetLib | Prevents editor updates from silently changing import/scatter behavior |
| Hosted generators | Store provider, model ID, plan, date, prompts, references, raw outputs, license snapshot, and output hash | SaaS versions cannot be frozen; only the generated evidence can be |

# Compatibility cautions

- Terrain3D v1.0.2-stable's release notes document support for Godot 4.4–4.6+. Do not treat it as a confirmed Godot 4.7 dependency until the demo and grapple/nav tests pass.
- ProtonScatter's 4.0 release notes describe Godot 4.0–4.2 compatibility at the time of writing. For Godot 4.7, use a tested commit or the newer Godot 4.7-targeted Scatter alternative; otherwise keep visual dressing manual.
- Freeze the project at one Blender line. Do not mix 4.5 and 5.2 `.blend` saves in the same source library without a deliberate migration test.

# Primary sources

- [Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/)
- [Blender active LTS releases](https://www.blender.org/download/lts/)
- [Blender 5.2.1 LTS](https://www.blender.org/releases/5-2/)
- [Material Maker releases](https://github.com/RodZill4/material-maker/releases)
- [AutoRemesher releases](https://github.com/huxingyi/autoremesher/releases)
- [AutoRemesher Blender bridge releases](https://github.com/adriflex/autoremesher-blender-bridge/releases)
- [Effekseer downloads](https://effekseer.github.io/en/download.html)
- [MeshLab releases](https://github.com/cnr-isti-vclab/meshlab/releases)
- [Rodin pricing](https://hyper3d.ai/pricing?lang=en)
- [Tripo Studio pricing](https://www.tripo3d.ai/pricing)
- [Tripo Studio commercial-use explanation](https://www.tripo3d.ai/media-production/generate-film-ready-3d-assets)
- [Tripo API pricing](https://developers.tripo3d.com/en/pricing)
- [Meshy pricing and credits](https://docs.meshy.ai/en/webapp/pricing)
- [Rokoko pricing](https://www.rokoko.com/pricing)
- [Cascadeur plans](https://cascadeur.com/plans)
- [Terrain3D releases](https://github.com/TokisanGames/Terrain3D/releases)
- [ProtonScatter releases](https://github.com/HungryProton/scatter/releases)
