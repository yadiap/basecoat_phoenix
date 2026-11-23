defmodule BasecoatPhoenix.Components.InputGroup do
  @moduledoc """
  Basecoat input group shell, addons, and action buttons.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:orientation, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_input_group(assigns) do
    ~H"""
    <div
      class={classes(["input-group", @class])}
      data-orientation={@orientation}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:align, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_input_group_addon(assigns) do
    ~H"""
    <span data-align={@align} {@rest}>{render_slot(@inner_block)}</span>
    """
  end

  attr(:as, :string, default: "button")
  attr(:type, :string, default: "button")
  attr(:label, :string, default: nil)
  attr(:align, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_input_group_button(assigns) do
    ~H"""
    <button
      :if={@as == "button"}
      type={@type}
      data-align={@align}
      aria-label={@label}
      {@rest}
    >{render_slot(@inner_block)}</button>
    <div
      :if={@as != "button"}
      role="group"
      data-align={@align}
      aria-label={@label}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
