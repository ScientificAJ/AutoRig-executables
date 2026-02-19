# Blender Plugin Installation

## Artifact

- `plugins/autorig_blender-0.2.1.zip`

## Install Steps

1. Open Blender.
2. Go to `Edit -> Preferences -> Add-ons`.
3. Click `Install...`.
4. Select `plugins/autorig_blender-0.2.1.zip`.
5. Enable the `AutoRig AI` add-on.

## Notes

- This plugin package is Blender-standard and contains Python add-on code inside the zip.
- The add-on talks to the local AutoRig API server. Start it from this repo with `bash ./bin/setup.sh`.

## EXPERIMENTAL: Geometric Inference Mode (Optional)

This plugin includes an optional **EXPERIMENTAL** "Draw -> Recognize -> Correct" mode that uses guide strokes/lines
to infer a skeleton before running the standard correction/export pipeline.

Requirements:

- The AutoRig API server must be started with `AUTORIG_ENABLE_GEOMETRIC_AUTORIG=1`.
- Quickstart (server with EXPERIMENTAL enabled, no browser auto-open): `bash ./bin/setup.sh --geometric --no-open`

Enable in Blender:

1. Open `Edit -> Preferences -> Add-ons`.
2. Find `AutoRig AI`.
3. Under **Experimental**, enable `Enable EXPERIMENTAL Geometric Inference`.
4. Set `Rig Mode` to `Geometric Inference (EXPERIMENTAL)`.

## EXPERIMENTAL: Hair Rigging + Cloth Assist + Motion Presets (Optional)

This add-on includes disabled-by-default helper rig layers:

- Hair helper chains: `hair_grp_*`
- Cloth assist chains: `cloth_grp_*`

Enable in Blender:

1. Open `Edit -> Preferences -> Add-ons`.
2. Find `AutoRig AI`.
3. Under **Experimental**, enable `Enable EXPERIMENTAL Hair Rigging` and/or `Enable EXPERIMENTAL Cloth Assist`.
4. Optionally set a motion preset ID (e.g. `Wind_001`) and tweak direction/intensity/frequency/damping.
