defmodule BasecoatPhoenix.Components.Alert do
  @moduledoc """
  Basecoat alert. The icon is a direct child SVG; title, description, and
  actions map to `h2`, `section`, and `footer`. No `alert-*` classes.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:variant, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon)
  slot(:inner_block, required: true)

  def bc_alert(assigns) do
    ~H"""
    <div class={classes(["alert", @class])} data-variant={@variant} {@rest}>
      {render_slot(@icon)}
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:as, :string, default: "h2")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_alert_title(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest}>{render_slot(@inner_block)}</.dynamic_tag>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_alert_description(assigns) do
    ~H"""
    <section {@rest}>{render_slot(@inner_block)}</section>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_alert_actions(assigns) do
    ~H"""
    <footer {@rest}>{render_slot(@inner_block)}</footer>
    """
  end
end
