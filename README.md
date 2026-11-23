# Basecoat Phoenix

[Basecoat](https://basecoatui.com) components for Phoenix LiveView, as `bc_*`
function components with upstream markup, ARIA, and `data-*` attributes intact.

Basecoat 1.2.1 is vendored under `priv/basecoat/`. Installation needs no npm and
no network.

Source: <https://github.com/yadiap/basecoat_phoenix>. Not published on Hex.

## Supported versions

- Elixir `~> 1.15`
- Phoenix `~> 1.8` (1.7 is not supported: it ships Tailwind 3 and a different
  `app.js`)
- `phoenix_live_view ~> 1.2` (`beforeUpdate/1` is required)
- `phoenix_html ~> 4.0`
- Tailwind CSS 4.3+

## Install

Add the dependency to `mix.exs`:

```elixir
defp deps do
  [
    # ...
    {:basecoat_phoenix, git: "https://github.com/yadiap/basecoat_phoenix.git", tag: "v0.3.0"}
  ]
end
```

Then:

```bash
mix deps.get
```

Pin a tag or a commit; the library is pre-1.0 and the API can change between
revisions. To track the default branch instead, drop `tag:`.

Working on the library itself? Point at a local checkout:

```elixir
{:basecoat_phoenix, path: "../basecoat_phoenix"}
```

Run the installer:

```bash
mix basecoat.install
```

It copies the vendored assets into `assets/vendor/basecoat/`, imports the
Basecoat CSS in `assets/css/app.css`, adds the `@source` line that makes Tailwind
scan the components, merges `BasecoatHooks` into `assets/js/app.js`, and creates
`assets/css/theme.css` for your design tokens (see [Theming](#theming)).

The `@source` line points at the library source inside `deps/`. Re-run
`mix basecoat.install` after upgrading the dependency so the path stays correct.
For a local `path:` dependency, pass the real location:

```bash
mix basecoat.install --source-path ../../basecoat_phoenix/lib
```

A stock Phoenix 1.8 app also has daisyUI and a `[data-theme=dark]` variant in
`app.css`. Both collide with Basecoat (`.btn`, `.card`, `.input`, `.badge`, and
dark-mode selectors), so the installer refuses to run until you pass:

```bash
mix basecoat.install --replace-ui
```

That removes every daisyUI plugin block and the `[data-theme=dark]` variant,
then backs up the original `app.css` to `app.css.bak` once. Basecoat dark mode
uses the `html.dark` class instead.

The same flag also replaces the generated
`lib/my_app_web/components/core_components.ex` with the
`BasecoatPhoenix.CoreComponents` drop-in. The installer keeps the module name,
carries over the Gettext backend, and saves the original as
`core_components.ex.bak`. Existing `<.button>`, `<.input>`, `<.table>`,
`<.list>`, `<.header>`, `<.flash>`, and `<.icon>` call sites keep working.

Options: `--style luma|lyra|maia|mira|nova|rhea|sera|vega` (default `vega`),
`--typeset` (also copy `typeset.css`), `--chart` (also copy and load Chart.js),
`--dry-run`, `--core-components` (path override for the drop-in target), and
the path overrides `--assets-path`, `--css`, `--js`, `--source-path`.

## Use

In your `html_helpers`:

```elixir
defp html_helpers do
  quote do
    use BasecoatPhoenix.Components
    # ...
  end
end
```

Then render components:

```heex
<.bc_card>
  <.bc_card_header>
    <.bc_card_title>Team</.bc_card_title>
    <.bc_card_description>Invite your teammates.</.bc_card_description>
    <.bc_card_action>
      <.bc_button variant="outline" size="sm">Edit</.bc_button>
    </.bc_card_action>
  </.bc_card_header>
  <.bc_card_content>No members yet.</.bc_card_content>
  <.bc_card_footer>
    <.bc_button phx-click="invite">Invite</.bc_button>
  </.bc_card_footer>
</.bc_card>
```

Sidebars have one structural rule: render `bc_sidebar` as a sibling before
your content wrapper, so the wrapper immediately follows it and receives the
desktop margin. Keep `bc_sidebar_header`, `bc_sidebar_content`, and
`bc_sidebar_footer` inside `bc_sidebar_nav`. See
[`docs/examples.md`](docs/examples.md#sidebar).

## Theming

Basecoat ships the [shadcn/ui design tokens](https://ui.shadcn.com/docs/theming)
in `:root` and `.dark`, and maps them to Tailwind utilities, so a theme built
for shadcn/ui applies unchanged.

The installer creates `assets/css/theme.css` next to `app.css` and imports it
right after the Basecoat CSS. That file is yours: it is created once and never
overwritten by a re-install.

To apply a theme from [tweakcn](https://tweakcn.com/editor/theme), open
`assets/css/theme.css`, paste the exported `:root` and `.dark` blocks below the
existing rules, and rebuild:

```bash
mix assets.build
```

That covers colors, radius, fonts, shadows, and tracking. Dark mode reads the
`html.dark` class, which is exactly what a `.dark` block expects.

The file also maps the two tokens Basecoat's own theme block omits, so shadcn
snippets that use them work:

- `--font-serif`, the `font-serif` utility.
- `--destructive-foreground`, so `bg-destructive text-destructive-foreground`
  renders the solid destructive pair instead of an unstyled pair.

Fonts named by a theme are not bundled; load them yourself (for example
`@font-face` rules in `app.css`).

## Components

51 upstream components, plus one convenience helper (`bc_spinner`, which
upstream documents as having no dedicated component). Every subcomponent uses
the `bc_` prefix, so nothing collides with Phoenix's `core_components`.

Five upstream pages are patterns, not components, and ship as documented
attributes and utility classes only: Direction, Aspect Ratio, Scroll Area, Data
Table, and Tooltip.

Copy-paste examples for every component are in
[`docs/examples.md`](docs/examples.md). A test fails if a component ships
without an example, so the file stays complete.

## Migrating an existing Phoenix app

Phoenix 1.8 generates `lib/my_app_web/components/core_components.ex` with
daisyUI markup, and every generated template calls `<.button>`, `<.input>`,
`<.table>`, `<.list>`, `<.header>`, `<.flash>`, and `<.icon>`. Run:

```bash
mix basecoat.install --replace-ui
```

It rewrites that file to the three lines below (original saved as
`core_components.ex.bak`) and drops daisyUI from the stylesheet:

```elixir
defmodule MyAppWeb.CoreComponents do
  @moduledoc "Basecoat-backed core components."
  use BasecoatPhoenix.CoreComponents, gettext_backend: MyAppWeb.Gettext
end
```

Nothing else changes: `MyAppWeb` keeps `import MyAppWeb.CoreComponents`, and no
template is edited. Same function names, same attributes, same slots, same
`translate_error/1` and `translate_errors/2`, same `show/2` and `hide/2` JS
commands. The installer carries over your module name and Gettext backend; if
the file is already migrated, it leaves it alone. Basecoat's dark mode uses
`html.dark`, not `[data-theme=dark]`.

Kept as-is, on purpose:

- `icon/1` still takes `hero-*` names and emits the class for the Heroicons
  Tailwind plugin that `phx.new` configures. Basecoat's own components use
  Lucide icons. Both can coexist until you drop the plugin.
- `show/2` and `hide/2` are `Phoenix.LiveView.JS` transitions, not styling.

Changed on purpose:

- A caller `class` is appended to the Basecoat classes instead of replacing
  them, so `class="w-full"` no longer silently drops `btn`.
- `:error_class` is accepted and ignored. Basecoat styles invalid inputs through
  `aria-invalid`, so there is no error class to override.

New UI should use the `bc_*` components directly; the drop-in exists so old
templates keep working while you move.

## CSP

No library markup contains an inline `onclick`, `onsubmit`, or other handler
attribute. Clicks route through `data-basecoat-*` attributes handled by the
vendored `basecoat_live.js`, so a `script-src` policy without `unsafe-inline`
works.

## Client state

Basecoat owns client state: open menus, the active tab, the selected value, the
drawer visibility. The library renders initial state only. The `BasecoatState`
hook snapshots the DOM before a patch and restores anything the server did not
deliberately change, so an open dropdown or a switched tab survives an unrelated
assign update.

Escape hatch: a server render equal to the client's original value cannot be
told apart from "unchanged". To force a client-owned value back, change a nonce
attribute on the component root or re-render the subtree.

## Charts

`bc_chart` renders a bare `<canvas>` plus the `data-chart-*` configuration. The
app must load Chart.js and Basecoat's chart script before the chart hook runs.
Without them, the console logs one clear error and the page still renders.

Let the installer vendor both:

```bash
mix basecoat.install --chart
```

That copies Chart.js 4.6.1 and Basecoat's chart script into
`assets/vendor/basecoat/` (`chartjs.js` and `chart.js`) and imports both in
`assets/js/app.js`. Loading Chart.js another way works too; the hook only needs
`window.Chart`.

## Toasts

Add one `<.bc_toaster />` near the end of the body, then push from the server:

```elixir
def handle_event("save", _params, socket) do
  {:noreply, BasecoatPhoenix.Toast.push(socket, category: :success, title: "Saved")}
end
```

The toaster is a single fixed `#toaster`, so toasts reach it from nested
LiveViews too. `:action` and `:cancel` accept `:label` and `:href` only; no
`onclick` is emitted.

## Verification

`mix test` covers component markup, installer behavior, and the client helpers.
Behavior that needs a browser (overlay focus, patch preservation, scroll
snapping) is listed in [`docs/manual-verification.md`](docs/manual-verification.md).

## License

MIT. Basecoat is MIT, copyright hunvreus; its license is vendored at
`priv/basecoat/LICENSE`.
