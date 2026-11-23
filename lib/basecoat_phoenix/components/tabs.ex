defmodule BasecoatPhoenix.Components.Tabs do
  @moduledoc """
  Basecoat tabs. Upstream markup is a flat tablist plus sibling panels, so the
  caller composes `bc_tab_list`, one `bc_tab` per tab, and one `bc_tab_panel`
  per panel. `selected` and `hidden` are caller-owned; Basecoat's script keeps
  them in sync in the browser.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_tabs(assigns) do
    ~H"""
    <div id={@id} class={classes(["tabs", @class])} phx-hook="BasecoatState" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:orientation, :string, default: "horizontal")
  attr(:variant, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_tab_list(assigns) do
    ~H"""
    <nav
      role="tablist"
      aria-orientation={@orientation}
      data-variant={@variant}
      class={classes([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </nav>
    """
  end

  attr(:id, :string, required: true)
  attr(:panel, :string, required: true)
  attr(:selected, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_tab(assigns) do
    ~H"""
    <button
      type="button"
      role="tab"
      id={@id}
      aria-controls={@panel}
      aria-selected={to_string(@selected)}
      tabindex={(@selected && "0") || "-1"}
      class={classes([@class])}
      disabled={@disabled}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  attr(:id, :string, required: true)
  attr(:labelledby, :string, required: true)
  attr(:hidden, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_tab_panel(assigns) do
    ~H"""
    <div
      role="tabpanel"
      id={@id}
      aria-labelledby={@labelledby}
      tabindex="-1"
      hidden={@hidden}
      class={classes([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
