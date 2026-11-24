# Built-in Theme Palettes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship six switchable color palettes with a CSP-safe switcher that persists the choice.

**Architecture:** One vendored `skins.css` holds every palette behind `html[data-skin="…"]` and `html[data-skin="…"].dark`. The installer copies it and imports it between Basecoat CSS and the app's `theme.css`. `basecoat_live.js` applies a stored skin, switches on clicks inside `[data-basecoat-skin]`, and syncs radio state.

**Tech Stack:** Elixir, Phoenix LiveView, plain CSS custom properties, vanilla ES modules.

**Spec:** `docs/superpowers/specs/2026-11-24-built-in-themes-design.md`

## Global Constraints

- Palette values are pinned from `https://tweakcn.com/r/themes/<id>.json` as of 2026-11-24; no runtime fetch.
- Skin ids: `clean-slate`, `modern-minimal`, `sunset-horizon`, `supabase`, `t3-chat`, `vercel`. `default` has no CSS block.
- Attribute is `data-skin` on `<html>`; picker elements carry `data-basecoat-skin`.
- Storage key is `themeSkin`; event is `basecoat:skinchange`.
- No inline handlers, no inline scripts, no new dependencies.
- Installer import order: `basecoat.css`, `skins.css`, `theme.css`.

## Review Focus

- Stored or clicked skin that matches no palette: page must fall back to Basecoat tokens, not break.
- `default` selection: attribute must be removed, not left as `data-skin="default"`.
- Server-rendered `data-skin` with empty storage: boot must not remove it.
- Dark mode with a skin: `html[data-skin="x"].dark` must win over both `.dark` and the light skin block.
- `localStorage` blocked: load and switching must still work for the session.

---

### Task 1: Palette CSS

**Files:**
- Create: `priv/basecoat/skins.css`
- Modify: `test/basecoat_phoenix/assets_test.exs` (append one test)

**Interfaces:**
- Produces: selectors `html[data-skin="<id>"]` and `html[data-skin="<id>"].dark` for the six ids, each setting the Basecoat token names used by `basecoat-vega.bundle.css`.

- [ ] **Step 1: Write the failing test**

Append to `test/basecoat_phoenix/assets_test.exs`:

```elixir
@skins ~w(clean-slate modern-minimal sunset-horizon supabase t3-chat vercel)

test "skins.css ships every palette in light and dark" do
  dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])
  css = File.read!(Path.join(dir, "skins.css"))

  for skin <- @skins do
    assert css =~ ~s|html[data-skin="#{skin}"] {|
    assert css =~ ~s|html[data-skin="#{skin}"].dark {|
  end

  refute css =~ ~s|html[data-skin="default"]|

  for token <- ~w(--background --foreground --card --card-foreground --popover
                 --popover-foreground --primary --primary-foreground --secondary
                 --secondary-foreground --muted --muted-foreground --accent
                 --accent-foreground --destructive --border --input --ring
                 --chart-1 --chart-5 --sidebar --sidebar-ring --radius
                 --font-sans --font-mono) do
    assert css =~ token
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/basecoat_phoenix/assets_test.exs`
Expected: FAIL with `File.read!` error for `skins.css`.

- [ ] **Step 3: Generate `priv/basecoat/skins.css`**

One-off generator; run it from the repo root. It reads the registry, writes committed CSS, and does not ship.

```python
import json, urllib.request

skins = ["clean-slate", "modern-minimal", "sunset-horizon", "supabase", "t3-chat", "vercel"]

colors = """background foreground card card-foreground popover popover-foreground
primary primary-foreground secondary secondary-foreground muted muted-foreground
accent accent-foreground destructive border input ring
chart-1 chart-2 chart-3 chart-4 chart-5 sidebar sidebar-foreground
sidebar-primary sidebar-primary-foreground sidebar-accent
sidebar-accent-foreground sidebar-border sidebar-ring""".split()

extras = ["radius", "font-sans", "font-mono"]

lines = [
    "/* Basecoat built-in palettes.",
    " * Select one with <html data-skin=\"name\">. No block for `default`.",
    " * Values pinned from https://tweakcn.com on 2026-11-24.",
    " */",
    "",
]

for skin in skins:
    url = f"https://tweakcn.com/r/themes/{skin}.json"
    data = json.load(urllib.request.urlopen(url))
    theme = data["cssVars"].get("theme", {})

    for selector, key in (
        (f'html[data-skin="{skin}"]', "light"),
        (f'html[data-skin="{skin}"].dark', "dark"),
    ):
        values = data["cssVars"][key]
        lines.append(f"{selector} {{")
        for token in colors + extras:
            value = values.get(token) or theme.get(token)
            if value:
                lines.append(f"  --{token}: {value};")
        lines.append("}")
        lines.append("")

open("priv/basecoat/skins.css", "w").write("\n".join(lines).rstrip() + "\n")
```

Expected: 12 blocks, light then dark per skin, `default` absent.

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/basecoat_phoenix/assets_test.exs`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add priv/basecoat/skins.css test/basecoat_phoenix/assets_test.exs
git commit -m "feat: add built-in theme palettes"
```

