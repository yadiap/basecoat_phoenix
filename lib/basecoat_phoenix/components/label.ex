defmodule BasecoatPhoenix.Components.Label do
  @moduledoc """
  Basecoat label.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:for, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_label(assigns) do
    ~H"""
    <label for={@for} class={classes(["label", @class])} {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end
end
