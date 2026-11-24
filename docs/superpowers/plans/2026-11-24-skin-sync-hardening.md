# Skin switcher hardening — plan

**Spec:** `docs/superpowers/specs/2026-11-24-skin-sync-hardening-design.md`

## Task 1: Switcher state and ARIA

- [x] Extend `test/basecoat_phoenix/live_js_test.exs`:
  - role guard mentions `menuitemradio`
  - `aria-disabled` is handled
  - `syncSkinItems();` appears at least four times (setSkin, load, mounted, updated)
  - the module-load block calls `applyStoredSkin();` then `syncSkinItems();`
- [x] Run it and watch it fail.
- [x] In `priv/basecoat/basecoat_live.js`:
  - skip items whose role is not `menuitemradio`, `radio`, `checkbox`, or `switch`
  - run `applyStoredSkin()`, `syncSkinItems()`, and `attachSkinApi()` in the
    `document` load block
  - call `syncSkinItems()` in `mounted` and at the end of `updated`
  - keep `attachSkinApi()` as a fallback inside the one-shot `syncRuntime`
  - skip a clicked item with `aria-disabled="true"`
- [x] Run the test and watch it pass.

## Task 2: Palette drift guards

- [x] Append to `test/basecoat_phoenix/assets_test.exs`: for every palette, the
  dark block's token names equal the light block's token names.
- [x] Add to `test/basecoat_phoenix/installer_test.exs`: a hand-edited
  `layer(basecoat)` import still ends up with the `skins.css` import.
- [x] Run both files; both pass without installer changes.

## Task 3: Docs

- [x] README: a stored choice, including `default`, wins over markup.
- [x] `docs/manual-verification.md`: disabled picker item does not switch.

## Task 4: Gates

- [x] `mix format --check-formatted`
- [x] `mix test`
- [x] `mix compile --warnings-as-errors --force`
- [x] `mix docs`
- [x] Commit.