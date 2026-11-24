# Basecoat Phoenix examples

Copy-paste examples for every component. Each snippet names only components and
attributes this library ships; the assigns (`@rows`, `@form`, `@type`) come from
the enclosing LiveView.

## Before you start

`use BasecoatPhoenix.Components` in `html_helpers` (see the README), then render
from a LiveView or a template:

```elixir
defmodule MyAppWeb.DemoLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "Ada", volume: 30)}
  end

  def render(assigns) do
    ~H"""
    <.bc_button phx-click="save">Save</.bc_button>
    """
  end
end
```

The examples below are template fragments: drop them into `render/1`.

## How to read this page

- Every component accepts `class` and passes unknown attributes to its root
  element, so `id`, `phx-click`, `phx-change`, `aria-*`, and `data-*` work
  without a dedicated attribute. The one exception is `bc_collapsible_content`:
  it renders no wrapper, because upstream has none.
- Each section lists its own attributes in an **Attrs** line. Parenthesized
  values are the accepted values; the default follows the name.
- Basecoat owns client state: open menus, the active tab, the selected value,
  drawer visibility. Templates render initial state only. An unrelated LiveView
  update keeps the client state (see [Client state](../README.md#client-state)).
- Icons are inline SVGs. The library ships the icons it needs (chevron, close,
  check, loader, sun/moon). `bc_alert`, `bc_marker`, `bc_toast`, and
  `bc_trace_line` also take an `:icon` slot; everywhere else, put the SVG in the
  default slot.

---

## Button

```heex
<.bc_button>Save</.bc_button>
<.bc_button variant="secondary">Secondary</.bc_button>
<.bc_button variant="outline">Outline</.bc_button>
<.bc_button variant="ghost">Ghost</.bc_button>
<.bc_button variant="link">Link</.bc_button>
<.bc_button variant="destructive" phx-click="delete">Delete</.bc_button>
```

Omit `variant` for the primary style. Sizes:

```heex
<.bc_button size="xs">Extra small</.bc_button>
<.bc_button size="sm">Small</.bc_button>
<.bc_button size="lg">Large</.bc_button>
```

Icon sizes take an icon and an `aria-label` instead of text:

```heex
<.bc_button variant="outline" size="icon" aria-label="Settings">
  <svg class="lucide lucide-settings" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.671 4.136a2.34 2.34 0 0 1 4.659 0 2.34 2.34 0 0 0 3.319 1.915 2.34 2.34 0 0 1 2.33 4.033 2.34 2.34 0 0 0 0 3.831 2.34 2.34 0 0 1-2.33 4.033 2.34 2.34 0 0 0-3.319 1.915 2.34 2.34 0 0 1-4.659 0 2.34 2.34 0 0 0-3.32-1.915 2.34 2.34 0 0 1-2.33-4.033 2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915" /><circle cx="12" cy="12" r="3" /></svg>
</.bc_button>
```

`size="icon-xs"`, `"icon-sm"`, and `"icon-lg"` follow the same shape.

A link, a submit button, a disabled button, and an icon with text:

```heex
<.bc_button href="/settings" variant="ghost">Settings</.bc_button>
<.bc_button type="submit" phx-disable-with="Saving…">Save</.bc_button>
<.bc_button disabled>Disabled</.bc_button>
<.bc_button>
  <svg data-icon="inline-start" class="lucide lucide-plus" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14" /><path d="M12 5v14" /></svg>
  New
</.bc_button>
```

`href` renders an `<a>`; otherwise a `<button type="button">`. `data-icon="inline-start"` or `"inline-end"` on an inline icon tightens the matching side padding. `disabled` applies to the `<button>` form only.

Attrs: `variant` (primary, secondary, outline, ghost, link, destructive; default primary), `size` (xs, sm, default, lg, icon, icon-xs, icon-sm, icon-lg; default default), `type` (default `"button"`), `href`, `disabled`, `class`.

## Button group

```heex
<.bc_button_group label="Zoom">
  <.bc_button variant="outline" size="sm" phx-click="zoom_out">−</.bc_button>
  <.bc_button variant="outline" size="sm" phx-click="zoom_in">+</.bc_button>
</.bc_button_group>
```

`label` becomes the group's accessible name. Children are plain buttons; the group only joins their borders.

Attrs: `label` (accessible name), `class`.

## Badge

```heex
<.bc_badge>New</.bc_badge>
<.bc_badge variant="secondary">Draft</.bc_badge>
<.bc_badge variant="destructive">Failed</.bc_badge>
<.bc_badge variant="outline">v1.3.0</.bc_badge>
<.bc_badge variant="ghost">Beta</.bc_badge>
<.bc_badge variant="link">Docs</.bc_badge>
```

Omit `variant` for the primary style. `link` uses the primary color with an underline on hover. `bc_badge` always renders a `<span>`; for a clickable badge, write `<a class="badge" href="…">` yourself and pass the same `data-variant`. Put `data-icon="inline-start"` or `data-icon="inline-end"` on an inline icon; Basecoat tightens the matching side padding so the icon sits flush with the edge:

```heex
<.bc_badge>
  <svg data-icon="inline-start" class="lucide lucide-check" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5" /></svg>
  Verified
</.bc_badge>
```

Attrs: `variant` (primary, secondary, destructive, outline, ghost, link; default primary), `class`.

## Kbd

```heex
Press <.bc_kbd>⌘K</.bc_kbd> to search.
```

Attrs: none beyond `class`.

## Separator

```heex
<.bc_separator />
<.bc_separator orientation="vertical" class="h-6" />
<.bc_separator decorative />
```

Horizontal by default. `orientation="vertical"` needs a height from a class. `decorative` renders `role="none"` for a purely visual rule.

Attrs: `orientation` (horizontal, vertical), `decorative`.

## Skeleton

```heex
<.bc_skeleton class="h-4 w-48" />
<.bc_skeleton class="h-24 w-full" />
```

Sizing comes from utility classes; the element carries no intrinsic size.

Attrs: `class`. Accepts an `inner_block` for a skeleton that wraps content.

## Spinner

```heex
<.bc_spinner />
<.bc_spinner label="Saving" class="size-4" />
```

`label` renders visible text next to the spinner; the SVG is then `aria-hidden` and the wrapper carries `role="status"`. Without it the SVG keeps `aria-label="Loading"`.

Attrs: `label`, `class`.

## Progress

```heex
<.bc_progress value={30} label="Upload" />
<.bc_progress value={7} max={10} label="Steps" />
<.bc_progress value={66} />
<.bc_progress value={40} labelledby="storage-heading" />
```

`label` renders the upstream labeled layout: label and percentage above the bar. Omit it for a bare bar. `labelledby` names the bar from an element elsewhere on the page.

Attrs: `value` (required), `max` (default 100), `min` (default 0), `label`, `labelledby`, `class`.

## Avatar

```heex
<.bc_avatar>
  <.bc_avatar_image src="/images/ada.jpg" alt="Ada Lovelace" />
</.bc_avatar>

<.bc_avatar>
  <.bc_avatar_fallback>AL</.bc_avatar_fallback>
</.bc_avatar>

<.bc_avatar size="lg">
  <.bc_avatar_image src="/images/ada.jpg" alt="Ada Lovelace" />
  <.bc_avatar_badge>3</.bc_avatar_badge>
</.bc_avatar>

<.bc_avatar_group>
  <.bc_avatar><.bc_avatar_fallback>AL</.bc_avatar_fallback></.bc_avatar>
  <.bc_avatar><.bc_avatar_fallback>GH</.bc_avatar_fallback></.bc_avatar>
</.bc_avatar_group>
```

Put the image first and the fallback after it: the fallback shows through while the image loads. `size="sm"` and `size="lg"` change the diameter.

Attrs: `bc_avatar` — `size` (sm, lg); `bc_avatar_image` — `src` (required), `alt`; `bc_avatar_badge` — `class`; `bc_avatar_group` — `class`.

## Card

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

Each helper renders the upstream tag: `header`, `h2`, `p`, `div.card-action`, `section`, `footer`. Skip any part you do not need; the card works with content alone. `data-size="sm"` tightens the padding, as upstream.

Attrs: every card helper takes `class` only; `bc_card` takes `class` and a required `inner_block`.

## Alert

```heex
<.bc_alert>
  <.bc_alert_title>Heads up</.bc_alert_title>
  <.bc_alert_description>Your trial ends in three days.</.bc_alert_description>
</.bc_alert>

<.bc_alert variant="destructive">
  <:icon>
    <svg class="lucide lucide-circle-alert" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10" /><line x1="12" x2="12" y1="8" y2="12" /><line x1="12" x2="12.01" y1="16" y2="16" /></svg>
  </:icon>
  <.bc_alert_title>Something went wrong</.bc_alert_title>
  <.bc_alert_description>Retry, or contact support.</.bc_alert_description>
  <.bc_alert_actions>
    <.bc_button variant="outline" size="sm">Retry</.bc_button>
  </.bc_alert_actions>
</.bc_alert>
```

Default styling and `destructive` are the only variants. The `:icon` slot must hold a direct child SVG, which is how Basecoat positions it. `bc_alert_title` renders `h2` by default; `as` changes the tag.

Attrs: `bc_alert` — `variant` (destructive), `icon` slot, `class`; `bc_alert_title` — `as` (default `"h2"`); `bc_alert_description`, `bc_alert_actions` — `class`.

## Item

```heex
<.bc_item_group>
  <.bc_item>
    <.bc_item_media>
      <.bc_avatar><.bc_avatar_fallback>AL</.bc_avatar_fallback></.bc_avatar>
    </.bc_item_media>
    <.bc_item_content>
      <.bc_item_title>Ada Lovelace</.bc_item_title>
      <.bc_item_description>First programmer</.bc_item_description>
    </.bc_item_content>
    <.bc_item_actions>
      <.bc_button variant="outline" size="sm">Follow</.bc_button>
    </.bc_item_actions>
  </.bc_item>
</.bc_item_group>

<.bc_item href="/invoices/42" variant="outline" size="sm">
  <.bc_item_content>
    <.bc_item_title>Invoice 42</.bc_item_title>
    <.bc_item_description>Paid on Monday</.bc_item_description>
  </.bc_item_content>
</.bc_item>

<.bc_item variant="muted">
  <.bc_item_header>
    <.bc_item_title as="h4">Deploy</.bc_item_title>
  </.bc_item_header>
  <.bc_item_content>All checks passed.</.bc_item_content>
  <.bc_item_footer>
    <.bc_badge variant="secondary">2 minutes ago</.bc_badge>
  </.bc_item_footer>
</.bc_item>
```

`href` renders an `<a>` instead of an `<article>`. Variants: `outline` and `muted`; sizes: `sm` and `xs`. `bc_item_title` renders `h3` by default.

Attrs: `bc_item` — `href`, `variant` (outline, muted), `size` (sm, xs), `class`; `bc_item_title` — `as` (default `"h3"`); the other helpers take `class`.

## Empty

```heex
<.bc_empty>
  <.bc_empty_header>
    <.bc_empty_media>
      <.bc_spinner />
    </.bc_empty_media>
    <.bc_empty_title>No projects</.bc_empty_title>
    <.bc_empty_description>Create your first project to get started.</.bc_empty_description>
  </.bc_empty_header>
  <.bc_empty_content>Projects hold your files.</.bc_empty_content>
  <.bc_empty_footer>
    <.bc_button phx-click="new_project">New project</.bc_button>
  </.bc_empty_footer>
</.bc_empty>
```

Renders `<section class="empty">`. `bc_empty_title` renders `h3` by default; `as` changes the tag.

Attrs: `bc_empty` — `class`; `bc_empty_title` — `as` (default `"h3"`); the other helpers take `class`.

## Table

```heex
<.bc_table_container>
  <.bc_table>
    <.bc_table_caption>Invoices</.bc_table_caption>
    <.bc_table_header>
      <.bc_table_row>
        <.bc_table_head scope="col">Invoice</.bc_table_head>
        <.bc_table_head scope="col">Status</.bc_table_head>
        <.bc_table_head scope="col" class="text-end">Amount</.bc_table_head>
      </.bc_table_row>
    </.bc_table_header>
    <.bc_table_body>
      <.bc_table_row>
        <.bc_table_cell class="font-medium">INV001</.bc_table_cell>
        <.bc_table_cell>Paid</.bc_table_cell>
        <.bc_table_cell class="text-end">$250.00</.bc_table_cell>
      </.bc_table_row>
      <.bc_table_row>
        <.bc_table_cell>INV002</.bc_table_cell>
        <.bc_table_cell>Pending</.bc_table_cell>
        <.bc_table_cell class="text-end">$150.00</.bc_table_cell>
      </.bc_table_row>
    </.bc_table_body>
    <.bc_table_footer>
      <.bc_table_row>
        <.bc_table_cell colspan="2">Total</.bc_table_cell>
        <.bc_table_cell class="text-end">$400.00</.bc_table_cell>
      </.bc_table_row>
    </.bc_table_footer>
  </.bc_table>
</.bc_table_container>
```

Wrap the table in `bc_table_container` so a wide table scrolls instead of stretching the page. `scope` on a head cell ties it to its column or row.

Attrs: `bc_table_head` — `scope` (col, row), `colspan`, `rowspan`; `bc_table_cell` — `colspan`, `rowspan`; the rest take `class`.

## Code block

```heex
<.bc_code_block size="sm">
  <.bc_code_block_header>
    <.bc_code_block_title>Terminal</.bc_code_block_title>
    <.bc_code_block_actions>
      <.bc_code_block_copy>Copy</.bc_code_block_copy>
    </.bc_code_block_actions>
  </.bc_code_block_header>
  <pre class="scrollbar" tabindex="0" aria-label="Terminal output"><code>mix phx.server</code></pre>
</.bc_code_block>
```

The code body is yours: put `data-line-numbers` on the `<pre>` to number lines, and add your own highlighter spans. `bc_code_block_copy` renders Basecoat's copy button, which copies the sibling `<pre>` text. `size="sm"` tightens the padding.

Attrs: `bc_code_block` — `size` (sm), `class`; `data-variant="destructive"` passes through `{@rest}` for the error styling. The header, title, actions, and copy helpers take `class`.

## Chart

Chart.js must be loaded by the app; `mix basecoat.install --chart` vendors it.

Every Chart.js type has a wrapper. Use `bc_chart` when the type is dynamic.

```heex
<.bc_chart id="visitors" type={@type} label_key="month" data={@rows} series={@series} />
```

Most snippets below reuse these two assigns:

```elixir
def mount(_params, _session, socket) do
  rows = [
    %{month: "Jan", desktop: 186, mobile: 80},
    %{month: "Feb", desktop: 305, mobile: 200},
    %{month: "Mar", desktop: 237, mobile: 120}
  ]

  sources = [
    %{source: "Direct", visitors: 320, color: "var(--chart-1)"},
    %{source: "Search", visitors: 240, color: "var(--chart-2)"},
    %{source: "Social", visitors: 130, color: "var(--chart-3)"}
  ]

  {:ok, assign(socket, rows: rows, sources: sources, type: "bar")}
end
```

`data` is a list of row maps. `label_key` names the field used for the axis or
slice labels; every other numeric field becomes a series. `series` maps a field
to its label, color, dataset overrides, and optional `surface`. A row may carry
`color` to color a pie or doughnut slice.

Attrs: `id` (required), `type` (bar, line, pie, doughnut, polarArea, radar, scatter, bubble), `label_key`, `legend`, `tooltip`, `data`, `series`, `options` (raw Chart.js options), `chart_data` (complete Chart.js data object), `class`. The wrappers take the same attrs without `type`.

### Bar

```heex
<.bc_bar_chart
  id="visitors"
  label_key="month"
  legend
  data={@rows}
  series={%{
    desktop: %{label: "Desktop", color: "var(--chart-1)"},
    mobile: %{label: "Mobile", color: "var(--chart-2)"}
  }}
/>
```

Stack the series by giving each one the same `stack` and turning it on in the
options:

```heex
<.bc_bar_chart
  id="pipeline"
  label_key="month"
  legend
  data={@rows}
  series={%{
    desktop: %{label: "Desktop", color: "var(--chart-1)", dataset: %{stack: "visitors"}},
    mobile: %{label: "Mobile", color: "var(--chart-2)", dataset: %{stack: "visitors"}}
  }}
  options={%{scales: %{x: %{stacked: true}, y: %{stacked: true}}}}
/>
```

Turn the bars sideways with `indexAxis`:

```heex
<.bc_bar_chart
  id="tasks"
  label_key="month"
  data={@rows}
  series={%{desktop: %{label: "Desktop", color: "var(--chart-1)"}}}
  options={%{indexAxis: "y"}}
/>
```

### Line

```heex
<.bc_line_chart
  id="revenue"
  label_key="month"
  legend
  data={[
    %{month: "Jan", recurring: 320, new: 180},
    %{month: "Feb", recurring: 410, new: 220},
    %{month: "Mar", recurring: 390, new: 260}
  ]}
  series={%{
    recurring: %{label: "Recurring", color: "var(--chart-1)"},
    new: %{label: "New", color: "var(--chart-2)"}
  }}
/>
```

Step line: add `stepped` to the dataset.

```heex
<.bc_line_chart
  id="queue"
  label_key="month"
  data={@rows}
  series={%{open: %{label: "Open", color: "var(--chart-3)", dataset: %{stepped: true}}}}
/>
```

Area: give the series a surface and fill it.

```heex
<.bc_line_chart
  id="traffic"
  label_key="month"
  data={@rows}
  series={%{
    desktop: %{
      label: "Desktop",
      color: "var(--chart-1)",
      surface: "gradient",
      dataset: %{fill: true, tension: 0.35}
    }
  }}
/>
```

### Pie

Pie, doughnut, and polar area take one series key. Color each slice on the row.

```heex
<.bc_pie_chart
  id="traffic-pie"
  label_key="source"
  legend
  data={@sources}
  series={%{visitors: %{label: "Visitors"}}}
/>
```

### Doughnut

```heex
<.bc_doughnut_chart
  id="traffic-doughnut"
  label_key="source"
  legend
  data={@sources}
  series={%{visitors: %{label: "Visitors"}}}
/>
```

### Polar area

```heex
<.bc_polar_area_chart
  id="channels"
  label_key="source"
  legend
  data={@sources}
  series={%{visitors: %{label: "Visitors"}}}
/>
```

### Radar

```heex
<.bc_radar_chart
  id="channels-radar"
  label_key="channel"
  legend
  data={[
    %{channel: "Email", open: 120, click: 80},
    %{channel: "Ads", open: 90, click: 60},
    %{channel: "Social", open: 140, click: 110},
    %{channel: "Search", open: 100, click: 70}
  ]}
  series={%{
    open: %{label: "Open", color: "var(--chart-1)"},
    click: %{label: "Click", color: "var(--chart-2)"}
  }}
/>
```

### Scatter

Scatter and bubble take complete Chart.js data, because each point carries its
own `x` and `y`.

```heex
<.bc_scatter_chart
  id="samples"
  chart_data={%{
    datasets: [
      %{
        label: "Samples",
        data: [%{x: 1, y: 2}, %{x: 2, y: 5}, %{x: 3, y: 3}, %{x: 4, y: 6}],
        backgroundColor: "var(--chart-1)",
        borderColor: "var(--chart-1)"
      }
    ]
  }}
  options={%{scales: %{x: %{type: "linear"}}}}
/>
```

### Bubble

Each bubble adds `r`, its radius.

```heex
<.bc_bubble_chart
  id="deals"
  chart_data={%{
    datasets: [
      %{
        label: "Deals",
        data: [%{x: 10, y: 20, r: 12}, %{x: 15, y: 10, r: 8}, %{x: 22, y: 18, r: 16}],
        backgroundColor: "color-mix(in oklab, var(--chart-2) 50%, transparent)",
        borderColor: "var(--chart-2)"
      }
    ]
  }}
  options={%{scales: %{x: %{type: "linear"}}}}
/>
```

### Mixed

A series with its own `type` mixes chart types on one canvas.

```heex
<.bc_bar_chart
  id="mixed"
  label_key="month"
  legend
  data={@rows}
  series={%{
    desktop: %{label: "Desktop", color: "var(--chart-1)"},
    mobile: %{label: "Mobile", color: "var(--chart-2)", type: "line"}
  }}
/>
```

## Collapsible

```heex
<.bc_collapsible>
  <.bc_collapsible_trigger>Show details</.bc_collapsible_trigger>
  <.bc_collapsible_content>
    <p>Hidden until opened.</p>
  </.bc_collapsible_content>
</.bc_collapsible>

<.bc_collapsible open>
  <.bc_collapsible_trigger>Open by default</.bc_collapsible_trigger>
  <.bc_collapsible_content>Visible now.</.bc_collapsible_content>
</.bc_collapsible>
```

A native `<details>`, so it works without JavaScript. `open` is initial state only; after mount the browser owns it.

Attrs: `bc_collapsible` — `open`; the trigger and content take `class`.

## Accordion

```heex
<.bc_accordion>
  <.bc_accordion_item open>
    <.bc_accordion_trigger>Shipping</.bc_accordion_trigger>
    <.bc_accordion_content>Orders ship in 2 days.</.bc_accordion_content>
  </.bc_accordion_item>
  <.bc_accordion_item>
    <.bc_accordion_trigger>Returns</.bc_accordion_trigger>
    <.bc_accordion_content>30 days, no questions asked.</.bc_accordion_content>
  </.bc_accordion_item>
  <.bc_accordion_item disabled>
    <.bc_accordion_trigger>Warranty</.bc_accordion_trigger>
    <.bc_accordion_content>Unavailable on this plan.</.bc_accordion_content>
  </.bc_accordion_item>
</.bc_accordion>
```

Basecoat closes the other items when one opens. Add `multiple` to allow several open items at once. Items are native `<details>`, so `open` is initial state.

Attrs: `bc_accordion` — `multiple`; `bc_accordion_item` — `open`, `disabled`; the trigger and content take `class`.

## Sidebar

The sidebar must be a sibling of the content wrapper: the wrapper that
immediately follows it receives the desktop margin. Basecoat styles
`.sidebar > nav`, so keep the header, content, and footer inside
`bc_sidebar_nav`.

```heex
<.bc_sidebar id="app-sidebar" side="left">
  <.bc_sidebar_nav label="Main">
    <.bc_sidebar_header>
      <.bc_button href="/" variant="ghost">Acme</.bc_button>
    </.bc_sidebar_header>
    <.bc_sidebar_content>
      <.bc_sidebar_group id="projects-group" label="Projects">
        <.bc_sidebar_menu>
          <.bc_sidebar_menu_item>
            <.bc_sidebar_menu_button href="/projects" active>All projects</.bc_sidebar_menu_button>
          </.bc_sidebar_menu_item>
          <.bc_sidebar_menu_item>
            <.bc_sidebar_menu_button href="/projects/new">New project</.bc_sidebar_menu_button>
          </.bc_sidebar_menu_item>
        </.bc_sidebar_menu>
      </.bc_sidebar_group>
      <.bc_sidebar_group id="team-group" label="Team">
        <.bc_sidebar_menu>
          <.bc_sidebar_menu_item>
            <.bc_sidebar_menu_sub id="members" label="Members">
              <.bc_sidebar_menu_item>
                <.bc_sidebar_menu_button href="/team/ada">Ada</.bc_sidebar_menu_button>
              </.bc_sidebar_menu_item>
            </.bc_sidebar_menu_sub>
          </.bc_sidebar_menu_item>
        </.bc_sidebar_menu>
      </.bc_sidebar_group>
    </.bc_sidebar_content>
    <.bc_sidebar_footer>
      <.bc_theme_switcher />
    </.bc_sidebar_footer>
  </.bc_sidebar_nav>
</.bc_sidebar>

<main>
  <.bc_sidebar_trigger sidebar="app-sidebar">Menu</.bc_sidebar_trigger>
  <h1>Content</h1>
</main>
```

`side="right"` moves it; `initial_open` and `initial_mobile_open` set the state on mount; `breakpoint` overrides the mobile cutoff. A menu button with `href` is a link, otherwise a `<button>`; `active` marks the current page and `disabled` blocks it. `variant` is `default` or `outline`, `size` is `default`, `sm`, or `lg`.

Attrs: `bc_sidebar` — `id` (required), `side` (left, right; default left), `initial_open`, `initial_mobile_open`, `breakpoint`, `class`; `bc_sidebar_nav` — `label`; `bc_sidebar_group` — `id` (required), `label` (required), `as` (default `"h3"`); `bc_sidebar_menu_button` — `href`, `variant` (default, outline), `size` (default, sm, lg), `active`, `disabled`, `class`; `bc_sidebar_menu_sub` — `id` (required), `label` (required), `open`; `bc_sidebar_trigger` — `sidebar` (required), `variant` (default outline), `class`. The header, content, footer, menu, and menu item helpers take `class`.

## Breadcrumb

```heex
<.bc_breadcrumb>
  <.bc_breadcrumb_list>
    <.bc_breadcrumb_item>
      <.bc_breadcrumb_link href="/">Home</.bc_breadcrumb_link>
    </.bc_breadcrumb_item>
    <.bc_breadcrumb_separator />
    <.bc_breadcrumb_ellipsis />
    <.bc_breadcrumb_separator />
    <.bc_breadcrumb_item>
      <.bc_breadcrumb_link href="/components">Components</.bc_breadcrumb_link>
    </.bc_breadcrumb_item>
    <.bc_breadcrumb_separator />
    <.bc_breadcrumb_item>
      <.bc_breadcrumb_page>Breadcrumb</.bc_breadcrumb_page>
    </.bc_breadcrumb_item>
  </.bc_breadcrumb_list>
</.bc_breadcrumb>
```

`bc_breadcrumb` renders `<nav>` with `aria-label`. `bc_breadcrumb_page` renders a `<span aria-current="page">`, or an `<a aria-current="page">` when it gets `href`. `bc_breadcrumb_separator` takes custom content; without it Basecoat draws its chevron. `bc_breadcrumb_ellipsis` collapses a long trail into one `…` item.

Attrs: `bc_breadcrumb` — `label` (default `"Breadcrumb"`); `bc_breadcrumb_link` — `href` (required); `bc_breadcrumb_page` — `href`; the list, item, separator, and ellipsis helpers take `class`.

## Pagination

```heex
<.bc_pagination>
  <.bc_pagination_list>
    <.bc_pagination_item>
      <.bc_pagination_previous href="/page/1" />
    </.bc_pagination_item>
    <.bc_pagination_item>
      <.bc_pagination_link href="/page/1">1</.bc_pagination_link>
    </.bc_pagination_item>
    <.bc_pagination_item>
      <.bc_pagination_link href="/page/2" current>2</.bc_pagination_link>
    </.bc_pagination_item>
    <.bc_pagination_item>
      <.bc_pagination_ellipsis />
    </.bc_pagination_item>
    <.bc_pagination_item>
      <.bc_pagination_next href="/page/3" />
    </.bc_pagination_item>
  </.bc_pagination_list>
</.bc_pagination>
```

`current` marks the active page and gives it the outline style. `bc_pagination_previous` and `bc_pagination_next` render the chevron plus their `label`, so translate the labels for other locales.

Attrs: `bc_pagination` — `label` (default `"pagination"`); `bc_pagination_link` — `href` (required), `current`; `bc_pagination_previous` — `href` (required), `label` (default `"Previous"`); `bc_pagination_next` — `href` (required), `label` (default `"Next"`); the list, item, and ellipsis helpers take `class`.

## Tabs

```heex
<.bc_tabs id="settings">
  <.bc_tab_list variant="line">
    <.bc_tab id="settings-tab-account" panel="settings-panel-account" selected>
      Account
    </.bc_tab>
    <.bc_tab id="settings-tab-password" panel="settings-panel-password">Password</.bc_tab>
    <.bc_tab id="settings-tab-billing" panel="settings-panel-billing" disabled>Billing</.bc_tab>
  </.bc_tab_list>
  <.bc_tab_panel id="settings-panel-account" labelledby="settings-tab-account">
    Account settings.
  </.bc_tab_panel>
  <.bc_tab_panel id="settings-panel-password" labelledby="settings-tab-password" hidden>
    Password settings.
  </.bc_tab_panel>
  <.bc_tab_panel id="settings-panel-billing" labelledby="settings-tab-billing" hidden>
    Billing settings.
  </.bc_tab_panel>
</.bc_tabs>
```

Vertical tabs:

```heex
<.bc_tabs id="settings-vertical">
  <.bc_tab_list orientation="vertical">
    <.bc_tab id="v-tab-account" panel="v-panel-account" selected>Account</.bc_tab>
    <.bc_tab id="v-tab-password" panel="v-panel-password">Password</.bc_tab>
  </.bc_tab_list>
  <.bc_tab_panel id="v-panel-account" labelledby="v-tab-account">Account settings.</.bc_tab_panel>
  <.bc_tab_panel id="v-panel-password" labelledby="v-tab-password" hidden>Password settings.</.bc_tab_panel>
</.bc_tabs>
```

Upstream markup is a flat tablist plus sibling panels, so the caller owns the pairing: `bc_tab` names its panel with `panel`, and `bc_tab_panel` names its tab with `labelledby`. Mark exactly one tab `selected` and give every other panel `hidden`. Basecoat keeps the selection from there.

Attrs: `bc_tabs` — `id` (required); `bc_tab_list` — `orientation` (horizontal, vertical; default horizontal), `variant` (line); `bc_tab` — `id` (required), `panel` (required), `selected`, `disabled`, `class`; `bc_tab_panel` — `id` (required), `labelledby` (required), `hidden`, `class`.

## Dropdown menu

```heex
<.bc_dropdown_menu id="account-menu">
  <.bc_dropdown_menu_trigger id="account-menu">Open</.bc_dropdown_menu_trigger>
  <.bc_dropdown_menu_content id="account-menu" class="w-40">
    <.bc_dropdown_menu_group id="account-menu-profile" label="My Account">
      <.bc_dropdown_menu_item>
        <span>Profile</span>
        <.bc_dropdown_menu_shortcut>⇧⌘P</.bc_dropdown_menu_shortcut>
      </.bc_dropdown_menu_item>
      <.bc_dropdown_menu_item phx-click="billing">Billing</.bc_dropdown_menu_item>
      <.bc_dropdown_menu_checkbox_item checked>Status bar</.bc_dropdown_menu_checkbox_item>
      <.bc_dropdown_menu_radio_item checked>Bottom</.bc_dropdown_menu_radio_item>
    </.bc_dropdown_menu_group>
    <.bc_dropdown_menu_separator />
    <.bc_dropdown_menu_group id="account-menu-more">
      <.bc_dropdown_menu_label id="account-menu-more-label">More</.bc_dropdown_menu_label>
      <.bc_dropdown_menu_item>Help</.bc_dropdown_menu_item>
    </.bc_dropdown_menu_group>
    <.bc_dropdown_menu_separator />
    <.bc_dropdown_menu_item disabled>API</.bc_dropdown_menu_item>
    <.bc_dropdown_menu_item variant="destructive" phx-click="logout">Log out</.bc_dropdown_menu_item>
  </.bc_dropdown_menu_content>
</.bc_dropdown_menu>
```

Placement and a custom trigger:

```heex
<.bc_dropdown_menu id="filters">
  <.bc_dropdown_menu_trigger id="filters" variant="ghost" size="sm">Filter</.bc_dropdown_menu_trigger>
  <.bc_dropdown_menu_content id="filters" side="top" align="end">
    <.bc_dropdown_menu_item>Newest</.bc_dropdown_menu_item>
    <.bc_dropdown_menu_item>Oldest</.bc_dropdown_menu_item>
  </.bc_dropdown_menu_content>
</.bc_dropdown_menu>
```

The menu opens under the trigger by default. When open it takes focus, typing jumps to a matching item, and Tab closes it and moves focus to the next control in the tab order. `variant="destructive"` on an item styles a dangerous action; `disabled` skips it in keyboard navigation.

Attrs: `bc_dropdown_menu` — `id` (required); `bc_dropdown_menu_trigger` — `id` (required), `variant` (default outline), `size` (default, sm, lg, icon, icon-xs, icon-sm, icon-lg); `bc_dropdown_menu_content` — `id` (required), `side` (top, bottom, left, right), `align` (start, center, end); `bc_dropdown_menu_group` — `id`, `label`; `bc_dropdown_menu_label` — `id`; `bc_dropdown_menu_item` — `disabled`, `variant` (destructive); `bc_dropdown_menu_checkbox_item`, `bc_dropdown_menu_radio_item` — `checked`, `disabled`; `bc_dropdown_menu_shortcut` — `class`. All take `class`.

## Command

```heex
<.bc_command label="Command menu">
  <.bc_command_input id="commands" placeholder="Type a command or search..." />
  <.bc_command_list id="commands" empty="No results found.">
    <.bc_command_group id="commands-suggestions" label="Suggestions">
      <.bc_command_item filter="Calendar" keywords="date event schedule">
        <span>Calendar</span>
        <.bc_command_shortcut>⌘K</.bc_command_shortcut>
      </.bc_command_item>
      <.bc_command_item filter="Search" phx-click="search">Search</.bc_command_item>
      <.bc_command_item filter="Calculator" disabled>Calculator</.bc_command_item>
    </.bc_command_group>
    <.bc_command_separator />
    <.bc_command_group id="commands-settings" label="Settings">
      <.bc_command_item filter="Profile" keep_open>Profile</.bc_command_item>
      <.bc_command_item filter="Docs" href="/docs">Docs</.bc_command_item>
    </.bc_command_group>
  </.bc_command_list>
</.bc_command>
```

Command palette in a modal:

```heex
<.bc_button phx-click="open_palette">Search…</.bc_button>

<.bc_command_dialog id="palette" label="Command menu" open={false}>
  <.bc_command>
    <.bc_command_input id="palette" placeholder="Search…" />
    <.bc_command_list id="palette" empty="No results found.">
      <.bc_command_group id="palette-suggestions" label="Suggestions">
        <.bc_command_item filter="Calendar">Calendar</.bc_command_item>
      </.bc_command_group>
    </.bc_command_list>
  </.bc_command>
</.bc_command_dialog>
```

Ids follow the upstream pattern: `bc_command_input` and `bc_command_list` take the base id and derive `ID-input` and `ID-menu`. Inside a dialog the base id is the dialog id, so `bc_command` needs no id there. `filter` is the text Basecoat matches against; `keywords` adds hidden search terms; `force` keeps an item visible whatever the filter says; `keep_open` keeps the menu open after the item runs; `href` renders a link. `manual_filter` disables Basecoat's filter when you filter on the server.

Attrs: `bc_command` — `id`, `label`, `labelledby`, `manual_filter`, `class`; `bc_command_dialog` — `id` (required), `open`, `label`, `labelledby`, `class`; `bc_command_input` — `id` (required), `placeholder` (default `"Type a command or search..."`), `value`, `class`; `bc_command_list` — `id` (required), `empty` (default `"No results found."`), `class`; `bc_command_group` — `id` (required), `label` (required); `bc_command_item` — `filter`, `keywords`, `force`, `keep_open`, `disabled`, `href`, `class`; `bc_command_shortcut` — `class`; `bc_command_separator` — `class`.

## Theme switcher

```heex
<.bc_theme_switcher />
<.bc_theme_switcher label="Switch theme" side="top" />
```

Toggles `html.dark` and stores the choice in `localStorage.themeMode`. The sun shows in dark mode, the moon in light mode. `label` is both the accessible name and the tooltip text; `side` places the tooltip.

Attrs: `label` (default `"Toggle dark mode"`), `side` (top, right, bottom, left; default bottom), `class`.

## Dialog

```heex
<.bc_dialog_trigger dialog="edit-profile">Edit profile</.bc_dialog_trigger>

<.bc_dialog id="edit-profile" title="Edit profile" description="Update your details.">
  <p>Body content.</p>
  <:footer>
    <.bc_button variant="outline" data-basecoat-dialog-close>Cancel</.bc_button>
    <.bc_button phx-click="save">Save</.bc_button>
  </:footer>
</.bc_dialog>
```

Render `open` to show it on mount. After that the dialog is client state: the
trigger, the close button, the backdrop, and Escape all close it locally. To
close it from the server, dispatch the event:

```heex
<.bc_button phx-click={JS.dispatch("basecoat:close-dialog", to: "#edit-profile")}>
  Close
</.bc_button>
```

`bc_dialog_trigger` defaults to the outline variant; `variant` takes the button variants.

Attrs: `bc_dialog` — `id` (required), `title` (required), `description`, `open`, `class`, `inner_block` slot, `footer` slot; `bc_dialog_trigger` — `dialog` (required), `variant` (default outline), `class`.

## Alert dialog

```heex
<.bc_alert_dialog_trigger dialog="delete-account" variant="destructive">
  Delete account
</.bc_alert_dialog_trigger>

<.bc_alert_dialog
  id="delete-account"
  title="Are you absolutely sure?"
  description="This action cannot be undone."
>
  <:footer>
    <.bc_button variant="outline" data-basecoat-dialog-close>Cancel</.bc_button>
    <.bc_button variant="destructive" phx-click="delete_account">Delete</.bc_button>
  </:footer>
</.bc_alert_dialog>
```

With an icon, `size="sm"`, and native `open`:

```heex
<.bc_alert_dialog id="share-project" title="Share this project?" size="sm" open>
  <:figure>
    <svg class="lucide lucide-share" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8" /><path d="m16 6-4-4-4 4" /><path d="M12 2v13" /></svg>
  </:figure>
  <:footer>
    <.bc_button variant="outline" data-basecoat-dialog-close>Cancel</.bc_button>
    <.bc_button phx-click="share">Share</.bc_button>
  </:footer>
</.bc_alert_dialog>
```

No close button and no backdrop close: the user must pick an action, as upstream requires. Escape still closes natively, so always render a cancel action. The `:figure` slot puts an icon or image above the title.

Attrs: `bc_alert_dialog` — `id` (required), `title` (required), `description`, `size` (sm), `open`, `class`, `figure` slot, `footer` slot; `bc_alert_dialog_trigger` — `dialog` (required), `variant` (default outline), `class`.

## Drawer

```heex
<.bc_drawer_trigger dialog="move-goal">Open drawer</.bc_drawer_trigger>

<.bc_drawer id="move-goal" side="right" title="Move goal" description="Set your daily goal.">
  <p>Body content.</p>
  <:footer>
    <.bc_button phx-click="submit">Submit</.bc_button>
    <.bc_button variant="outline" data-basecoat-dialog-close>Cancel</.bc_button>
  </:footer>
</.bc_drawer>
```

Sides: `top`, `right`, `bottom`, `left`. Omit `side` for the bottom drawer. Basecoat's drawer script owns the backdrop close and the exit animation.

Attrs: `bc_drawer` — `id` (required), `title` (required), `description`, `side` (top, right, bottom, left; default bottom), `open`, `class`, `footer` slot, `inner_block` slot; `bc_drawer_trigger` — `dialog` (required), `variant` (default outline), `class`.

## Sheet

```heex
<.bc_sheet_trigger dialog="edit-sheet">Edit profile</.bc_sheet_trigger>

<.bc_sheet id="edit-sheet" title="Edit profile" description="Changes are saved immediately.">
  <p>Body content.</p>
  <:footer>
    <.bc_button phx-click="save">Save</.bc_button>
    <.bc_button variant="outline" data-basecoat-dialog-close>Close</.bc_button>
  </:footer>
</.bc_sheet>
```

Defaults to the right edge; `side="left"` flips it. `close_button={false}` removes the X.

Attrs: `bc_sheet` — `id` (required), `title` (required), `description`, `side` (right, left; default right), `close_button` (default true), `open`, `class`, `footer` slot, `inner_block` slot; `bc_sheet_trigger` — `dialog` (required), `variant` (default outline), `class`.

## Popover

```heex
<.bc_popover id="dimensions">
  <.bc_popover_trigger id="dimensions">Open popover</.bc_popover_trigger>
  <.bc_popover_content id="dimensions" align="center" class="w-72">
    <header>
      <h4>Dimensions</h4>
      <p>Set the size of the layer.</p>
    </header>
    <.bc_input id="dimensions-width" name="width" value="100%" />
  </.bc_popover_content>
</.bc_popover>
```

Inline-positioned relative to the wrapper. `side` and `align` control placement; the trigger takes the button `variant` and `size` values.

Attrs: `bc_popover` — `id` (required), `class`; `bc_popover_trigger` — `id` (required), `variant` (default outline), `size` (default, sm, lg, icon, icon-xs, icon-sm, icon-lg); `bc_popover_content` — `id` (required), `side` (top, bottom, left, right), `align` (start, center, end), `class`.

## Toast

Add one toaster to the layout:

```heex
<.bc_toaster />
```

`align` places it on small screens and up: `start`, `center`, or `end` (the default).

Push from the server:

```elixir
def handle_event("save", _params, socket) do
  {:noreply, BasecoatPhoenix.Toast.push(socket, category: :success, title: "Saved")}
end
```

Push with an action link:

```elixir
def handle_event("archive", _params, socket) do
  {:noreply,
   BasecoatPhoenix.Toast.push(socket,
     title: "Conversation archived",
     action: %{label: "Undo", href: "/inbox/archived"}
   )}
end
```

Server-rendered toast:

```heex
<.bc_toast
  category="error"
  title="Event could not be created"
  description="Try again later."
  duration="5000"
>
  <:footer>
    <.bc_button variant="outline" size="sm" phx-click="retry">Retry</.bc_button>
  </:footer>
</.bc_toast>
```

Categories: `success`, `info`, `warning`, `error`, `loading`. An error toast gets `role="alert"`; the rest get `role="status"`. `duration` is milliseconds, or `-1` to keep it open. A loading toast stays until it is replaced or dismissed. `close_button={false}` removes the X, and the `:icon` slot replaces the category icon.

Attrs: `bc_toaster` — `align` (start, center, end), `class`, `inner_block` slot; `bc_toast` — `category` (success, info, warning, error, loading), `duration`, `title`, `description`, `close_button` (default true), `class`, `icon` slot, `footer` slot, `inner_block` slot.

## Carousel

```heex
<.bc_carousel id="featured" label="Featured items" class="max-w-xs">
  <.bc_carousel_content label="Slides">
    <.bc_carousel_item>
      <.bc_card>
        <.bc_card_content>First</.bc_card_content>
      </.bc_card>
    </.bc_carousel_item>
    <.bc_carousel_item>
      <.bc_card>
        <.bc_card_content>Second</.bc_card_content>
      </.bc_card>
    </.bc_carousel_item>
  </.bc_carousel_content>
  <.bc_carousel_previous />
  <.bc_carousel_next />
</.bc_carousel>
```

The buttons are direct children of the carousel, Previous before Next, and stay `hidden` until Basecoat initializes them. They also work with touch and trackpad scrolling without JavaScript. `bc_carousel` needs `id` and `label` (its accessible name).

Attrs: `bc_carousel` — `id` (required), `label` (required), `class`; `bc_carousel_content` — `label` (default `"Slides"`); `bc_carousel_item` — `class`; `bc_carousel_previous` — `label` (default `"Previous slide"`); `bc_carousel_next` — `label` (default `"Next slide"`).

---

## Forms

Every form control accepts `field` (a `Phoenix.HTML.FormField`) and derives its
id, name, and value from it. Validation is exposed through `aria-invalid`, not a
CSS class.

### Label, input, textarea

```heex
<.bc_label for="name">Name</.bc_label>

<.bc_field>
  <.bc_field_label for="name">Name</.bc_field_label>
  <.bc_input id="name" name="name" placeholder="Ada Lovelace" />
  <.bc_field_description id="name">How it appears on your profile.</.bc_field_description>
</.bc_field>

<.bc_field>
  <.bc_field_label for="bio">Bio</.bc_field_label>
  <.bc_textarea id="bio" name="bio" placeholder="Tell us about yourself" />
</.bc_field>

<.bc_field>
  <.bc_field_label for="email">Email</.bc_field_label>
  <.bc_input id="email" name="email" type="email" invalid />
  <.bc_field_error id="email">Enter a valid email address.</.bc_field_error>
</.bc_field>
```

Input types and a description that is wired to the control:

```heex
<.bc_input id="password" name="password" type="password" value="hunter2" />
<.bc_input id="search" name="search" type="search" placeholder="Search…" />
<.bc_input id="phone" name="phone" type="tel" describedby="phone-hint" has_description />
<.bc_field_description id="phone-hint">Include the country code.</.bc_field_description>
```

`invalid` sets `aria-invalid="true"`. `describedby` adds `aria-describedby`; `has_description` tells the control to point at the description element with its own id. `errors` is a list of error strings, used by the Ecto helper path.

Attrs: `bc_input` — `id`, `name`, `type` (default `"text"`), `value`, `placeholder`, `field`, `errors`, `invalid`, `describedby`, `has_description`, `class`; `bc_textarea` — the same without `type`; `bc_label` — `for`; `bc_field_label` — `for`.

### Fieldset

```heex
<.bc_fieldset legend="Notification preferences">
  <.bc_field>
    <.bc_field_label for="digest">Weekly digest</.bc_field_label>
    <.bc_native_select
      id="digest"
      name="digest"
      options={[
        %{value: "daily", label: "Daily"},
        %{value: "weekly", label: "Weekly"},
        %{value: "never", label: "Never"}
      ]}
    />
  </.bc_field>
</.bc_fieldset>
```

`as="div"` renders a `div role="group"` instead of a `<fieldset>`. `bc_field` is the row; `orientation="horizontal"` puts the label beside the control.

Attrs: `bc_fieldset` — `legend`, `as` (default `"fieldset"`), `class`; `bc_field` — `orientation` (horizontal), `class`; `bc_field_description`, `bc_field_error` — `id` (required), `class`.

### Native select

```heex
<.bc_native_select
  id="fruit"
  name="fruit"
  value="banana"
  options={[
    %{value: "apple", label: "Apple"},
    %{value: "banana", label: "Banana"},
    %{value: "cherry", label: "Cherry", disabled: true}
  ]}
/>

<.bc_native_select id="size" name="size">
  <option value="s">Small</option>
  <option value="m" selected>Medium</option>
  <option value="l">Large</option>
</.bc_native_select>
```

A real `<select>`: the browser owns the dropdown, so it needs no JavaScript and submits normally. Add `multiple` for multi-select. Use the `inner_block` slot when you need `<optgroup>` or custom options.

Attrs: `id`, `name`, `value`, `field`, `options`, `multiple`, `class`, `inner_block` slot.

### Select

```heex
<.bc_select
  id="framework"
  name="framework"
  placeholder="Select a framework"
  value="remix"
  options={[
    %{value: "next", label: "Next.js"},
    %{value: "remix", label: "Remix"},
    %{
      label: "Others",
      options: [
        %{value: "astro", label: "Astro"},
        %{value: "svelte", label: "SvelteKit"}
      ]
    }
  ]}
/>
```

Multiple, JSON-encoded into the hidden input:

```heex
<.bc_select
  id="tags"
  name="tags"
  multiple
  value={["elixir", "phoenix"]}
  options={[
    %{value: "elixir", label: "Elixir"},
    %{value: "phoenix", label: "Phoenix"},
    %{value: "erlang", label: "Erlang"}
  ]}
/>
```

Read it back with `BasecoatPhoenix.Forms.decode_multi/1`.

Object format, where each selection carries its label:

```heex
<.bc_select
  id="owner"
  name="owner"
  format="object"
  options={[%{value: "ada", label: "Ada Lovelace"}, %{value: "grace", label: "Grace Hopper"}]}
/>
```

The listbox is Basecoat's, not a native `<select>`: the trigger gets `role="combobox"`, the highlighted option is exposed with `aria-activedescendant`, typing jumps to a match, and the value lives in a hidden input so the enclosing form still submits. A server-side `options` change refreshes the list.

Attrs: `id` (required), `name`, `field`, `options` (required), `value`, `multiple`, `format` (object), `placeholder`, `class`.

### Combobox

```heex
<.bc_combobox
  id="assignee"
  name="assignee"
  placeholder="Assign to…"
  options={[
    %{value: "ada", label: "Ada Lovelace"},
    %{value: "grace", label: "Grace Hopper"}
  ]}
/>
```

Multi-select with a clear button and custom empty text:

```heex
<.bc_combobox
  id="labels"
  name="labels"
  multiple
  clear
  empty="No label matches."
  value={["bug"]}
  options={[
    %{value: "bug", label: "Bug"},
    %{value: "feature", label: "Feature"},
    %{value: "chore", label: "Chore"}
  ]}
/>
```

Same option shape and hidden-input encoding as `bc_select`, with a text input that filters the list as you type.

Attrs: `id` (required), `name`, `field`, `options`, `value`, `multiple`, `format` (object), `placeholder`, `clear`, `empty` (default `"No items found."`), `class`.

### Checkbox

```heex
<.bc_checkbox id="terms" name="terms">Accept the terms</.bc_checkbox>

<.bc_checkbox id="news" name="news" description="One email per week.">
  Product news
</.bc_checkbox>

<.bc_checkbox id="locked" name="locked" checked disabled>
  Locked
</.bc_checkbox>
```

`description` renders helper text under the label. The slot is the label text; the wrapper is Basecoat's field layout.

Attrs: `id`, `name`, `value`, `checked`, `disabled`, `description`, `field`, `class`.

### Radio group

```heex
<.bc_radio_group label="Plan">
  <.bc_radio_group_item id="plan-free" name="plan" value="free" checked>
    Free
  </.bc_radio_group_item>
  <.bc_radio_group_item id="plan-pro" name="plan" value="pro">
    Pro
  </.bc_radio_group_item>
  <.bc_radio_group_item id="plan-team" name="plan" value="team" disabled>
    Team
  </.bc_radio_group_item>
</.bc_radio_group>
```

`label` on the group becomes its accessible name. Items sharing a `name` form one group; the browser enforces the single choice.

Attrs: `bc_radio_group` — `label`, `class`; `bc_radio_group_item` — `id` (required), `name` (required), `value` (required), `checked`, `disabled`, `field`, `class`.

### Switch

```heex
<.bc_switch id="airplane" name="airplane">Airplane mode</.bc_switch>
<.bc_switch id="wifi" name="wifi" checked>Wi-Fi</.bc_switch>
<.bc_switch id="locked" name="locked" checked disabled>Locked</.bc_switch>
```

A native checkbox with `role="switch"`: it submits like a checkbox and keeps native keyboard behavior.

Attrs: `id`, `name`, `value`, `checked`, `disabled`, `field`, `class`.

### Toggle

```heex
<.bc_toggle name="bold" value="bold">Bold</.bc_toggle>
<.bc_toggle name="italic" value="italic" checked variant="outline">Italic</.bc_toggle>
<.bc_toggle name="strike" value="strike" variant="ghost" size="sm">Strike</.bc_toggle>
<.bc_toggle type="radio" name="align" value="left" checked>Left</.bc_toggle>
```

A checkbox or radio inside a `.btn` label. `variant` is `ghost` or `outline`; omit it for the primary style. `size` takes the button sizes. `type="radio"` gives single-choice behavior inside a form.

Attrs: `id`, `name`, `value`, `type` (checkbox, radio; default checkbox), `checked`, `disabled`, `variant` (ghost, outline), `size` (xs, sm, default, lg, icon, icon-xs, icon-sm, icon-lg), `field`, `class`.

### Toggle group

```heex
<.bc_toggle_group
  legend="Alignment"
  name="align"
  single
  value="left"
  variant="outline"
  size="sm"
  options={[
    %{value: "left", label: "Left"},
    %{value: "center", label: "Center"},
    %{value: "right", label: "Right"}
  ]}
/>
```

`single` renders radios, otherwise checkboxes. Custom items:

```heex
<.bc_toggle_group legend="Formatting">
  <.bc_toggle_group_item name="format" value="bold" checked>
    <.bc_kbd>B</.bc_kbd>
  </.bc_toggle_group_item>
  <.bc_toggle_group_item name="format" value="italic">
    <.bc_kbd>I</.bc_kbd>
  </.bc_toggle_group_item>
</.bc_toggle_group>
```

Attrs: `bc_toggle_group` — `legend` (required), `name`, `options`, `value`, `single`, `variant` (default outline), `size` (xs, sm, default, lg), `inner_block` slot; `bc_toggle_group_item` — `name` (required), `value` (required), `type` (checkbox, radio; default checkbox), `checked`, `disabled`, `variant` (default outline), `size`, `class`.

### Slider

```heex
<.bc_slider id="volume" name="volume" value={30} min={0} max={100} step={5} />
```

A native range input. The filled track is rendered from `value`, and Basecoat's controller keeps it in sync while the user drags. `step` defaults to the browser's.

Attrs: `id` (required), `name`, `field`, `min` (default 0), `max` (default 100), `step`, `value`, `class`.

### Input group

```heex
<.bc_input_group>
  <.bc_input_group_addon>https://</.bc_input_group_addon>
  <.bc_input id="site" name="site" placeholder="example.com" />
  <.bc_input_group_button label="Copy" phx-click="copy">.com</.bc_input_group_button>
</.bc_input_group>
```

Vertical layout, and an addon aligned to the block edges:

```heex
<.bc_input_group orientation="vertical">
  <.bc_input_group_addon align="block-start">Amount</.bc_input_group_addon>
  <.bc_input id="amount" name="amount" type="number" />
</.bc_input_group>
```

`bc_input_group_button` renders a `<button>` by default; `as="div"` renders a `role="group"` wrapper for several controls. `label` becomes its `aria-label`.

Attrs: `bc_input_group` — `orientation` (vertical), `class`; `bc_input_group_addon` — `align` (start, end, block-start, block-end, inline-start, inline-end), `class`; `bc_input_group_button` — `as` (default `"button"`), `type` (default `"button"`), `label`, `align`, `class`.

### Input OTP

```heex
<.bc_input_otp id="code" name="code" length={6} />
<.bc_input_otp id="pin" name="pin" length={4} label="PIN" pattern="[0-9]*" />
```

A one-time-code input with one slot per character. `filter` adds Basecoat's filter, which enforces `pattern` while typing and pasting, so use a partial-friendly pattern such as `[0-9]+`. `pattern` also sets the native input pattern. It carries `phx-update="ignore"` because Basecoat writes into the slot spans, so render it once and let the client own the digits. The real input still submits.

Attrs: `id` (required), `name`, `field`, `length` (default 6), `value`, `filter`, `pattern`, `label` (default `"Verification code"`), `disabled`, `class`.

### Ecto changeset fields

Every form control accepts `field` (a `Phoenix.HTML.FormField`) and derives id,
name, value, and error state:

```heex
<.bc_field>
  <.bc_field_label for={@form[:email].id}>Email</.bc_field_label>
  <.bc_input field={@form[:email]} />
  <.bc_field_error :for={error <- @form[:email].errors} id={@form[:email].id}>
    {translate_error(error)}
  </.bc_field_error>
</.bc_field>

<.bc_select
  id={@form[:plan].id}
  field={@form[:plan]}
  options={[%{value: "free", label: "Free"}, %{value: "pro", label: "Pro"}]}
/>
```

`bc_input` and `bc_textarea` also take `errors` directly. `bc_checkbox`,
`bc_switch`, `bc_toggle`, `bc_radio_group_item`, `bc_slider`, `bc_input_otp`,
`bc_native_select`, `bc_select`, and `bc_combobox` accept `field` too.

---

## Messaging

### Bubble

```heex
<.bc_bubble_group>
  <.bc_bubble>Hey, is the build green?</.bc_bubble>
  <.bc_bubble variant="muted" align="start">All green.</.bc_bubble>
  <.bc_bubble variant="outline" align="start">Outline</.bc_bubble>
  <.bc_bubble variant="secondary" align="end">Secondary</.bc_bubble>
  <.bc_bubble variant="tinted" align="end">Tinted</.bc_bubble>
  <.bc_bubble variant="ghost">Ghost</.bc_bubble>
  <.bc_bubble variant="destructive" align="end">Failed</.bc_bubble>
</.bc_bubble_group>
```

Omit `variant` for the primary style. `align="end"` marks an outgoing message. `bc_bubble_group` is a column flex layout so bubbles can align.

With reactions:

```heex
<.bc_bubble variant="muted" align="start">
  Nice work!
  <:reactions label="2 reactions" side="top" align="end">🎉 2</:reactions>
</.bc_bubble>
```

Attrs: `bc_bubble` — `variant` (secondary, muted, tinted, outline, ghost, destructive; default primary), `align` (start, end), `class`, `reactions` slot (`label`, `side`, `align`); `bc_bubble_group` — `as` (default `"div"`), `label`, `class`.

### Message

```heex
<.bc_message_group label="Conversation">
  <.bc_message>
    <.bc_avatar><.bc_avatar_fallback>AL</.bc_avatar_fallback></.bc_avatar>
    <.bc_bubble>Ship it.</.bc_bubble>
  </.bc_message>
  <.bc_message align="end">
    <.bc_bubble>Shipped.</.bc_bubble>
  </.bc_message>
</.bc_message_group>
```

One conversation turn per message. The caller composes the avatar, sender, and bubble inside the slot; the component only supplies the row. `bc_message` renders `<li>` by default and `bc_message_group` renders a labelled list.

Attrs: `bc_message` — `as` (default `"li"`), `align` (start, end), `class`; `bc_message_group` — `label`, `class`.

### Marker

```heex
<.bc_marker>Today</.bc_marker>
<.bc_marker role="status">Online</.bc_marker>
<.bc_marker shimmer role="status">Thinking…</.bc_marker>
<.bc_marker variant="border">Draft</.bc_marker>
<.bc_marker variant="separator">Yesterday</.bc_marker>
```

`separator` draws rules on both sides; `border` frames the marker. `shimmer` animates the text while a status is pending, and falls back to static text with reduced motion or without relative-color support. Add `role="status"` when the text updates on its own, and use a real `<a>` or `<button>` for actions.

Attrs: `variant` (separator, border), `shimmer`, `icon` slot, `class`.

### Attachment

```heex
<.bc_attachment>
  <.bc_attachment_media>
    <.bc_avatar><.bc_avatar_fallback>PDF</.bc_avatar_fallback></.bc_avatar>
  </.bc_attachment_media>
  <.bc_attachment_content>
    <.bc_attachment_title>invoice.pdf</.bc_attachment_title>
    <.bc_attachment_description>128 KB</.bc_attachment_description>
  </.bc_attachment_content>
  <.bc_attachment_actions>
    <.bc_button variant="ghost" size="icon-sm" aria-label="Remove">×</.bc_button>
  </.bc_attachment_actions>
</.bc_attachment>
```

Vertical, uploading, and in a list:

```heex
<.bc_attachment orientation="vertical" state="uploading">
  <.bc_attachment_media>
    <img src="/images/cover.png" alt="" />
  </.bc_attachment_media>
  <.bc_attachment_content>
    <.bc_attachment_title>cover.png</.bc_attachment_title>
    <.bc_attachment_description>Uploading…</.bc_attachment_description>
  </.bc_attachment_content>
</.bc_attachment>

<.bc_attachment as="li" state="error" data-size="sm">
  <.bc_attachment_content>
    <.bc_attachment_title>broken.zip</.bc_attachment_title>
    <.bc_attachment_description>Upload failed.</.bc_attachment_description>
  </.bc_attachment_content>
</.bc_attachment>
```

Children go in upstream order: media, content, an optional full-card `<a>` or `<button>`, then actions. `state` is `idle`, `uploading`, `processing`, or `error`; `data-size="sm"` or `"xs"` passes through `{@rest}`.

Attrs: `as` (default `"div"`), `orientation` (vertical), `state` (idle, uploading, processing, error), `class`. The media, content, title, description, and actions helpers take `class`.

### Trace

```heex
<.bc_trace label="Agent steps">
  <.bc_trace_item details open>
    <.bc_trace_line meta="1.2s">Searched the docs</.bc_trace_line>
    <.bc_trace_detail>Found 3 relevant pages.</.bc_trace_detail>
  </.bc_trace_item>
  <.bc_trace_item>
    <.bc_trace_line>Wrote the summary</.bc_trace_line>
  </.bc_trace_item>
  <.bc_trace_item>
    <.bc_trace_line href="/runs/42" meta="view">Open run</.bc_trace_line>
  </.bc_trace_item>
</.bc_trace>
```

One line per item. `details` makes the line a `<summary>` with the detail slot
below it; otherwise the line is static, a paragraph (`as="p"`), or a link
(`href`). `meta` renders right-aligned small text, and the `:icon` slot puts an
icon before the text.

Attrs: `bc_trace` — `label`, `class`; `bc_trace_item` — `details`, `open`, `class`; `bc_trace_line` — `as`, `href`, `meta`, `class`, `icon` slot; `bc_trace_detail` — `class`.

## Patterns without components

These upstream pages are attributes and utilities, not components. Use them
directly in your markup:

- **Direction** — set `dir="rtl"` on a wrapper; icons marked `data-rtl-flip`
  mirror.
- **Aspect ratio** — `<div class="aspect-video">…</div>`.
- **Scroll area** — add `class="scrollbar"` to a scrollable element.
- **Data table** — compose `bc_table_*` with your own sorting and paging.
- **Tooltip** — `<button data-tooltip="Copy" data-side="bottom">…</button>`.
  It shows on hover and on keyboard focus; `data-side` is `top`, `right`,
  `bottom`, or `left`.
