defmodule BasecoatPhoenix.Components.Sidebar do
  @moduledoc """
  Basecoat sidebar: a native `<aside>` whose state Basecoat owns.

  `bc_sidebar_trigger` calls `toggle()` on the sidebar it names, through
  `basecoat_live.js`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  @sides ~w(left right)

  attr(:id, :string, required: true)
  attr(:side, :string, default: "left")
  attr(:initial_open, :string, default: nil)
  attr(:initial_mobile_open, :string, default: nil)
  attr(:breakpoint, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar(assigns) do
    unless assigns.side in @sides do
      raise ArgumentError,
            "bc_sidebar expects side to be one of #{Enum.join(@sides, ", ")}, got: #{inspect(assigns.side)}"
    end

    ~H"""
    <aside
      id={@id}
      class={classes(["sidebar", @class])}
      data-side={@side}
      data-initial-open={@initial_open}
      data-initial-mobile-open={@initial_mobile_open}
      data-breakpoint={@breakpoint}
      phx-hook="BasecoatState"
      {@rest}
    >
      {render_slot(@inner_block)}
    </aside>
    """
  end

  attr(:label, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_nav(assigns) do
    ~H"""
    <nav aria-label={@label} {@rest}>{render_slot(@inner_block)}</nav>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_header(assigns) do
    ~H"""
    <header {@rest}>{render_slot(@inner_block)}</header>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_content(assigns) do
    ~H"""
    <section {@rest}>{render_slot(@inner_block)}</section>
    """
  end

  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:as, :string, default: "h3")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_group(assigns) do
    ~H"""
    <div role="group" aria-labelledby={@id} {@rest}>
      <.dynamic_tag tag_name={@as} id={@id}>{@label}</.dynamic_tag>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_menu(assigns) do
    ~H"""
    <ul {@rest}>{render_slot(@inner_block)}</ul>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_menu_item(assigns) do
    ~H"""
    <li {@rest}>{render_slot(@inner_block)}</li>
    """
  end

  attr(:href, :string, default: nil)
  attr(:variant, :string, default: nil)
  attr(:size, :string, default: nil)
  attr(:active, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_menu_button(assigns) do
    ~H"""
    <a
      :if={@href}
      href={@href}
      class={@class}
      data-variant={@variant}
      data-size={@size}
      data-active={@active && "true"}
      aria-disabled={@disabled && "true"}
      {@rest}
    >{render_slot(@inner_block)}</a>
    <button
      :if={!@href}
      type="button"
      class={@class}
      data-variant={@variant}
      data-size={@size}
      data-active={@active && "true"}
      disabled={@disabled}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:open, :boolean, default: false)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_menu_sub(assigns) do
    ~H"""
    <details id={@id} open={@open} {@rest}>
      <summary aria-controls={"#{@id}-content"}>{@label}</summary>
      <ul id={"#{@id}-content"}>{render_slot(@inner_block)}</ul>
    </details>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_footer(assigns) do
    ~H"""
    <footer {@rest}>{render_slot(@inner_block)}</footer>
    """
  end

  attr(:sidebar, :string, required: true)
  attr(:variant, :string, default: "outline")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sidebar_trigger(assigns) do
    ~H"""
    <button
      type="button"
      class={classes(["btn", @class])}
      data-variant={@variant}
      data-basecoat-sidebar-toggle={@sidebar}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end
end
