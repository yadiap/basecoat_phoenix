defmodule BasecoatPhoenix.Components.NavigationFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Breadcrumb
  import BasecoatPhoenix.Components.Pagination
  import BasecoatPhoenix.Components.Tabs
  import BasecoatPhoenix.Components.DropdownMenu
  import BasecoatPhoenix.Components.Command
  import BasecoatPhoenix.Components.ThemeSwitcher

  def breadcrumb(assigns) do
    ~H"""
    <.bc_breadcrumb>
      <.bc_breadcrumb_list>
        <.bc_breadcrumb_item>
          <.bc_breadcrumb_link href="#">Home</.bc_breadcrumb_link>
        </.bc_breadcrumb_item>
        <.bc_breadcrumb_separator />
        <.bc_breadcrumb_item>
          <.bc_breadcrumb_link href="#">Components</.bc_breadcrumb_link>
        </.bc_breadcrumb_item>
        <.bc_breadcrumb_separator />
        <.bc_breadcrumb_item>
          <.bc_breadcrumb_page>Breadcrumb</.bc_breadcrumb_page>
        </.bc_breadcrumb_item>
      </.bc_breadcrumb_list>
    </.bc_breadcrumb>
    """
  end

  def breadcrumb_ellipsis(assigns) do
    ~H"""
    <.bc_breadcrumb_ellipsis />
    """
  end

  def pagination(assigns) do
    ~H"""
    <.bc_pagination>
      <.bc_pagination_list>
        <.bc_pagination_item>
          <.bc_pagination_previous href="#" />
        </.bc_pagination_item>
        <.bc_pagination_item>
          <.bc_pagination_link href="#">1</.bc_pagination_link>
        </.bc_pagination_item>
        <.bc_pagination_item>
          <.bc_pagination_link href="#" current>2</.bc_pagination_link>
        </.bc_pagination_item>
        <.bc_pagination_item>
          <.bc_pagination_ellipsis />
        </.bc_pagination_item>
        <.bc_pagination_item>
          <.bc_pagination_next href="#" />
        </.bc_pagination_item>
      </.bc_pagination_list>
    </.bc_pagination>
    """
  end

  def tabs(assigns) do
    ~H"""
    <.bc_tabs id="demo-tabs">
      <.bc_tab_list variant="line">
        <.bc_tab id="demo-tabs-tab-1" panel="demo-tabs-panel-1" selected>Account</.bc_tab>
        <.bc_tab id="demo-tabs-tab-2" panel="demo-tabs-panel-2" disabled>Password</.bc_tab>
      </.bc_tab_list>
      <.bc_tab_panel id="demo-tabs-panel-1" labelledby="demo-tabs-tab-1">
        Account content.
      </.bc_tab_panel>
      <.bc_tab_panel id="demo-tabs-panel-2" labelledby="demo-tabs-tab-2" hidden>
        Password content.
      </.bc_tab_panel>
    </.bc_tabs>
    """
  end

  def dropdown_menu(assigns) do
    ~H"""
    <.bc_dropdown_menu id="account-menu">
      <.bc_dropdown_menu_trigger id="account-menu">Open</.bc_dropdown_menu_trigger>
      <.bc_dropdown_menu_content id="account-menu" class="w-40">
        <.bc_dropdown_menu_group id="account-menu-account" label="My Account">
          <.bc_dropdown_menu_item>
            <span>Profile</span>
            <.bc_dropdown_menu_shortcut>⇧⌘P</.bc_dropdown_menu_shortcut>
          </.bc_dropdown_menu_item>
          <.bc_dropdown_menu_checkbox_item checked>Status Bar</.bc_dropdown_menu_checkbox_item>
          <.bc_dropdown_menu_radio_item checked>Bottom</.bc_dropdown_menu_radio_item>
        </.bc_dropdown_menu_group>
        <.bc_dropdown_menu_separator />
        <.bc_dropdown_menu_item disabled>API</.bc_dropdown_menu_item>
      </.bc_dropdown_menu_content>
    </.bc_dropdown_menu>
    """
  end

  def command(assigns) do
    ~H"""
    <.bc_command id="demo-command" label="Command menu">
      <.bc_command_input id="demo-command" placeholder="Type a command or search..." />
      <.bc_command_list id="demo-command" empty="No results found.">
        <.bc_command_group id="demo-command-suggestions" label="Suggestions">
          <.bc_command_item filter="Calendar" keywords="date event schedule">
            <span>Calendar</span>
            <.bc_command_shortcut>⌘K</.bc_command_shortcut>
          </.bc_command_item>
          <.bc_command_item filter="Calculator" disabled>Calculator</.bc_command_item>
        </.bc_command_group>
        <.bc_command_separator />
      </.bc_command_list>
    </.bc_command>
    """
  end

  def command_dialog(assigns) do
    ~H"""
    <.bc_command_dialog id="command-palette" label="Command menu" open>
      <.bc_command>
        <.bc_command_input id="command-palette" placeholder="Search..." />
        <.bc_command_list id="command-palette" empty="No results found.">
          <.bc_command_group id="command-palette-suggestions" label="Suggestions">
            <.bc_command_item filter="Calendar" force keep_open>Calendar</.bc_command_item>
          </.bc_command_group>
        </.bc_command_list>
      </.bc_command>
    </.bc_command_dialog>
    """
  end

  def theme_switcher(assigns) do
    ~H"""
    <.bc_theme_switcher />
    """
  end
