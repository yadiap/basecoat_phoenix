defmodule BasecoatPhoenix.Components.LayoutFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Item
  import BasecoatPhoenix.Components.Empty
  import BasecoatPhoenix.Components.Collapsible
  import BasecoatPhoenix.Components.Accordion
  import BasecoatPhoenix.Components.Sidebar

  def item(assigns) do
    ~H"""
    <.bc_item variant="outline">
      <.bc_item_media>Icon</.bc_item_media>
      <.bc_item_content>
        <.bc_item_title>Basic Item</.bc_item_title>
        <.bc_item_description>A simple item with title and description.</.bc_item_description>
      </.bc_item_content>
      <.bc_item_actions>Action</.bc_item_actions>
    </.bc_item>
    """
  end

  def item_link(assigns) do
    ~H"""
    <.bc_item href="#" size="sm">
      <.bc_item_content>
        <.bc_item_title>Verified</.bc_item_title>
      </.bc_item_content>
    </.bc_item>
    """
  end

  def item_regions(assigns) do
    ~H"""
    <.bc_item>
      <.bc_item_header>Header</.bc_item_header>
      <.bc_item_footer>Footer</.bc_item_footer>
    </.bc_item>
    """
  end

  def item_group(assigns) do
    ~H"""
    <.bc_item_group>
      <.bc_item>Body</.bc_item>
    </.bc_item_group>
    """
  end

  def empty(assigns) do
    ~H"""
    <.bc_empty>
      <.bc_empty_header>
        <.bc_empty_media>Icon</.bc_empty_media>
        <.bc_empty_title>No Projects Yet</.bc_empty_title>
        <.bc_empty_description>You have not created any projects yet.</.bc_empty_description>
      </.bc_empty_header>
      <.bc_empty_footer>Actions</.bc_empty_footer>
    </.bc_empty>
    """
  end

  def collapsible(assigns) do
    ~H"""
    <.bc_collapsible>
      <.bc_collapsible_trigger>Shipping options</.bc_collapsible_trigger>
      <.bc_collapsible_content>
        <p>Orders ship within two business days.</p>
      </.bc_collapsible_content>
    </.bc_collapsible>
    """
  end

  def accordion(assigns) do
    ~H"""
    <.bc_accordion>
      <.bc_accordion_item open>
        <.bc_accordion_trigger>Is it accessible?</.bc_accordion_trigger>
        <.bc_accordion_content>Yes. It uses native disclosure semantics.</.bc_accordion_content>
      </.bc_accordion_item>
      <.bc_accordion_item>
        <.bc_accordion_trigger>Can I close it?</.bc_accordion_trigger>
        <.bc_accordion_content>Yes.</.bc_accordion_content>
      </.bc_accordion_item>
    </.bc_accordion>
    """
  end

  def sidebar(assigns) do
    ~H"""
    <.bc_sidebar id="sidebar" side="left" breakpoint="1024">
      <.bc_sidebar_nav label="Sidebar navigation">
        <.bc_sidebar_header>Brand</.bc_sidebar_header>
        <.bc_sidebar_content>
          <.bc_sidebar_group id="group-label-content-1" label="Getting started">
            <.bc_sidebar_menu>
              <.bc_sidebar_menu_item>
                <.bc_sidebar_menu_button href="#">Playground</.bc_sidebar_menu_button>
              </.bc_sidebar_menu_item>
            </.bc_sidebar_menu>
          </.bc_sidebar_group>
        </.bc_sidebar_content>
        <.bc_sidebar_footer>Account</.bc_sidebar_footer>
      </.bc_sidebar_nav>
    </.bc_sidebar>
    """
  end

  def sidebar_submenu(assigns) do
    ~H"""
    <.bc_sidebar_menu_item>
      <.bc_sidebar_menu_sub id="submenu-1" label="Settings">
        <.bc_sidebar_menu_item>
          <.bc_sidebar_menu_button href="#">General</.bc_sidebar_menu_button>
        </.bc_sidebar_menu_item>
      </.bc_sidebar_menu_sub>
    </.bc_sidebar_menu_item>
    """
  end
end

