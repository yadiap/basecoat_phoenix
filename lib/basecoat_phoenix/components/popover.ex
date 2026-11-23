defmodule BasecoatPhoenix.Components.Popover do
  @moduledoc """
  Basecoat popover: an inline-positioned panel relative to a `.popover`
  wrapper. Ids follow the upstream `ID-trigger` and `ID-popover` pattern.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_popover(assigns) do
    ~H"""
    <div id={@id} class={classes(["popover", @class])} phx-hook="BasecoatState" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:variant, :string, default: "outline")
  attr(:size, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_popover_trigger(assigns) do
    ~H"""
    <button
      type="button"
      id={"#{@id}-trigger"}
      aria-expanded="false"
      aria-controls={"#{@id}-popover"}
      class={classes(["btn", @class])}
      data-variant={@variant}
      data-size={@size}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  attr(:id, :string, required: true)
  attr(:side, :string, default: nil)
  attr(:align, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_popover_content(assigns) do
    ~H"""
    <div
      id={"#{@id}-popover"}
      data-popover
      data-side={@side}
      data-align={@align}
      aria-hidden="true"
      class={classes([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
