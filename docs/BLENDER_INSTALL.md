# Blender Plugin Installation

## Artifact

- `plugins/autorig_blender-0.2.3.zip`

## Install Steps

1. Open Blender.
2. Go to `Edit -> Preferences -> Add-ons`.
3. Click `Install...`.
4. Select `plugins/autorig_blender-0.2.3.zip`.
5. Enable the `AutoRig AI` add-on.

## Notes

- This plugin package is Blender-standard and contains Python add-on code inside the zip.
- The add-on talks to the local AutoRig API server. Start it from this repo with `bash ./bin/setup.sh`.

## Pocket Anchor Confirmation (Contact Pose)

For `contact_v2` pocket poses (`hand_in_pocket*`), run is blocked until the anchor is confirmed:

1. Set `Pose Mode` and `Contact Pose ID` in add-on preferences.
2. Configure pocket anchor side/center/half extents.
3. Click run; a confirmation dialog shows side, center, half extents, and preview state.
4. Confirm to continue; cancel to reposition.

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

## EXPERIMENTAL: Film Extension + Facial Plugin (Optional)

This add-on also includes a disabled-by-default film extension layer:

- `film_spine_mid_*`
- `film_twist_*`
- `film_scapula_*`
- `film_metacarpal_*`
- optional `film_face_*`

Enable in Blender:

1. Open `Edit -> Preferences -> Add-ons`.
2. Find `AutoRig AI`.
3. Under **Experimental**, enable `Enable EXPERIMENTAL Film Extension`.
4. Optionally enable `Enable EXPERIMENTAL Film Facial Plugin`.
5. Choose `Film Facial Mode` (`auto|landmark|surface_project|offset`).
6. Optional: set `Film Facial Calibration JSON` for per-character overrides.

## EXPERIMENTAL: Eyelid Color Appearance (Optional)

When film extension + film facial plugin are enabled, this build adds eyelid color controls in
add-on preferences:

1. Enable `Enable Film Eyelid Color`.
2. Set `Left/Right` upper/lower colors (`#RRGGBB`).
3. Set opacity in `[0,1]`.
4. Keep color space as `srgb`.

Invalid eyelid payload values are rejected by the API with `AUTORIG_EYELID_COLOR_INVALID`.
