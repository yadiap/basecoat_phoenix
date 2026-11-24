# Built-in theme palettes — design

## Intent

Apps should be able to change the whole look of a Basecoat UI without pasting
token blocks. The library ships a small set of palettes, a `data-skin`
attribute selects one, and the choice survives reloads.

## Goals

- Ship six palettes plus the existing default: Clean Slate, Modern Minimal,
  Sunset Horizon, Supabase, T3 Chat, Vercel.
- `default` means "no overrides", so it stays correct for any style pack
  (vega, nova, ...), not just the default one.
- Selecting a skin works from markup (`data-skin` on `<html>`) and from a
  click on any element carrying `data-basecoat-skin`.
- The choice persists in `localStorage.themeSkin` and applies before LiveView
  mounts.
- CSP-safe: no inline handlers or inline scripts.
- Installer delivers the CSS and wires the import; upgrades keep working.

## Non-goals

- Switching the Basecoat style pack (vega to nova).
- Bundling fonts. Palettes only name font families.
- Shadcn tokens Basecoat does not map (shadows, tracking, spacing).
- A dedicated picker component.

## Approach

Chosen: one vendored CSS file plus a small switcher in `basecoat_live.js`.
The picker is ordinary markup, so no new component API is added. A dedicated
`bc_theme_menu` component was rejected as duplicate dropdown behavior; a
docs-only palette set was rejected because it gives no switching or
persistence.

## Design

### Palette CSS

`priv/basecoat/skins.css`:

- One block per palette: `html[data-skin="clean-slate"]` and
  `html[data-skin="clean-slate"].dark`, and the same for the other five.
- Each block sets the Basecoat tokens: background, foreground, card, popover,
  primary, secondary, muted, accent, destructive, border, input, ring,
  chart 1–5, sidebar colors, plus `--radius`, `--font-sans`, `--font-mono`.
  Tokens Basecoat does not map (serif, shadows, tracking) are skipped.
- Values are pinned from the tweakcn registry on 2026-11-24 and committed.
  No runtime fetch.
- No block for `default`.

### Installer

- Copy `skins.css` to `assets/vendor/basecoat/skins.css`.
- Import it after `basecoat.css` and before `theme.css`, so an app can
  override a palette in its own theme file. `CSS.insert_after/3` keeps the
  step idempotent.

### Switcher

In `priv/basecoat/basecoat_live.js`:

- Apply the stored skin on module load; leave a server-rendered `data-skin`
  alone when nothing is stored.
- Delegated click on `[data-basecoat-skin]`: `default` (or an empty value)
  removes the attribute, anything else sets it.
- Persist to `localStorage.themeSkin`, dispatch `basecoat:skinchange`, and
  sync `aria-checked` on every `[data-basecoat-skin]` radio item so the menu
  shows the active palette.
- Expose `window.basecoat.skin.set/1` and `window.basecoat.skin.current/0`.
- Never re-run `initAll`; this is independent of Basecoat component state.

### Docs

- README Theming: built-in palettes, the attribute, persistence, picker
  example, font loading, overriding a palette.
- `docs/examples.md`: a Themes section with a `bc_dropdown_menu` picker using
  `bc_dropdown_menu_radio_item` and `data-basecoat-skin`.

### Tests

- Assets: every expected palette has a light and a dark selector; the file is
  valid enough to include each token group.
- Installer: copies `skins.css`, imports it between Basecoat CSS and
  `theme.css`, and stays idempotent on a re-run.
- Live JS: contains the attribute, storage key, event name, and API markers.
- Docs drift test still passes.

## Risks

- Fonts named by palettes are not loaded; the docs say so.
- Applying the stored skin on module load can flash the default palette for
  one frame. Removing that needs an inline script, which CSP forbids.
