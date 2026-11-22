defmodule BasecoatPhoenix.Components.Skeleton do
  @moduledoc """
  Basecoat skeleton placeholder. Sizing comes from utility classes.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def bc_skeleton(assigns) do
    ~H"""
    <div class={classes(["skeleton", @class])} {@rest}>{render_slot(@inner_block)}</div>
    """
  end
end
