defmodule BasecoatPhoenix.Components.Badge do
  @moduledoc """
  Basecoat badge. Omit the variant for the primary style.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:variant, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_badge(assigns) do
    ~H"""
    <span class={classes(["badge", @class])} data-variant={variant(@variant)} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp variant(nil), do: nil
  defp variant("primary"), do: nil
  defp variant(value), do: value
end
