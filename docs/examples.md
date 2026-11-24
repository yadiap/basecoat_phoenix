# Basecoat Phoenix examples

Copy-paste examples for every component. Each snippet is verified to compile
against the library.

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

---

## Button

```heex
<.bc_button>Save</.bc_button>
<.bc_button variant="outline" size="sm">Cancel</.bc_button>
<.bc_button variant="destructive" phx-click="delete">Delete</.bc_button>
<.bc_button href="/settings" variant="ghost">Settings</.bc_button>
<.bc_button disabled>Disabled</.bc_button>
```

`href` renders an `<a>`; otherwise a `<button type="button">`. Omit `variant`
for the primary style.

## Button group

```heex
<.bc_button_group label="Zoom">
  <.bc_button variant="outline" size="sm" phx-click="zoom_out">−</.bc_button>
  <.bc_button variant="outline" size="sm" phx-click="zoom_in">+</.bc_button>
</.bc_button_group>
```

## Badge

```heex
<.bc_badge>New</.bc_badge>
<.bc_badge variant="secondary">Draft</.bc_badge>
<.bc_badge variant="outline">v1.2.1</.bc_badge>
<.bc_badge variant="destructive">Failed</.bc_badge>
```

## Kbd

```heex
Press <.bc_kbd>⌘K</.bc_kbd> to search.
```

## Separator

```heex
<.bc_separator />
<.bc_separator orientation="vertical" class="h-6" />
<.bc_separator decorative />
```

## Skeleton

```heex
<.bc_skeleton class="h-4 w-48" />
<.bc_skeleton class="h-24 w-full" />
```

## Spinner

```heex
<.bc_spinner />
<.bc_spinner label="Saving" class="size-4" />
```

`label` renders visible text next to the spinner; the SVG is then
`aria-hidden` and the wrapper carries `role="status"`.

## Progress

```heex
<.bc_progress value={30} label="Upload" />
<.bc_progress value={7} max={10} label="Steps" />
```

`label` renders the upstream labeled layout: label and percentage above the
bar. Omit it for a bare bar.

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

## Alert

```heex
<.bc_alert variant="success">
  <:icon>
    <svg class="lucide lucide-check" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5" /></svg>
  </:icon>
  <.bc_alert_title>Payment succeeded</.bc_alert_title>
  <.bc_alert_description>Your plan is active until next month.</.bc_alert_description>
  <.bc_alert_actions>
    <.bc_button variant="outline" size="sm">View invoice</.bc_button>
  </.bc_alert_actions>
</.bc_alert>

<.bc_alert variant="destructive">
  <.bc_alert_title>Something went wrong</.bc_alert_title>
  <.bc_alert_description>Retry, or contact support.</.bc_alert_description>
</.bc_alert>
```

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

<.bc_item href="/invoices/42" variant="outline">
  <.bc_item_content>
    <.bc_item_title>Invoice 42</.bc_item_title>
    <.bc_item_description>Paid on Monday</.bc_item_description>
  </.bc_item_content>
</.bc_item>

<.bc_item>
  <.bc_item_header>
    <.bc_item_title>Deploy</.bc_item_title>
  </.bc_item_header>
  <.bc_item_content>All checks passed.</.bc_item_content>
  <.bc_item_footer>
    <.bc_badge variant="secondary">2 minutes ago</.bc_badge>
  </.bc_item_footer>
</.bc_item>
```

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

The code body is yours: put `data-line-numbers` on the `<pre>` to number lines.

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

  {:ok, assign(socket, rows: rows, sources: sources)}
end
```

### Bar

```heex
<.bc_bar_chart
  id="visitors"
  label_key="month"
  legend
  data={[
    %{month: "Jan", desktop: 186, mobile: 80},
    %{month: "Feb", desktop: 305, mobile: 200},
    %{month: "Mar", desktop: 237, mobile: 120}
  ]}
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
</.bc_accordion>
```

Add `multiple` to allow several open items at once.

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

## Tabs

```heex
<.bc_tabs id="settings">
  <.bc_tab_list variant="line">
    <.bc_tab id="settings-tab-account" panel="settings-panel-account" selected>
      Account
    </.bc_tab>
    <.bc_tab id="settings-tab-password" panel="settings-panel-password">Password</.bc_tab>
  </.bc_tab_list>
  <.bc_tab_panel id="settings-panel-account" labelledby="settings-tab-account">
    Account settings.
  </.bc_tab_panel>
  <.bc_tab_panel id="settings-panel-password" labelledby="settings-tab-password" hidden>
    Password settings.
  </.bc_tab_panel>
</.bc_tabs>
```

The caller marks one tab `selected`; Basecoat keeps the selection.

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
  </.bc_dropdown_menu_content>