defmodule BasecoatPhoenix.Components.LayoutTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Sidebar

  test "bc_item matches the upstream markup" do
    assert_markup(&BasecoatPhoenix.Components.LayoutFixture.item/1, %{}, ~S"""
    <article class="item" data-variant="outline">
      <figure>Icon</figure>
      <section>
        <h3>Basic Item</h3>
        <p>A simple item with title and description.</p>
      </section>
      <aside>Action</aside>
    </article>
    """)
  end

  test "bc_item renders an anchor when href is present" do
    html = render(&BasecoatPhoenix.Components.LayoutFixture.item_link/1, %{})

    link = one(html, "a.item")
    assert attr(link, "href") == "#"
    assert attr(link, "data-size") == "sm"
    refute one(html, "article")
  end

  test "bc_item_group renders the upstream list container" do
    assert_markup(
      &BasecoatPhoenix.Components.LayoutFixture.item_group/1,
      %{},
      ~S(<div role="list" class="item-group"><article class="item">Body</article></div>)
    )
  end

  test "bc_item_header and bc_item_footer render the full-width regions" do
    html = render(&BasecoatPhoenix.Components.LayoutFixture.item_regions/1, %{})

    root = one(html, "article.item")
    assert text(one(root, "header")) == "Header"
    assert text(one(root, "footer")) == "Footer"
  end

  test "bc_empty matches the upstream markup" do
    assert_markup(&BasecoatPhoenix.Components.LayoutFixture.empty/1, %{}, ~S"""
    <section class="empty">
      <header>
        <figure>Icon</figure>
        <h3>No Projects Yet</h3>
        <p>You have not created any projects yet.</p>
      </header>
      <footer>Actions</footer>
    </section>
    """)
  end

  test "bc_empty_content renders a section" do
    html =
      render(&BasecoatPhoenix.Components.Empty.bc_empty_content/1, %{
        inner_block: [%{inner_block: fn _, _ -> "Actions" end}]
      })

    assert text(one(html, "section")) == "Actions"
  end

  test "bc_collapsible matches the upstream markup" do
    assert_markup(&BasecoatPhoenix.Components.LayoutFixture.collapsible/1, %{}, ~S"""
    <details>
      <summary>Shipping options</summary>
      <p>Orders ship within two business days.</p>
    </details>
    """)
  end

  test "bc_collapsible renders the native open attribute" do
    html =
      render(&BasecoatPhoenix.Components.Collapsible.bc_collapsible/1, %{
        open: true,
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })

    assert attr(one(html, "details"), "open")
  end

  test "bc_accordion matches the upstream markup" do
    assert_markup(&BasecoatPhoenix.Components.LayoutFixture.accordion/1, %{}, ~S"""
    <section class="accordion">
      <details open>
        <summary>
          Is it accessible?
          <svg class="lucide lucide-chevron-down" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6" /></svg>
        </summary>
        <section>Yes. It uses native disclosure semantics.</section>
      </details>
      <details>
        <summary>
          Can I close it?
          <svg class="lucide lucide-chevron-down" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6" /></svg>
        </summary>
        <section>Yes.</section>
      </details>
    </section>
    """)
  end

  test "bc_accordion passes data-multiple through" do
    html =
      render(&BasecoatPhoenix.Components.Accordion.bc_accordion/1, %{
        multiple: true,
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })

    assert attr(one(html, "section.accordion"), "data-multiple")
  end

  test "bc_accordion_item marks a disabled item" do
    html =
      render(&BasecoatPhoenix.Components.Accordion.bc_accordion_item/1, %{
        disabled: true,
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })

    assert attr(one(html, "details"), "aria-disabled") == "true"
  end

  test "bc_sidebar matches the upstream markup" do
    html = render(&BasecoatPhoenix.Components.LayoutFixture.sidebar/1, %{})

    root = one(html, "aside#sidebar.sidebar")
    assert attr(root, "data-side") == "left"
    assert attr(root, "data-breakpoint") == "1024"
    assert attr(root, "phx-hook") == "BasecoatState"

    nav = one(root, "nav")
    assert attr(nav, "aria-label") == "Sidebar navigation"
    assert one(nav, "header")
    assert one(nav, "section")
    assert one(nav, "footer")

    group = one(nav, "div[role=group]")
    assert attr(group, "aria-labelledby") == "group-label-content-1"
    assert text(one(group, "h3#group-label-content-1")) == "Getting started"

    assert attr(one(group, "ul > li > a"), "href") == "#"
  end

  test "bc_sidebar passes the initial state attributes through" do
    html =
      render(&Sidebar.bc_sidebar/1, %{
        id: "sidebar",
        side: "right",
        initial_open: "false",
        initial_mobile_open: "true",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })

    root = one(html, "aside.sidebar")
    assert attr(root, "data-side") == "right"
    assert attr(root, "data-initial-open") == "false"
    assert attr(root, "data-initial-mobile-open") == "true"
  end

  test "bc_sidebar rejects an unknown side" do
    assert_raise ArgumentError, ~r/side/, fn ->
      render(&Sidebar.bc_sidebar/1, %{
        id: "sidebar",
        side: "top",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })
    end
  end

  test "bc_sidebar_menu_sub renders a native details submenu" do
    html = render(&BasecoatPhoenix.Components.LayoutFixture.sidebar_submenu/1, %{})

    details = one(html, "details")
    assert attr(details, "id") == "submenu-1"

    summary = one(details, "summary")
    assert attr(summary, "aria-controls") == "submenu-1-content"

    assert attr(one(details, "ul#submenu-1-content"), "id") == "submenu-1-content"
  end

  test "bc_sidebar_trigger targets a sidebar by id" do
    html =
      render(&Sidebar.bc_sidebar_trigger/1, %{
        sidebar: "sidebar",
        inner_block: [%{inner_block: fn _, _ -> "Menu" end}]
      })

    button = one(html, "button.btn")
    assert attr(button, "type") == "button"
    assert attr(button, "data-variant") == "outline"
    assert attr(button, "data-basecoat-sidebar-toggle") == "sidebar"
    assert text(button) == "Menu"
  end
end