---

### Task 2: Installer delivery

**Files:**
- Modify: `lib/basecoat_phoenix/installer.ex:94-108` (import order) and `:132-141` (`copies/3`)
- Modify: `test/basecoat_phoenix/installer_test.exs:62-76` and `:93-105`

**Interfaces:**
- Consumes: `priv/basecoat/skins.css` from Task 1.
- Produces: `assets/vendor/basecoat/skins.css` and the app.css import line `@import "../vendor/basecoat/skins.css";` between the Basecoat and theme imports.

- [ ] **Step 1: Update the failing installer tests**

In `test/basecoat_phoenix/installer_test.exs`, change the adjacency assertion in `"creates theme.css and imports it after the Basecoat CSS"` to:

```elixir
assert css =~
         ~s|@import "../vendor/basecoat/basecoat.css";\n@import "../vendor/basecoat/skins.css";\n@import "./theme.css";|
```

Add to `"copies the pinned assets and patches the CSS"`:

```elixir
assert File.exists?(Path.join(vendor, "skins.css"))
```

Add a new test:

```elixir
test "imports skins.css once", ctx do
  assert {:ok, _} = install(ctx)
  assert {:ok, _} = install(ctx)

  css = File.read!(ctx.css_path)
  assert length(String.split(css, ~s|@import "../vendor/basecoat/skins.css";|)) == 2
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `mix test test/basecoat_phoenix/installer_test.exs`
Expected: FAIL on the missing file and the old import order.

- [ ] **Step 3: Implement the copy and import**

In `copies/3`, add to the base list:

```elixir
{Path.join(priv, "skins.css"), Path.join(vendor, "skins.css")},
```

In `build/10`, add a `skins_css` path and insert it after the Basecoat import. Insert the theme import first, then skins, so the final order is Basecoat, skins, theme:

```elixir
skins_css = relative(Path.join(vendor, "skins.css"), css_dir)