</.bc_dropdown_menu>
```

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

## Theme switcher

```heex
<.bc_theme_switcher />
<.bc_theme_switcher label="Switch theme" side="top" />
```

Toggles `html.dark` and stores the choice in `localStorage.themeMode`.

## Dialog

```heex
<.bc_dialog_trigger dialog="edit-profile">Edit profile</.bc_dialog_trigger>

<.bc_dialog id="edit-profile" title="Edit profile" description="Update your details.">
  <p>Body content.</p>
  <:footer>
    <.bc_button variant="outline">Cancel</.bc_button>
    <.bc_button phx-click="save">Save</.bc_button>
  </:footer>
</.bc_dialog>
```

Render `open` to show it on mount.

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

Sides: `top`, `right`, `bottom`, `left`. Omit `side` for the bottom drawer.

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

Defaults to the right edge. `close_button={false}` removes the X.

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

## Toast

Add one toaster to the layout:

```heex
<.bc_toaster />
```

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

Buttons stay `hidden` until Basecoat initializes them.

---

## Forms

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

`as="div"` renders a `div role="group"` instead of a `<fieldset>`.

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

Add `clear` for a clear button, `multiple` for multi-select, `empty="No match."`
to change the empty text.

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

### Radio group

```heex
<.bc_radio_group label="Plan">
  <.bc_radio_group_item id="plan-free" name="plan" value="free" checked>
    Free
  </.bc_radio_group_item>
  <.bc_radio_group_item id="plan-pro" name="plan" value="pro">
    Pro
  </.bc_radio_group_item>
</.bc_radio_group>
```

### Switch

```heex
<.bc_switch id="airplane" name="airplane">Airplane mode</.bc_switch>
<.bc_switch id="wifi" name="wifi" checked>Wi-Fi</.bc_switch>
```

### Toggle

```heex
<.bc_toggle name="bold" value="bold">Bold</.bc_toggle>
<.bc_toggle name="italic" value="italic" checked variant="outline">Italic</.bc_toggle>
```

### Toggle group

```heex
<.bc_toggle_group
  legend="Alignment"
  name="align"
  single
  value="left"
  options={[
    %{value: "left", label: "Left"},
    %{value: "center", label: "Center"},
    %{value: "right", label: "Right"}
  ]}
/>
```

Custom items:

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

### Slider

```heex
<.bc_slider id="volume" name="volume" value={30} min={0} max={100} step={5} />
```

### Input group

```heex
<.bc_input_group>
  <.bc_input_group_addon>https://</.bc_input_group_addon>
  <.bc_input id="site" name="site" placeholder="example.com" />
  <.bc_input_group_button label="Copy" phx-click="copy">.com</.bc_input_group_button>
</.bc_input_group>
```

### Input OTP

```heex
<.bc_input_otp id="code" name="code" length={6} />
```

It carries `phx-update="ignore"` because Basecoat writes into the slot spans.

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

---

## Messaging

### Bubble

```heex
<.bc_bubble_group>
  <.bc_bubble>Hey, is the build green?</.bc_bubble>
  <.bc_bubble variant="muted" align="start">All green.</.bc_bubble>
</.bc_bubble_group>
```

With reactions:

```heex
<.bc_bubble variant="muted" align="start">
  Nice work!
  <:reactions label="2 reactions" side="top" align="end">🎉 2</:reactions>
</.bc_bubble>
```

### Message

```heex
<.bc_message_group label="Conversation">
  <.bc_message>
    <.bc_avatar><.bc_avatar_fallback>AL</.bc_avatar_fallback></.bc_avatar>
    <.bc_bubble>Ship it.</.bc_bubble>
  </.bc_message>
  <.bc_message align="end">
    <.bc_bubble variant="primary">Shipped.</.bc_bubble>
  </.bc_message>
</.bc_message_group>
```

### Marker

```heex
<.bc_marker>Today</.bc_marker>
<.bc_marker variant="success">Online</.bc_marker>
<.bc_marker shimmer>Thinking…</.bc_marker>
```

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

States and orientation: `state="uploading" | "error"`, `orientation="vertical"`.

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

## Patterns without components

These upstream pages are attributes and utilities, not components. Use them
directly in your markup:

- **Direction** — set `dir="rtl"` on a wrapper; icons marked `data-rtl-flip`
  mirror.
- **Aspect ratio** — `<div class="aspect-video">…</div>`.
- **Scroll area** — add `class="scrollbar"` to a scrollable element.
- **Data table** — compose `bc_table_*` with your own sorting and paging.
- **Tooltip** — `<button data-tooltip="Copy" data-side="bottom">…</button>`.