end

defmodule BasecoatPhoenix.Components.NavigationTest do
  use BasecoatPhoenix.ComponentCase

  test "bc_breadcrumb matches the upstream structure" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.breadcrumb/1, %{})

    nav = one(html, "nav.breadcrumb")
    assert attr(nav, "aria-label") == "Breadcrumb"

    items = Floki.find(nav, "ol > li")
    assert length(items) == 5

    assert attr(one(nav, "li > a"), "href") == "#"
    assert text(one(nav, "a[aria-current=page], [aria-current=page]")) == "Breadcrumb"

    separator = one(nav, "li[aria-hidden=true]")
    assert attr(one(separator, "svg"), "data-rtl-flip")
    assert classes(one(separator, "svg")) == ["lucide", "lucide-chevron-right"]
  end

  test "bc_breadcrumb_ellipsis renders a hidden span" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.breadcrumb_ellipsis/1, %{})

    span = one(html, "li > span")
    assert attr(span, "aria-hidden") == "true"
    assert text(span) |> String.trim() == "…"
  end

  test "bc_pagination matches the upstream classes and chevrons" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.pagination/1, %{})

    nav = one(html, "nav[role=navigation]")
    assert attr(nav, "aria-label") == "pagination"
    assert classes(nav) == ["mx-auto", "flex", "w-full", "justify-center"]

    list = one(nav, "ul")
    assert classes(list) == ["flex", "flex-row", "items-center", "gap-1"]

    previous = one(list, "li > a.btn[data-variant=ghost]")
    assert one(previous, "svg.lucide-chevron-left")
    assert text(one(previous, "span")) == "Previous"

    assert classes(one(list, "a.btn[data-size=icon][data-variant=ghost]")) == ["btn"]
    assert attr(one(list, "a[data-variant=outline]"), "data-size") == "icon"

    ellipsis = one(list, "div.size-9")
    assert classes(ellipsis) == ["size-9", "flex", "items-center", "justify-center"]
    assert one(ellipsis, "svg.size-4.shrink-0.lucide-ellipsis")

    next = one(list, "li:last-child > a.btn")
    assert text(one(next, "span")) == "Next"
    assert one(next, "svg.lucide-chevron-right")

    refute one(nav, ".pagination")
  end

  test "bc_tabs renders the tablist, tabs, and panels" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.tabs/1, %{})

    root = one(html, "div.tabs#demo-tabs")
    assert attr(root, "phx-hook") == "BasecoatState"

    nav = one(root, "nav[role=tablist]")
    assert attr(nav, "aria-orientation") == "horizontal"
    assert attr(nav, "data-variant") == "line"

    tabs = Floki.find(nav, "button[role=tab]")
    assert length(tabs) == 2

    [first, second] = tabs
    assert attr(first, "id") == "demo-tabs-tab-1"
    assert attr(first, "aria-controls") == "demo-tabs-panel-1"
    assert attr(first, "aria-selected") == "true"
    assert attr(first, "tabindex") == "0"

    assert attr(second, "aria-selected") == "false"
    assert attr(second, "tabindex") == "-1"
    assert attr(second, "disabled")

    panel = one(root, "div[role=tabpanel]#demo-tabs-panel-1")
    assert attr(panel, "aria-labelledby") == "demo-tabs-tab-1"
    assert attr(panel, "tabindex") == "-1"
    refute attr(panel, "hidden")

    assert attr(one(root, "div#demo-tabs-panel-2"), "hidden")
  end

  test "bc_dropdown_menu renders the trigger, popover, and menu" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.dropdown_menu/1, %{})

    root = one(html, "div.dropdown-menu#account-menu")
    assert attr(root, "phx-hook") == "BasecoatState"

    trigger = one(root, "button#account-menu-trigger")
    assert attr(trigger, "aria-haspopup") == "menu"
    assert attr(trigger, "aria-controls") == "account-menu-menu"
    assert attr(trigger, "aria-expanded") == "false"
    assert classes(trigger) == ["btn"]
    assert attr(trigger, "data-variant") == "outline"

    popover = one(root, "div#account-menu-popover[data-popover]")
    assert attr(popover, "aria-hidden") == "true"
    assert classes(popover) == ["w-40"]

    menu = one(popover, "div[role=menu]#account-menu-menu")
    assert attr(menu, "aria-labelledby") == "account-menu-trigger"

    group = one(menu, "div[role=group]")
    assert attr(group, "aria-labelledby") == "account-menu-account"

    assert text(one(group, "div[role=heading]#account-menu-account")) |> String.trim() ==
             "My Account"

    item = one(group, "div[role=menuitem]")
    assert text(one(item, "span")) == "Profile"
    assert text(one(item, "kbd")) == "⇧⌘P"

    checkbox = one(group, "div[role=menuitemcheckbox]")
    assert attr(checkbox, "aria-checked") == "true"
    assert one(checkbox, "span[data-indicator]")

    radio = one(group, "div[role=menuitemradio]")
    assert attr(radio, "aria-checked") == "true"

    assert one(menu, "hr[role=separator]")
    assert attr(one(menu, "div[role=menuitem][aria-disabled=true]"), "aria-disabled") == "true"
  end

  test "bc_command renders the search header, menu, groups, and items" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.command/1, %{})

    root = one(html, "div.command#demo-command")
    assert attr(root, "aria-label") == "Command menu"

    input = one(root, "header > input")
    assert attr(input, "role") == "combobox"
    assert attr(input, "aria-autocomplete") == "list"
    assert attr(input, "aria-expanded") == "true"
    assert attr(input, "aria-controls") == "demo-command-menu"
    assert attr(input, "autocomplete") == "off"
    assert one(root, "header > svg.lucide-search")

    menu = one(root, "div[role=menu]#demo-command-menu")
    assert attr(menu, "aria-orientation") == "vertical"
    assert attr(menu, "data-empty") == "No results found."

    group = one(menu, "div[role=group]")
    assert attr(group, "aria-labelledby") == "demo-command-suggestions"

    assert text(one(group, "span[role=heading]#demo-command-suggestions")) |> String.trim() ==
             "Suggestions"

    item = one(group, "div[role=menuitem][data-filter=Calendar]")
    assert attr(item, "data-keywords") == "date event schedule"
    assert text(one(item, "span[data-shortcut]")) == "⌘K"

    disabled = one(group, "div[role=menuitem][aria-disabled=true]")
    assert text(disabled) |> String.trim() == "Calculator"

    assert one(menu, "hr[role=separator]")
  end

  test "bc_command_dialog wraps the command in a native dialog" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.command_dialog/1, %{})

    dialog = one(html, "dialog.command-dialog#command-palette")
    assert attr(dialog, "aria-label") == "Command menu"
    assert attr(dialog, "open")
    assert attr(dialog, "phx-hook") == "BasecoatState"

    assert one(dialog, "div.command")

    item = one(dialog, "div[role=menuitem]")
    assert attr(item, "data-force")
    assert attr(item, "data-keep-command-open")
  end

  test "bc_theme_switcher renders the toggle button and both icons" do
    html = render(&BasecoatPhoenix.Components.NavigationFixture.theme_switcher/1, %{})

    button = one(html, "button.btn.size-8")
    assert attr(button, "type") == "button"
    assert attr(button, "aria-label") == "Toggle dark mode"
    assert attr(button, "data-tooltip") == "Toggle dark mode"
    assert attr(button, "data-side") == "bottom"
    assert attr(button, "data-variant") == "outline"
    assert attr(button, "data-size") == "icon"
    assert attr(button, "data-basecoat-theme-toggle")

    assert classes(one(button, "span.hidden")) == ["hidden", "dark:block"]
    assert classes(one(button, "span.block")) == ["block", "dark:hidden"]
    assert one(button, "span.hidden svg.lucide-sun")
    assert one(button, "span.block svg.lucide-moon")
  end
end