css =
  css
  |> CSS.insert_after(@tailwind_import, ~s(@import "#{basecoat_css}";))
  |> CSS.insert_after(~s(@import "#{basecoat_css}";), @theme_import)
  |> CSS.insert_after(~s(@import "#{basecoat_css}";), ~s(@import "#{skins_css}";))
  |> append_once(~s(@source "#{source_path}";))
  |> maybe_typeset(opts, vendor, css_dir, basecoat_css)
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `mix test test/basecoat_phoenix/installer_test.exs`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/basecoat_phoenix/installer.ex test/basecoat_phoenix/installer_test.exs
git commit -m "feat: install the built-in palettes"
```

---

### Task 3: Switcher

**Files:**
- Modify: `priv/basecoat/basecoat_live.js` (constants near the top, click handler, module-load block, `syncRuntime`)
- Modify: `test/basecoat_phoenix/live_js_test.exs` (append one test)
- Modify: `docs/manual-verification.md` (append browser checks)

**Interfaces:**
- Consumes: `data-skin` selectors from Task 1.
- Produces: `window.basecoat.skin.set(name)` and `window.basecoat.skin.current()`; click handling for `[data-basecoat-skin]`; `basecoat:skinchange` with `detail.skin`.

- [ ] **Step 1: Write the failing test**

Append to `test/basecoat_phoenix/live_js_test.exs`:

```elixir
test "switches and persists skins", %{js: js} do
  assert js =~ "data-basecoat-skin"
  assert js =~ ~s|localStorage.getItem(SKIN_KEY)|
  assert js =~ ~s|localStorage.setItem(SKIN_KEY|
  assert js =~ ~s|const SKIN_KEY = "themeSkin"|
  assert js =~ "basecoat:skinchange"
  assert js =~ "window.basecoat.skin"
  assert js =~ "aria-checked"
  assert js =~ "delete document.documentElement.dataset.skin"
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/basecoat_phoenix/live_js_test.exs`
Expected: FAIL on the first missing marker.

- [ ] **Step 3: Implement the switcher**

Add near the top constants:

```js
const SKIN_KEY = "themeSkin";
const SKIN_SELECTOR = "[data-basecoat-skin]";

const storedSkin = () => {
  try {
    return localStorage.getItem(SKIN_KEY);
  } catch {
    return null;
  }
};

const currentSkin = () => document.documentElement.dataset.skin || "default";

const syncSkinItems = () => {
  const active = currentSkin();
  document.querySelectorAll(SKIN_SELECTOR).forEach((item) => {
    const name = item.getAttribute("data-basecoat-skin") || "default";
    item.setAttribute("aria-checked", name === active ? "true" : "false");
  });
};

const setSkin = (name) => {
  const skin = !name || name === "default" ? null : name;

  if (skin) document.documentElement.dataset.skin = skin;
  else delete document.documentElement.dataset.skin;

  try {
    localStorage.setItem(SKIN_KEY, skin || "default");
  } catch {}

  syncSkinItems();
  document.dispatchEvent(
    new CustomEvent("basecoat:skinchange", { detail: { skin: skin || "default" } }),
  );
};

const applyStoredSkin = () => {
  const stored = storedSkin();
  if (stored !== null) setSkin(stored);
};
```

In `handleClick`, before the theme branch:

```js
const skin = event.target.closest?.(SKIN_SELECTOR);
if (skin) return setSkin(skin.getAttribute("data-basecoat-skin"));
```

At module load, inside the existing `if (typeof document !== "undefined")` block, call:

```js
applyStoredSkin();
```

In `syncRuntime`'s `setTimeout` callback, after `initAll`, add:

```js
syncSkinItems();
if (window.basecoat) window.basecoat.skin = { set: setSkin, current: currentSkin };
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/basecoat_phoenix/live_js_test.exs`
Expected: PASS.

- [ ] **Step 5: Add the browser checks**

Append to `docs/manual-verification.md`:

```markdown
### Built-in palettes

1. Click a palette in the theme menu: colors, radius, and font change at once.
2. Reload: the same palette is still applied.
3. Click Default: `data-skin` disappears and Basecoat tokens return.
4. Toggle dark mode with a palette active: the palette's dark block applies.
5. Set `data-skin="nope"` in DevTools and reload: the page renders with
   Basecoat tokens and no console error.
6. Render `<html data-skin="supabase">` with storage cleared: it survives boot.
7. Block storage for the site and switch palettes: switching works until reload.
```

- [ ] **Step 6: Commit**

```bash
git add priv/basecoat/basecoat_live.js test/basecoat_phoenix/live_js_test.exs docs/manual-verification.md
git commit -m "feat: switch and persist built-in palettes"
```

---

### Task 4: Documentation

**Files:**
- Modify: `README.md` (Theming section)
- Modify: `docs/examples.md` (new `## Themes` section after Theme switcher)
- Modify: `test/basecoat_phoenix/examples_test.exs` only if a guard fails

**Interfaces:**
- Consumes: palette ids from Task 1, click contract from Task 3.

- [ ] **Step 1: Add the README subsection**

After the tweakcn paragraph in `## Theming`, add:

- The six built-in ids and that `default` has no overrides.
- `data-skin` on `<html>` and `data-basecoat-skin` on a clickable element.
- `localStorage.themeSkin`, `basecoat:skinchange`, `window.basecoat.skin`.
- Override rule: target `html[data-skin="…"]` in `theme.css`.
- Fonts are named, not bundled.

- [ ] **Step 2: Add the examples section**

Insert after `## Theme switcher`:

````markdown
## Themes

Built-in palettes: `default`, `clean-slate`, `modern-minimal`,
`sunset-horizon`, `supabase`, `t3-chat`, `vercel`.

```heex
<.bc_dropdown_menu id="theme-menu">
  <.bc_dropdown_menu_trigger id="theme-menu" variant="outline" size="sm">
    Theme
  </.bc_dropdown_menu_trigger>
  <.bc_dropdown_menu_content id="theme-menu" class="w-44">
    <.bc_dropdown_menu_group id="theme-menu-list" label="Theme">
      <.bc_dropdown_menu_radio_item data-basecoat-skin="default">Default</.bc_dropdown_menu_radio_item>
      <.bc_dropdown_menu_radio_item data-basecoat-skin="clean-slate">Clean Slate</.bc_dropdown_menu_radio_item>
      <.bc_dropdown_menu_radio_item data-basecoat-skin="modern-minimal">Modern Minimal</.bc_dropdown_menu_radio_item>
      <.bc_dropdown_menu_radio_item data-basecoat-skin="sunset-horizon">Sunset Horizon</.bc_dropdown_menu_radio_item>
      <.bc_dropdown_menu_radio_item data-basecoat-skin="supabase">Supabase</.bc_dropdown_menu_radio_item>
      <.bc_dropdown_menu_radio_item data-basecoat-skin="t3-chat">T3 Chat</.bc_dropdown_menu_radio_item>
      <.bc_dropdown_menu_radio_item data-basecoat-skin="vercel">Vercel</.bc_dropdown_menu_radio_item>
    </.bc_dropdown_menu_group>
  </.bc_dropdown_menu_content>
</.bc_dropdown_menu>
```

Any element with `data-basecoat-skin` switches the palette; the radio item is
the menu-friendly choice. The choice is stored in `localStorage.themeSkin` and
applied on the next load. `default` removes the attribute and restores the
style pack's own tokens. Dark mode uses the palette's dark block. Fonts named
by a palette are not bundled; load them yourself.

Attrs: no component attributes beyond `data-basecoat-skin` on the item.
````

- [ ] **Step 3: Run the docs and full tests**

Run: `mix test`
Expected: PASS, including the examples drift guard.

- [ ] **Step 4: Commit**

```bash
git add README.md docs/examples.md
git commit -m "docs: document the built-in palettes"
```

---

### Task 5: Final verification

- [ ] **Step 1: Run the gates**

```bash
mix format --check-formatted
mix test
mix compile --warnings-as-errors --force
mix docs
```

Expected: format clean, 183+ tests pass, no warnings from compile, docs build with only the pre-existing `docs/manual-verification.md` link warning.

- [ ] **Step 2: Push**

```bash
git push origin main
```
