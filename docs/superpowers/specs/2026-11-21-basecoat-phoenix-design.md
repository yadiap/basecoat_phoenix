# Basecoat Phoenix — Design

Date: 2026-11-21 (revised 2026-11-22)
Status: approved approach, design pending approval
Verified against: Basecoat 1.2.1 (latest npm/GitHub release, published 2026-11-21), Phoenix 1.8.17, Phoenix LiveView 1.2.15, phoenix_html 4.4.0.

## Intent

A standalone Elixir library that makes [Basecoat](https://basecoatui.com) (shadcn/ui's markup and design system, implemented as plain HTML/CSS plus small vanilla JS) usable from Phoenix LiveView without writing raw Basecoat markup by hand.

The library is for the author's own Phoenix app. It is a dependency, not an ejected component dump: the app adds `basecoat_phoenix`, runs one installer task, and imports the components.

Upstream pinned version: **Basecoat 1.2.1** (`hunvreus/basecoat`).

## Why

Basecoat is HTML-first: a component is a class plus documented `data-*` attributes, and 15 small JS controllers provide the interactive behavior. That maps well to Phoenix function components, but three integration problems are real:

1. **Assets.** Basecoat ships Tailwind 4 source bundles and JS controllers. A Phoenix app needs them in its asset pipeline without adding npm.
2. **LiveView lifecycle.** Basecoat initializes on `DOMContentLoaded`, observes inserted nodes, and destroys removed nodes. LiveView patches, streams, reconnects, and reused DOM need explicit handling.
3. **Event bridging.** Select and combobox write hidden inputs and dispatch a custom `change` event that LiveView's form handling does not see. Dialog/drawer/toast are client-side APIs with no server counterpart.

## Goals

- One `mix basecoat.install` command wires CSS, JS, Tailwind scanning, and LiveView hooks into a Phoenix 1.8 app.
- Every Basecoat component available as a `bc_*` Phoenix function component, matching upstream markup, ARIA, and `data-*` contracts: 51 upstream components plus one convenience helper (`bc_spinner`, which upstream documents as having no dedicated component). The 5 pattern pages ship as documented attributes/utilities, not invented components.
- Server-side form values and LiveView events work for every form control.
- No Node/npm dependency for installation. Optional Chart.js is app-supplied. No inline `onclick` in library markup (CSP-safe).
- Pinned upstream assets are vendored; installation never needs the network.
- Per-component render tests and installer tests.

## Non-goals

- Reimplementing Basecoat CSS or JS behavior in Elixir.
- Server-owned state for tabs, accordion, popover, dropdown, sidebar, or carousel. Basecoat JS owns that state.
- Portalled overlays. Basecoat positions inline; the library keeps that.
- Bundling an icon set. Basecoat does not ship icons; the library renders only the built-in affordances it needs (chevron, close, check, loader, sun/moon) and accepts `:icon` slots elsewhere.
- Chart.js. `bc_chart` renders the canvas and config; the app supplies Chart.js.
- Server-persisted theme preference.
- Ejecting component source into the app (explicitly rejected; dependency import chosen).
- Tailwind-free apps. The installer targets the standard Phoenix Tailwind 4 build.
- Phoenix < 1.8. Stock Phoenix 1.7 generates Tailwind 3 and a different `app.js`; supporting it would fork the installer and asset pipeline. Apps on 1.7 must upgrade first.
- Phoenix LiveView < 1.2.

## Anti-goals

- Diverging from upstream class names or markup structure.
- Auto-generated component ids that change between renders.
- A second JavaScript component system layered over Basecoat's.
- Hiding integration failures behind rescue/no-op fallbacks.

## Constraints

- Elixir `~> 1.15`; Phoenix `~> 1.8`; `phoenix_live_view ~> 1.2`; `phoenix_html ~> 4.0`.
- LiveView 1.2 is required for the `beforeUpdate(toEl)` hook callback, which is used to distinguish server-driven attribute changes from client-owned Basecoat state.
- Tailwind CSS 4.3+ (Basecoat's requirement; Phoenix 1.8 default).
- Phoenix 1.8's generated `app.css` ships daisyUI and a `[data-theme=dark]` dark variant. Both collide with Basecoat (`.btn`, `.card`, `.input`, `.badge`, ... and dark-mode selectors), so the installer must detect and explicitly replace them.
- Basecoat 1.2.1 asset files are committed under `priv/basecoat/` with a version file and MIT license.
- The installer must be idempotent and must not corrupt a hand-edited `app.css`/`app.js`.

## Approaches Considered

### Component API

| Option | Trade-off |
| --- | --- |
| **A. One module per component, umbrella `use` (chosen)** | Navigable, per-file tests, selective imports possible. Slightly more files. |
| B. One monolithic `BasecoatPhoenix.Components` | Fewer files; unmaintainable at 51 components and slow to navigate. |
| C. Generate components from upstream docs | Fragile parser, unreadable generated output, loses hand-written docs. |

### Asset delivery

| Option | Trade-off |
| --- | --- |
| **A. Vendor Basecoat's uncompiled bundle, Tailwind `@source` (chosen)** | No npm; utilities used by library markup are generated; requires a Tailwind build (Phoenix default). |
| B. Vendor compiled CDN CSS | No Tailwind interaction, but utility classes used in component markup may be missing. |
| C. Require `npm install basecoat-css` | Best upstream tracking; adds Node to an Elixir library and a second install step. |

### LiveView behavior

| Option | Trade-off |
| --- | --- |
| **A. Basecoat JS owns client state; hooks bridge events and preserve state (chosen)** | Preserves upstream behavior and accessibility; needs a state-preservation hook so morphdom does not wipe Basecoat's attributes. |
| B. Reimplement tabs/accordion/select server-side | Full server control; throws away Basecoat JS and doubles the work. |

## Architecture

### Repository layout

```text
basecoat_phoenix/
├── lib/
│   ├── basecoat_phoenix.ex
│   ├── basecoat_phoenix/
│   │   ├── components.ex              # use BasecoatPhoenix.Components
│   │   ├── components/                # one module per component
│   │   │   ├── accordion.ex
│   │   │   ├── ...
│   │   │   └── trace.ex
│   │   └── toast.ex                   # server-side toast helper
│   └── mix/tasks/basecoat.install.ex
├── priv/
│   └── basecoat/
│       ├── VERSION                    # 1.2.1
│       ├── LICENSE                    # upstream MIT
│       ├── basecoat-vega.bundle.css   # 8 style packs
│       ├── basecoat-nova.bundle.css
│       ├── ...
│       ├── all.min.js
│       ├── chart.min.js
│       ├── typeset.css
│       └── basecoat_live.js           # library-owned LiveView glue
├── test/
└── docs/
```

`BasecoatPhoenix.Components` defines `__using__/1` that imports every component module:

```elixir
defmodule MyAppWeb do
  def html_helpers do
    quote do
      use BasecoatPhoenix.Components
    end
  end
end
```

Individual modules remain importable: `import BasecoatPhoenix.Components.Button`.

### Naming

All components use a `bc_` prefix (`<.bc_button>`, `<.bc_card_header>`). This avoids collisions with Phoenix's generated `core_components` (`<.button>`, `<.input>`, `<.table>`, ...) when both are imported in `html_helpers`.

### Component conventions

- Every component accepts `attr :class, :string` and `attr :rest, :global`. A component with an upstream class merges `["base-class", @class]`; a class-less semantic subcomponent passes `@class` through unchanged. `{@rest}` is spread on the upstream root element only.
- Variants and sizes use `attr :variant` / `attr :size` with `values:`. Default values omit the `data-*` attribute, matching upstream markup.
- Link-capable components (`bc_button`, pagination links, menu items) render `<a>` when `href` is present, otherwise `<button type="button">`.
- Components with linked ARIA ids (`bc_dialog`, `bc_drawer`, `bc_select`, `bc_combobox`, `bc_dropdown_menu`, `bc_popover`, `bc_command`, `bc_command_dialog`) require an explicit `id`; derived ids use suffixes (`"#{id}-title"`, `"#{id}-trigger"`). `bc_tabs` requires an explicit `id`, but tab and panel ids are caller-supplied (`bc_tab` takes `id`/`panel`; `bc_tab_panel` takes `id`/`labelledby`) and are never derived. No runtime-generated ids. `bc_input_otp` takes an `id` for its root/label wiring; upstream defines no linked ARIA ids for it.
- Form controls accept either `field={@form[:name]}` (a `Phoenix.HTML.FormField`) or explicit `name`/`value`. The field form derives `name`, `id`, `value`, errors, `aria-invalid`, and `aria-describedby`. A shared `BasecoatPhoenix.Field` helper normalizes both forms so every control behaves the same.
- `bc_field` and `bc_field_error` accept `field` or `errors`; errors render with the upstream field error markup.
- Upstream feature coverage is part of the API, not left to raw `data-*` passthrough. Structural features are implemented: select/combobox multiple + groups + disabled options + `format`, tabs `variant` + orientation + disabled + initial active, command `data-force` + `data-keep-command-open` + `data-filter="manual"`, sidebar side/initial state/breakpoint, OTP filter/pattern/length, toggle-group single/multiple, slider min/max/step. Arbitrary upstream `data-*` attributes still pass through `{@rest}`.
- Multiple select/combobox values are JSON-encoded by Basecoat. `bc_select`/`bc_combobox` accept an Elixir list for `value` and encode it; `BasecoatPhoenix.Forms.decode_multi/1` decodes the submitted JSON string (and `data-format="object"` maps) into Elixir values. Single values stay strings.
- Purely structural components expose subcomponents (`bc_card` + `bc_card_header` + ...), matching upstream markup.
- Trivial semantic subcomponents (tag + optional class + slot, e.g. `bc_card_header`, `bc_item_title`, `bc_alert_description`) are declared with one shared `defsemantic` macro. It emits the upstream tag, adds a class only when one is given, and spreads `{@rest}`. One module per component is kept; only the bodies collapse.
- Icons: built-in affordances are inline Lucide SVGs. Other icon positions accept a `:icon` slot; the library does not install an icon package.
- No inline event handler attributes in library output. Dialog/drawer/theme actions use `data-basecoat-*` hooks handled by `basecoat_live.js`; LiveView actions use normal `phx-*` attributes passed through `{@rest}`.

### Markup fidelity

Basecoat is HTML-first: styling and behavior come from exact tags, classes, roles, aria attributes, and `data-*` attributes. Every component renders the upstream structure verbatim.

- Tag names, nesting order, classes, `role`, `aria-*`, and `data-*` match the upstream docs for that component. No extra wrapper element and no invented `*-content` or `*-media` class.
- Subcomponents are render helpers for individual upstream tags. `bc_card_header` renders `<header>`; `bc_item_content` renders `<section>`; `bc_empty_title` renders `<h3>`. A helper adds no class unless upstream adds one.
- Upstream native elements stay native: `<dialog>`, `<details>/<summary>`, `<input type="range">`, `<table>`, `<ol>/<li>`, `<hr role="separator">`.
- Allowed additions, and only these: `phx-hook`, stable `id`s, `data-basecoat-dialog-open|close`, `data-basecoat-drawer-open|close`, `data-basecoat-sidebar-toggle`, `data-basecoat-theme-toggle`, and LiveView attributes passed through `{@rest}`.
- Where upstream documents a pattern instead of a class or controller (Direction, Aspect Ratio, Scroll Area, Data Table, Tooltip), the library documents the pattern. It does not invent a component, class, or wrapper.
- The upstream docs are the markup contract. Each component test asserts its rendered tree against the corresponding doc example; drift is a test failure, not a documentation note.

### LiveView DOM state preservation

This is the core integration problem. LiveView's morphdom patch removes attributes that the server did not render and resets form-control properties. Basecoat's state lives in exactly those places: `data-*-initialized`, `data-basecoat-component`, `aria-expanded`, `aria-hidden`, `aria-selected`, `hidden`, `open`, option classes, and hidden-input values. Without mitigation, any unrelated LiveView update closes menus, resets tabs, and loses select values.

The library ships a `BasecoatState` LiveView hook, exported from `basecoat_live.js` and attached automatically by every stateful component:

- Stateful roots get `phx-hook="BasecoatState"` and a required `id`. The root is the whole preservation scope: no marker attributes, no key attributes.
- `mounted`: record a baseline snapshot of the root and its subtree: attributes and the form properties `value`, `checked`, `selectedIndex`, `open`. LiveView-owned attributes (`phx-*`, `data-phx-*`) are never snapshotted or restored. Any root `<dialog>` already open is opened modally here (`showModal()` when it is not already `:modal`).
- Element identity is `id`, then `name`, then the index among same-tag siblings. Absolute position is never part of the key, so inserting or removing a sibling does not shift matching.
- `beforeUpdate(toEl)`: snapshot the current client state, snapshot the incoming server element, and diff the incoming server state against the baseline, treating presence and absence as values. Attributes/properties the server actually changed win; everything else is restored to the client value, including attributes the client removed. Elements are looked up again in `updated`, never assumed to be the same node object.
- `updated`: restore client attributes and properties, run overlay sync, call `window.basecoat.refresh(this.el)` once, then make the incoming server snapshot the new baseline.
- Overlay sync applies to every root `<dialog>` in the scope: `.dialog`, `.alert-dialog`, `.drawer`, `.sheet`, and `.command-dialog`. It opens modally when the server changes `open` to true and closes when the server changes it to false, guarded by `el.open` and `el.matches(":modal")`. Basecoat ships no dialog controller at all (verified in `all.js`), so the hook owns `showModal()`/`close()` for all five. Basecoat's drawer controller still owns cancel and backdrop for `.drawer`/`.sheet`; the hook owns backdrop click for the other three.
- Baseline limitation: a server render equal to the client's original value is indistinguishable from "unchanged". To force a client-owned value back, change a nonce attribute on the root or re-render the subtree; this escape hatch is documented in the README.

This preserves Basecoat's initialized markers (so components are not initialized twice), keeps open menus/tabs/dialogs open across unrelated patches, and still lets the server change a value deliberately.

`window.basecoat.refresh(el)` is the only refresh entry point needed. Basecoat registers a `refresh` function for exactly five components (`select`, `combobox`, `dropdown-menu`, `command`, `tabs`) and dispatches on `dataset.basecoatComponent`; every other component returns silently. The select and combobox refresh paths run with `triggerEvent = false`, so a refresh never emits `change` and cannot loop back into a LiveView event. It also re-creates the client-inserted `.combobox-chips` wrapper in a multiple combobox after a patch removed it (`ensureMultipleInputSurface`). It requires LiveView 1.2's `beforeUpdate(toEl)`.

Attached to: `bc_accordion`, `bc_collapsible`, `bc_dialog`, `bc_alert_dialog`, `bc_drawer`, `bc_sheet`, `bc_tabs`, `bc_select`, `bc_combobox`, `bc_dropdown_menu`, `bc_popover`, `bc_sidebar`, `bc_carousel`, `bc_command`, `bc_command_dialog`, `bc_slider`. `bc_chart` carries `BasecoatChart`; `bc_input_otp` and `bc_toaster` use `phx-update="ignore"`.

`phx-update="ignore"` is used instead of the hook where the client owns DOM content inside the element:

- `bc_toaster`: Basecoat inserts `<li class="toast">` nodes; a server patch of an empty `<ol>` would delete them.
- `bc_input_otp`: Basecoat writes each character into the pre-rendered slot spans (`:scope > div > div > span`) and toggles `data-active`/`data-caret` on them. A patch would fight that client state, so `phx-update="ignore"` keeps the slots intact. The input still submits normally.

Native form controls (`bc_input`, `bc_textarea`, `bc_checkbox`, `bc_radio_group`, `bc_switch`, `bc_toggle`, `bc_native_select`) keep standard LiveView form semantics; the app controls them with `phx-change`/assigns as usual. `bc_slider` is also a native control, but carries `BasecoatState` so the `--slider-value` style Basecoat computes survives a patch. Because Basecoat's range controller listens to `input` only and has no registry refresh, `bc_slider` also server-renders `style="--slider-value: N%"` from `value`/`min`/`max`; the diff then repaints the fill after a server-side value change.

### Component inventory

51 upstream components plus 1 convenience helper cover the 57 upstream doc pages. Five pages are patterns that add no class or controller of their own: Direction, Aspect Ratio, Scroll Area, Data Table, and Tooltip. One page, Spinner, documents that Basecoat has no dedicated component; `bc_spinner` is the library's only convenience helper and renders the upstream loader SVG markup. Typeset is stylesheet-only. Grouped by module:

**Actions and input**

| Upstream | Modules |
| --- | --- |
| Button | `bc_button` (`variant`/`size` render `data-variant`/`data-size`, omitted at defaults; `href` renders `<a>`) |
| Button Group | `bc_button_group` (`<div class="button-group" role="group">`) |
| Toggle | `bc_toggle` (`<label class="btn" data-variant data-size>`, optional `has-checked:[&_svg]:fill-current`; native `<input type="checkbox|radio">` inside) |
| Toggle Group | `bc_toggle_group` (`<fieldset>` + `<legend class="sr-only">`), `bc_toggle_group_item` (`<label class="btn" data-variant data-size>` + native input) |
| Checkbox | `bc_checkbox` (`<div class="fieldset" role="group">` > `<div class="field" role="group" data-orientation="horizontal">` > `<input class="input" type="checkbox">` + `<label for>`; optional `<section>` with label + `<p>`) |
| Radio Group | `bc_radio_group` (`<div role="radiogroup" aria-label data-slot="radio-group">`), `bc_radio_group_item` (`<div class="flex items-center gap-3">` + `<input class="input" type="radio">` + `<label for>`) |
| Switch | `bc_switch` (`<div class="field" role="group" data-orientation="horizontal">` + `<input class="input" type="checkbox" role="switch">` + `<label for>`) |
| Input | `bc_input` (`<input class="input">`) |
| Textarea | `bc_textarea` (`<textarea class="textarea">`) |
| Native Select | `bc_native_select` (`<select class="select">` + `<option>` children) |
| Select | `bc_select` (`<div class="select" data-placeholder>` > `<button aria-haspopup="listbox" aria-expanded="false" aria-controls>` + `<div aria-hidden="true" data-popover>` > `<div role="listbox">`; hidden `<input>`), attrs `id`, `name`, `field`, `options`, `value`, `multiple`, `format`, `placeholder` |
| Combobox | `bc_combobox` (`<div class="combobox">` > `<input role="combobox" aria-autocomplete="list" aria-expanded="false" aria-controls>` + `<div aria-hidden="true" data-popover>` > `<div role="listbox" data-empty>`; options `<div role="option" data-value>`), attrs `id`, `name`, `field`, `options`, `value`, `multiple`, `format`, `placeholder`, `clear` |
| Input Group | `bc_input_group` (`<div class="input-group">`), `bc_input_group_addon` (`<span data-align="start|end">`; no class), `bc_input_group_button` (`<button>` or `<div role="group">`) |
| Input OTP | `bc_input_otp` (`<div class="input-otp">` > `<input class="input" aria-label>` + pre-rendered `<div aria-hidden="true">` > `<div>` > `<span>` slots, one span per `length` character), attrs `id`, `name`, `field`, `length`, `filter`, `pattern` |
| Field | `bc_fieldset` (`<fieldset class="fieldset">` or `<div class="fieldset" role="group">`), `bc_field` (`<div class="field" role="group" data-orientation>`), `bc_field_label` (`<label>`), `bc_field_description` (`<p>`), `bc_field_error` (`<p role="alert">`) |
| Label | `bc_label` (`<label class="label">`) |
| Slider | `bc_slider` (native `<input type="range" class="input">`; server-rendered `--slider-value` style; no multi-thumb or vertical support, matching upstream) |
| Form wrapper | none; use Phoenix `form_for`/`<.form>` |

**Layout and structure**

| Upstream | Modules |
| --- | --- |
| Card | `bc_card` (`.card`), `bc_card_header` (`<header>`), `bc_card_title` (`<h2>`), `bc_card_description` (`<p>`), `bc_card_action` (`.card-action`), `bc_card_content` (`<section>`), `bc_card_footer` (`<footer>`) |
| Separator | `bc_separator` (native `<hr role="separator">`; `decorative` renders `role="none"`) |
| Sidebar | `bc_sidebar` (`<aside class="sidebar">`, `data-side="left|right"`, `data-initial-open="false"`, `data-initial-mobile-open="true"`, `data-breakpoint`), `bc_sidebar_nav` (`<nav aria-label>`), `bc_sidebar_header` (`<header>`), `bc_sidebar_content` (`<section>`), `bc_sidebar_group` (`<div role="group" aria-labelledby>`), `bc_sidebar_group_label` (heading), `bc_sidebar_menu` (`<ul>`), `bc_sidebar_menu_item` (`<li>`), `bc_sidebar_menu_button` (`<a>`/`<button>`), `bc_sidebar_menu_sub` (`<details>/<summary>` + nested `<ul>`), `bc_sidebar_footer` (`<footer>`), `bc_sidebar_trigger` (`<button data-basecoat-sidebar-toggle="#{id}">` that calls that sidebar's `toggle()`). Upstream has no inset/floating variant; no `bc_sidebar_inset`. |
| Item | `bc_item` (`<article class="item">` or `<a class="item">`), `bc_item_group` (`.item-group[role="list"]`), `bc_item_media` (`<figure>`), `bc_item_content` (`<section>`), `bc_item_title` (`<h2>`/`<h3>`/`<h4>`), `bc_item_description` (`<p>`), `bc_item_actions` (`<aside>`), `bc_item_header` (`<header>`), `bc_item_footer` (`<footer>`). No `.item-*` classes. |
| Empty | `bc_empty` (`<section class="empty">`), `bc_empty_header` (`<header>`), `bc_empty_media` (`<figure>`), `bc_empty_title` (`<h2>`/`<h3>`/`<h4>`), `bc_empty_description` (`<p>`), `bc_empty_content` (`<section>`), `bc_empty_footer` (`<footer>`). No `.empty-*` classes. |
| Collapsible | `bc_collapsible` (native `<details>`), `bc_collapsible_trigger` (`<summary>`), `bc_collapsible_content` |
| Accordion | `bc_accordion` (`<section class="accordion">`), `bc_accordion_item` (`<details>`), `bc_accordion_trigger` (`<summary>`), `bc_accordion_content` (`<section>`) |

**Display and data**

| Upstream | Modules |
| --- | --- |
| Alert | `bc_alert` (`<div class="alert">`), optional direct child SVG via `:icon` slot, `bc_alert_title` (`<h2>`), `bc_alert_description` (`<section>`), `bc_alert_actions` (`<footer>`). No `.alert-*` classes. |
| Avatar | `bc_avatar` (`<span class="avatar">`), `bc_avatar_image` (`<img>`), `bc_avatar_fallback` (`<span>`), `bc_avatar_badge` (`<span>`), `bc_avatar_group` |
| Badge | `bc_badge` (`<span class="badge">`) |
| Bubble | `bc_bubble` (`<div class="bubble">`; first child is the content, optional `:reactions` renders a direct `<div role="img">`), `bc_bubble_group` (`.bubble-group`). No `.bubble-content`. |
| Message | `bc_message` (`<li class="message">` or `<div class="message">`, `data-align`), `bc_message_group` (`<ol role="list">`). The body is a plain `<div>` containing the sender (`<span class="sr-only">`) and a `bc_bubble`. No `.message-content`. |
| Marker | `bc_marker` (`.marker`; `data-variant="separator|border"`; `role="status"` when text updates; optional decorative SVG before the text `<span>`) |
| Kbd | `bc_kbd` (`<kbd class="kbd">`) |
| Progress | `bc_progress` (`<div class="progress" role="progressbar">` with `aria-label|aria-labelledby`, `aria-valuenow/min/max`; inner `<span style="width: N%">`) |
| Skeleton | `bc_skeleton` (`.skeleton`) |
| Spinner | `bc_spinner` (`svg[role=status][aria-label="Loading"]`; upstream documents no Spinner component, so this helper renders the upstream loader SVG markup as-is) |
| Table | `bc_table_container` (`<div class="table-container">`), `bc_table` (`<table class="table">`), `bc_table_caption` (`<caption>`), `bc_table_header` (`<thead>`), `bc_table_body` (`<tbody>`), `bc_table_footer` (`<tfoot>`), `bc_table_row` (`<tr>`), `bc_table_head` (`<th>`), `bc_table_cell` (`<td>`) |
| Code Block | `bc_code_block` (`<div class="code-block">`), `bc_code_block_header` (`<header>`), `bc_code_block_title` (`<span>`), `bc_code_block_actions` (inner `<div>`), `bc_code_block_copy` (`<button class="btn" data-copy>`), code body is `<pre class="scrollbar" tabindex="0"><code>`. `data-line-numbers` on `<pre>`, `data-size` on root. |
| Attachment | `bc_attachment` (`<div>`/`<li class="attachment">`, `data-orientation`), `bc_attachment_media` (`<figure>`), `bc_attachment_content` (`<section>`), `bc_attachment_title` (first `<p>`), `bc_attachment_description` (following `<p>`s), `bc_attachment_actions` (final `<div>`; optional full-card `<a>`/`<button>` before it). No `.attachment-*` classes. |
| Trace | `bc_trace` (`<ol class="trace" role="list">`), `bc_trace_item` (`<li>`), `bc_trace_line` (`<summary class="trace-line">`), `bc_trace_detail` (`<div>`); nested code uses `bc_code_block` |
| Chart | `bc_chart` (bare `<canvas id aria-label data-chart-*>`; no class; requires Chart.js) |

**Navigation**

| Upstream | Modules |
| --- | --- |
| Breadcrumb | `bc_breadcrumb` (`<nav class="breadcrumb" aria-label="Breadcrumb">`), `bc_breadcrumb_list` (`<ol>`), `bc_breadcrumb_item` (`<li>`), `bc_breadcrumb_link` (`<a>`), `bc_breadcrumb_page` (`<a aria-current="page">`), `bc_breadcrumb_separator` (`<li aria-hidden="true">` + chevron SVG with `data-rtl-flip`), `bc_breadcrumb_ellipsis` (`<li><span aria-hidden="true">…</span></li>`) |
| Pagination | `bc_pagination` (`<nav role="navigation" aria-label="pagination" class="mx-auto flex w-full justify-center">`), `bc_pagination_list` (`<ul class="flex flex-row items-center gap-1">`), `bc_pagination_item` (`<li>`), `bc_pagination_link` (`<a class="btn" data-variant="ghost">`), `bc_pagination_previous`/`bc_pagination_next` (`<a class="btn">` + chevron), `bc_pagination_ellipsis` (`<div class="size-9 flex items-center justify-center">`). No `.pagination` class. |
| Tabs | `bc_tabs` (`<div class="tabs">`), `bc_tab_list` (`<nav role="tablist" aria-orientation="horizontal|vertical" data-variant="line|...">`), `bc_tab` (`<button role="tab" aria-controls aria-selected tabindex>`; disabled via `disabled`/`aria-disabled`), `bc_tab_panel` (`<div role="tabpanel" aria-labelledby tabindex="-1">`, inactive panels `hidden`). The caller composes tabs from the subcomponents; there is no slot-driven `bc_tabs` API, because upstream markup is a flat `nav` plus sibling panels. |
| Dropdown Menu | `bc_dropdown_menu` (`.dropdown-menu`), `bc_dropdown_menu_trigger` (`<button aria-haspopup="menu" aria-controls aria-expanded>`, id `#{id}-trigger`), `bc_dropdown_menu_content` (`<div aria-hidden="true" data-popover>`), `bc_dropdown_menu_group` (`<div role="group" aria-labelledby>`), `bc_dropdown_menu_label` (`<div role="heading">`), `bc_dropdown_menu_item` (`<div role="menuitem">`), `bc_dropdown_menu_checkbox_item` (`<div role="menuitemcheckbox" aria-checked>`), `bc_dropdown_menu_radio_item` (`<div role="menuitemradio" aria-checked>`), `bc_dropdown_menu_separator` (`<hr role="separator">`), `bc_dropdown_menu_shortcut` (`<kbd>`) |
| Command | `bc_command` (`<div class="command">`), `bc_command_dialog` (`<dialog class="command-dialog" aria-label|aria-labelledby>` wrapping one `<div class="command">`), `bc_command_input` (`<input role="combobox" aria-autocomplete="list" aria-controls aria-expanded>`), `bc_command_list` (`<div role="menu" data-empty>`), `bc_command_group` (`<div role="group" aria-labelledby>`), `bc_command_item` (`<div role="menuitem" data-filter data-keywords>`, optional `data-force`, `data-keep-command-open`, `aria-disabled`), `bc_command_separator` (`<hr role="separator">`), `bc_command_shortcut` (`<span data-shortcut>`); support `data-filter="manual"` |
| Theme Switcher | `bc_theme_switcher` (`<button class="btn size-8" aria-label data-tooltip data-side data-variant="outline" data-size="icon" data-basecoat-theme-toggle>` with `hidden dark:block` / `block dark:hidden` icon spans) |

**Overlays and feedback**

| Upstream | Modules |
| --- | --- |
| Dialog | `bc_dialog` (`<dialog class="dialog" aria-labelledby aria-describedby>` > `<div>` > `<header>` + `<section>` + `<footer>` + close `<button>`; native `open` for initial state), `bc_dialog_trigger` |
| Alert Dialog | `bc_alert_dialog` (`<dialog class="alert-dialog">` > `<div>` > `<header>` + `<footer>`), `bc_alert_dialog_trigger` |
| Drawer | `bc_drawer` (`<dialog class="drawer" data-side>`, sides `top|right|bottom|left`; `<article>` > `<header>` + `<section>` + `<footer>`), `bc_drawer_trigger` |
| Sheet | `bc_sheet` (`<dialog class="sheet" data-side>`, default `right`; same article structure), `bc_sheet_trigger` |
| Popover | `bc_popover` (`<div class="popover">`), `bc_popover_trigger` (`<button aria-expanded="false" aria-controls>`), `bc_popover_content` (`<div aria-hidden="true" data-popover data-align>`) |
| Toast | `bc_toaster` (fixed `<ol id="toaster" class="toaster" role="list" aria-label="Notifications" phx-update="ignore">`), `bc_toast` (`<li class="toast" data-category data-duration>` > `<div class="toast-content" role="status|alert" aria-atomic="true">` > `<section>` + `<footer>`; error uses `role="alert"`; optional direct SVG), `BasecoatPhoenix.Toast.push/2` |
| Carousel | `bc_carousel` (`<div class="carousel" role="region" aria-roledescription="carousel" aria-label>`), `bc_carousel_content` (`<ul class="scrollbar" role="list" tabindex="0" aria-label>`), `bc_carousel_item` (`<li>`), `bc_carousel_previous`/`bc_carousel_next` (direct `<button class="btn" hidden>` children) |

**Patterns only: no component, no invented class**

| Upstream page | What ships |
| --- | --- |
| Direction | Documentation: set `dir="rtl"` on a component or ancestor; logical utilities (`ms-*`, `pe-*`, `start/end`) follow it. `data-side` stays physical. No `bc_direction`. |
| Aspect Ratio | Documentation: wrapper with `aspect-video`, `aspect-square`, or `aspect-[w/h]` plus `overflow-hidden`, media with `h-full w-full object-cover`. No `bc_aspect_ratio`. |
| Scroll Area | Documentation: focusable viewport with `scrollbar`, a height/width, and `overflow-auto|overflow-y-auto`. No `bc_scroll_area`. |
| Data Table | Recipe: `bc_table` inside `bc_table_container` plus the app's `simple-datatables` setup. Basecoat ships no data-table controller or class. No `bc_data_table`. |
| Tooltip | Attribute helper: add `data-tooltip`, `data-side` (`top|bottom|left|right|inline-start|inline-end`), and `data-align` (`start|center|end`) to the trigger element through `{@rest}`. CSS-only, text-only. No `bc_tooltip` wrapper. |

**Stylesheet only**

- Typeset: `mix basecoat.install --typeset` copies `typeset.css` and adds its import.
- Utilities (`transition-details`, `scrollbar`, `scroll-fade`, `shimmer`): documented CSS classes; no Elixir component.

**Integration notes**

- `bc_toaster` renders `<ol id="toaster" class="toaster" role="list" aria-label="Notifications" phx-update="ignore">`; Basecoat registers only `#toaster`, so the id is fixed. Render it once in the layout.
- `bc_chart` renders `<canvas id aria-label data-chart-*>` with no class, matching upstream, plus a `BasecoatChart` hook. The hook calls `window.basecoat.chart(canvas, config)` on mount and when a `data-chart-*` input changes. Chart.js itself is not bundled; with `--chart`, the app still loads Chart.js (npm or CDN) before `chart.js`. Without Chart.js the hook logs a clear error and leaves the canvas empty.
- `bc_input_otp` uses `phx-update="ignore"` because Basecoat mutates the pre-rendered slot spans (text plus `data-active`/`data-caret`) instead of generating them; a patch would overwrite that state.

### High-level component shapes

```heex
<.bc_button variant="outline" size="sm" phx-click="save">Save</.bc_button>

<.bc_card>
  <.bc_card_header>
    <.bc_card_title>Title</.bc_card_title>
    <.bc_card_description>Description.</.bc_card_description>
    <.bc_card_action><.bc_button size="sm">Edit</.bc_button></.bc_card_action>
  </.bc_card_header>
  <.bc_card_content>Body</.bc_card_content>
  <.bc_card_footer>Footer</.bc_card_footer>
</.bc_card>

<.bc_dialog_trigger dialog="edit-profile">Edit profile</.bc_dialog_trigger>
<.bc_dialog id="edit-profile" title="Edit profile" description="Make changes here.">
  <.bc_input name="name" value={@name} />
  <:footer>
    <.bc_button variant="outline" data-basecoat-dialog-close>Cancel</.bc_button>
    <.bc_button phx-click="save">Save</.bc_button>
  </:footer>
</.bc_dialog>

<.bc_select
  id="fruit"
  name="fruit"
  placeholder="Select a fruit"
  value={@fruit}
  options={[
    %{label: "Fruits", options: [
      %{value: "apple", label: "Apple"},
      %{value: "banana", label: "Banana"}
    ]}
  ]}
/>

<.bc_tabs id="settings">
  <.bc_tab_list>
    <.bc_tab id="settings-tab-account" panel="settings-panel-account" selected>Account</.bc_tab>
    <.bc_tab id="settings-tab-password" panel="settings-panel-password">Password</.bc_tab>
  </.bc_tab_list>
  <.bc_tab_panel id="settings-panel-account" labelledby="settings-tab-account">Account panel</.bc_tab_panel>
  <.bc_tab_panel id="settings-panel-password" labelledby="settings-tab-password" hidden>Password panel</.bc_tab_panel>
</.bc_tabs>
```

### Assets and installer

Vendored from `basecoat-css@1.2.1`:

- `basecoat-{vega,nova,maia,lyra,mira,luma,sera,rhea}.bundle.css` (uncompiled, Tailwind-processed)
- `all.min.js` (runtime + all controllers except Chart)
- `chart.min.js`
- `typeset.css`
- `VERSION` (recorded at install), `LICENSE` (upstream MIT)

`mix basecoat.install`:

```text
mix basecoat.install [--style vega] [--typeset] [--chart]
                     [--replace-ui]
                     [--assets-path assets]
                     [--css assets/css/app.css]
                     [--js assets/js/app.js]
                     [--source-path "../../deps/basecoat_phoenix/lib"]
```

Steps:

1. Preflight `app.css`. Abort before copying anything if:
   - There is no `@import "tailwindcss"` line (Tailwind 3 or missing Tailwind).
   - A daisyUI `@plugin` is present and `--replace-ui` was not given.
   - A `@custom-variant dark` using `[data-theme=dark]` is present and `--replace-ui` was not given.
   The abort message prints the exact lines to remove.
2. With `--replace-ui`, back up `app.css` to `app.css.bak`, remove every daisyUI `@plugin` block (including their `{ ... }` config), and remove the `[data-theme=dark]` dark variant. Phoenix 1.8's template has three blocks: `daisyui`, `daisyui-theme` (dark), and `daisyui-theme` (light). The base name is a prefix of the theme name, so matching uses the full quoted plugin name and repeats until no block remains. Phoenix 1.8's generated `core_components` keep compiling but lose daisyUI styling; the app migrates to `bc_*` components.
3. Copy `basecoat.css` (chosen style) to `vendor/basecoat/basecoat.css`, `all.min.js` to `vendor/basecoat/basecoat.js` (the runtime plus all 15 controllers), and `basecoat_live.js` to `vendor/basecoat/basecoat_live.js`. With `--typeset`, copy `typeset.css`; with `--chart`, copy `chart.min.js` to `vendor/basecoat/chart.js`.
4. Patch `app.css` idempotently:
   - Insert `@import "../vendor/basecoat/basecoat.css";` immediately after the `@import "tailwindcss"` line, so it precedes Phoenix's `@source` and custom variants.
   - Append `@source "<source-path>";` (default `../../deps/basecoat_phoenix/lib`).
   - Optional `@import "../vendor/basecoat/typeset.css";` after Basecoat.
5. Patch `app.js` idempotently:
   - Add `import "../vendor/basecoat/basecoat.js";`
   - With `--chart`, add `import "../vendor/basecoat/chart.js";` after it.
   - Add `import {BasecoatHooks} from "../vendor/basecoat/basecoat_live.js";`
   - Replace `hooks: {...colocatedHooks}` with `hooks: {...colocatedHooks, ...BasecoatHooks}`.
6. If a pattern is missing, leave the file untouched and print the exact snippet to add manually. Never fail after copying files.
7. Re-running is a no-op.

**Dark mode contract.** Basecoat wins: `html.dark`, set by `window.basecoat.theme`. The installer removes Phoenix's `[data-theme=dark]` variant under `--replace-ui`; without that removal Basecoat's `dark:` styles would be overridden by the later variant. The theme switcher does not set `data-theme`.

`basecoat_live.js` responsibilities (no inline handlers):

- `BasecoatState` hook: the attribute/property preservation described above. Attached by stateful components. It also performs overlay sync for every root `<dialog>` (`.dialog`, `.alert-dialog`, `.drawer`, `.sheet`, `.command-dialog`): it compares the server-rendered `open` state with the previous baseline and calls native `<dialog>` `showModal()`/`close()`. Basecoat has no dialog controller (verified in `all.js`), so nothing else would open these modally; only `.drawer`/`.sheet` get cancel and backdrop from Basecoat's drawer controller. The hook owns backdrop click for the other three. One hook per element, so overlay sync is folded into this hook rather than a second `phx-hook`.
- `BasecoatChart` hook: calls `window.basecoat.chart(canvas, config)` on mount and when `data-chart-data`, `data-chart-series`, or `data-chart-type` changes; guards on `window.basecoat.chart` and `window.Chart`.
- Toaster listener: a plain `window.addEventListener("phx:basecoat_toast", …)` in `basecoat_live.js` calls `document.getElementById("toaster")?.toast(payload)`. LiveView dispatches every `push_event` as `phx:<event>` on `window` (verified in LiveView 1.2.15), so one listener serves all LiveViews, nested ones included. No hook, and no `phx-update` interaction.
- Delegated `click` handling for `[data-basecoat-dialog-open]`, `[data-basecoat-dialog-close]`, `[data-basecoat-drawer-open]`, `[data-basecoat-drawer-close]`, `[data-basecoat-sidebar-toggle]`, `[data-basecoat-theme-toggle]`.
- Custom events `basecoat:open-dialog`, `basecoat:close-dialog`, `basecoat:open-drawer`, `basecoat:close-drawer`, `basecoat:toast` for `Phoenix.LiveView.JS.dispatch/2`.
- Relay `change` from `.select` / `.combobox` roots to their hidden input so LiveView form handling sees the value. The relay fires only when the event target is the component root, never the hidden input, so it cannot loop. It is distinct from `window.basecoat.refresh`, which never emits `change`.
- Installer CSS surgery lives in pure functions (`BasecoatPhoenix.Installer.CSS`), not regexes: `remove_plugin_block/2` scans brace depth and matches the full quoted plugin name, and `insert_after/3` inserts one line after the first line that starts with a given prefix. Both are unit-tested without touching the filesystem.
- On `phx:page-loading-stop`, call `window.basecoat.initAll()` (idempotent).
- All handlers guard on `window.basecoat` being present.

### LiveView behavior

- Basecoat's own `MutationObserver` initializes nodes added by LiveView patches and streams, and destroys removed components. The `BasecoatState` hook keeps its initialized markers and client-owned attributes alive across patches.
- State owned by Basecoat (open menus, active tabs, drawer visibility, select value) is not mirrored in assigns. Component templates render only initial state. `BasecoatState` preserves client changes unless the server deliberately changes the same attribute. A server render equal to the client's original value cannot be told apart from "unchanged"; to force a reset, change a nonce attribute on the root or re-render the subtree.
- Dialog/drawer/sheet use native `<dialog>`. `bc_dialog`, `bc_alert_dialog`, `bc_drawer`, and `bc_sheet` accept an initial `open` boolean (rendered as the native `open` attribute; the hook calls `showModal()` on mount when true and not already `:modal`). After mount the overlay is client-owned: triggers and close buttons update it locally, and `BasecoatState` keeps it across patches. Server-side "close after save" uses `JS.dispatch("basecoat:close-dialog", to: "#id")`. Server-side "open" works by changing `open` from `false` to `true`; overlay sync notices the server change and calls `showModal()`, so the dialog opens modally rather than with a bare attribute.
- Backdrop click closes dialogs, alert dialogs, and command dialogs, handled by `BasecoatState`. Escape closes natively; `bc_dialog` also renders its upstream close button. Drawers and sheets get backdrop and cancel from Basecoat's drawer controller.
- Select/combobox submit through their hidden input. `phx-change`/`phx-submit` on the enclosing form receive the value after the relay. The hidden input carries `name`; `bc_select`/`bc_combobox` require it.
- Tabs/accordion/sidebar/carousel/command are client-side. Their state survives patches. Server-driven tab panels use a separate LiveView or a `phx-click` handler; the library does not re-render active state. `bc_tabs` renders only initial state from `selected`/`hidden`; the caller composes `bc_tab_list`, `bc_tab`, and `bc_tab_panel` rather than passing slots.
- Basecoat's observer watches `childList` only, so server changes to values or option lists need an explicit refresh. `BasecoatState` calls `window.basecoat.refresh(root)` after every patch; Basecoat's own registry decides which five components need it (`select`, `combobox`, `dropdown-menu`, `command`, `tabs`) and no-ops for the rest. The combobox refresh also re-creates the client-inserted `.combobox-chips` wrapper when a patch removed it. `bc_chart` re-renders through `BasecoatChart`. Server-driven options are supported by re-rendering and refreshing; `data-filter="manual"` covers server-side command filtering.
- `bc_input_otp` is the exception: it is `phx-update="ignore"`, so server value changes after mount are not reflected. The submitted value is authoritative; reset the form to clear it.
- Toasts: `BasecoatPhoenix.Toast.push(socket, category: :success, title: "Saved")` calls `push_event(socket, "basecoat_toast", payload)`. LiveView dispatches pushed events as `phx:basecoat_toast` on `window`, and the listener in `basecoat_live.js` catches them, so a single `#toaster` in the root layout receives toasts from nested LiveViews too. Client-side toasts use `JS.dispatch("basecoat:toast", detail: ...)`. The helper accepts `:title`, `:description`, `:category`, `:duration`, `:close_button`, `:action`, and `:cancel`, and converts them to Basecoat's camelCase payload keys. `:action`/`:cancel` accept `:label` and `:href`; no `onclick` is emitted (CSP-safe). Actions that must run a LiveView event belong on a persistent control outside the toast.
- Reconnect and `push_patch` need no special handling. A documented escape hatch exists: `window.basecoat.initAll({ force: true })`.

### Theming

- Basecoat uses the `dark` class on `<html>` and `localStorage.themeMode`.
- `bc_theme_switcher` renders a button with `data-basecoat-theme-toggle`; `basecoat_live.js` toggles via `window.basecoat.theme.toggle()`.
- Phoenix 1.8's generated theme code (if present) uses `data-theme`; replace it with `bc_theme_switcher`. Keeping both produces two competing theme mechanisms.
- No server-side theme persistence. Optional no-flash head script is documented, not injected.

### Accessibility

- Mirror upstream roles, `aria-*`, and keyboard contracts exactly.
- Linked ids are deterministic and required.
- Icon-only buttons require `aria-label` via the caller; documented per component.
- Render tests assert ARIA wiring for dialog, tabs, select, combobox, dropdown, accordion.

## Testing

- `mix test`: one render test file per component module using `Phoenix.LiveViewTest.render_component/2`. Assert root classes, variant/size attributes, slot content, class merging, global attribute passthrough, and ARIA ids.
- Markup fidelity tests: each component asserts its rendered tag tree, classes, roles, and `data-*` against the upstream doc example. Subcomponent tests assert semantic tags (`header`, `section`, `footer`, `figure`, `aside`, `h2`/`h3`, `p`) and assert no invented `*-content`/`*-media` class appears. Pattern pages (Direction, Aspect Ratio, Scroll Area, Data Table, Tooltip) assert that no component module exists.
- Stateful components additionally assert `phx-hook="BasecoatState"` and a required `id`.
- Markup fidelity is asserted by comparing the rendered tree against the upstream doc example: one normalized expected-markup string per component, whitespace and attribute order normalized. Targeted assertions cover only class merging and `{@rest}` passthrough, in one shared test.
- Form tests cover `field={@form[:x]}` and explicit `name`/`value`, error rendering, multiple select/combobox JSON round-trip through `BasecoatPhoenix.Forms.decode_multi/1`, and disabled options.
- Installer tests: create a temp project skeleton with `app.css`/`app.js`, run the task, assert copied files and exact patches; run twice and assert no duplicates; test missing-pattern fallback; test the daisyUI/dark-variant preflight abort; test `--replace-ui` removes all three daisyUI plugin blocks and the `[data-theme=dark]` variant and writes `app.css.bak`.
- Dark-mode test: compiled CSS contains Basecoat's `html.dark` variant and no `[data-theme=dark]` variant after `--replace-ui`.
- Asset integrity test: vendored files are checked against recorded SHA-256 hashes, so accidental edits or a partial upgrade fail CI.
- `mix compile --warnings-as-errors`, `mix format --check-formatted`.
- The manual browser checklist starts as soon as the vertical slice lands (task 6), not at the end: the throwaway Phoenix app is created then and each component's manual check is added as that component's task completes. Waiting until the last task would surface every JS assumption at once.
- No committed demo app. Manual browser checklist for the 15 JS controllers is kept in `docs/manual-verification.md`; a throwaway Phoenix app is used during development for that checklist. The checklist includes the patch-preservation cases: open dropdown + unrelated assign update, switched tab + update, selected value + update, open dialog + update, toast + update, OTP + update.
- JS has no automated test harness in v1.

## Build order

1. Project skeleton, upstream assets, installer, `basecoat_live.js`.
2. Umbrella module + conventions + first vertical slice (`bc_button`, `bc_card`, `bc_dialog`, `bc_select`) to validate markup, tests, and installer end-to-end.
3. Remaining CSS-only components.
4. Remaining JS-backed components.
5. Toast/chart/theme integration, docs, manual verification.

## Risks

- **Upstream drift.** Pinned and verified at 1.2.1. Upgrades are a deliberate task: replace `priv/basecoat/`, diff markup, update hashes, run tests.
- **`BasecoatState` is custom integration code.** It must be verified in a real browser against LiveView 1.2.15. Failure mode: state not preserved or server changes ignored. Manual checklist covers both directions. If LiveView's patch internals change, this hook is the first thing to inspect.
- **LiveView 1.2 requirement.** `beforeUpdate(toEl)` is not available in 1.1. Apps on older LiveView cannot use the library. Accepted; the target app is on current Phoenix 1.8.
- **Tailwind `@source` path.** Dep location varies (path, git, hex). Installer defaults to `../../deps/basecoat_phoenix/lib` and accepts `--source-path`. Apps using `source(none)` still work because the installer appends an explicit `@source`.
- **Select change relay.** A double `change` would double-submit. The relay only dispatches when the event target is the component root, not the hidden input; covered by manual check.
- **Client-owned overlays.** A dialog opened by a trigger is not reflected in assigns. Server-side close/open uses `JS.dispatch` or an `open` assign transition. Documented; this is the Basecoat model.
- **daisyUI collision.** Phoenix 1.8's default `app.css` loads daisyUI, which defines the same `.btn`, `.card`, `.input`, `.badge`, `.alert` classes. Coexistence is impossible. `--replace-ui` removes it with a backup; without the flag the installer aborts. Existing `core_components` markup loses styling until migrated to `bc_*`.
- **Dark-mode override.** Basecoat uses `html.dark`; Phoenix 1.8 defines `[data-theme=dark]`. The installer must remove the Phoenix variant under `--replace-ui`, otherwise the later declaration wins and all Basecoat `dark:` styles silently break. Covered by a CSS assertion test.
- **57 doc pages, 51 upstream components, 1 convenience helper, 5 patterns.** Each component maps 1:1 to an upstream doc example and is covered by a markup-fidelity test. `bc_spinner` exists because upstream documents no Spinner component. Pattern pages are documentation only, so there is no invented API to drift.
- **Markup is a docs contract, not a typed API.** Upstream can change tags or classes in a patch release. The vendored docs, hash-checked assets, and per-component tree assertions make drift visible immediately.
- **No committed demo app.** JS behavior is verified manually, not in CI. Accepted for v1; add a demo app if regressions appear.
