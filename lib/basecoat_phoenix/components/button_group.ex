defmodule BasecoatPhoenix.Components.ButtonGroup do
  @moduledoc """
  Basecoat button group.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_button_group(assigns) do
    ~H"""
    <div
      role="group"
      aria-label={@label}
      class={classes(["button-group", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
