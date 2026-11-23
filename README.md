# Basecoat Phoenix

[Basecoat](https://basecoatui.com) components for Phoenix LiveView, as `bc_*`
function components with upstream markup, ARIA, and `data-*` attributes intact.

Basecoat 1.2.1 is vendored under `priv/basecoat/`. Installation needs no npm and
no network.

## Supported versions

- Elixir `~> 1.15`
- Phoenix `~> 1.8` (1.7 is not supported: it ships Tailwind 3 and a different
  `app.js`)
- `phoenix_live_view ~> 1.2` (`beforeUpdate/1` is required)
- `phoenix_html ~> 4.0`
- Tailwind CSS 4.3+

## Install

Add the dependency:

```elixir
{:basecoat_phoenix, path: "../basecoat_phoenix"}
```

Run the installer:

```bash
mix basecoat.install
```

It copies the vendored assets into `assets/vendor/basecoat/`, imports the
Basecoat CSS in `assets/css/app.css`, adds the `@source` line that makes Tailwind
scan the components, and merges `BasecoatHooks` into `assets/js/app.js`.

A stock Phoenix 1.8 app also has daisyUI and a `[data-theme=dark]` variant in
`app.css`. Both collide with Basecoat (`.btn`, `.card`, `.input`, `.badge`, and
dark-mode selectors), so the installer refuses to run until you pass:

```bash
mix basecoat.install --replace-ui
```

That removes every daisyUI plugin block and the `[data-theme=dark]` variant,
then backs up the original `app.css` to `app.css.bak` once. Basecoat dark mode
uses the `html.dark` class instead.

Options: `--style luma|lyra|maia|mira|nova|rhea|sera|vega` (default `vega`),
`--typeset` (also copy `typeset.css`), `--dry-run`.

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

## Components

51 upstream components, plus one convenience helper (`bc_spinner`, which
upstream documents as having no dedicated component). Every subcomponent uses
the `bc_` prefix, so nothing collides with Phoenix's `core_components`.

Five upstream pages are patterns, not components, and ship as documented
attributes and utility classes only: Direction, Aspect Ratio, Scroll Area, Data
Table, and Tooltip.

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
app must load Chart.js before the chart hook runs. Without it, the console logs
one clear error and the page still renders.

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
