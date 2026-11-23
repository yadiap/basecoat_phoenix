defmodule BasecoatPhoenix.Components.Marker do
  @moduledoc """
  Basecoat marker: an inline note, status, or labeled separator.

  An optional `:icon` slot renders a decorative SVG before the text. `shimmer`
  animates the text while a status is pending.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:variant, :string, default: nil)
  attr(:shimmer, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon)
  slot(:inner_block, required: true)

  def bc_marker(assigns) do
    ~H"""
    <div class={classes(["marker", @class])} data-variant={@variant} {@rest}>
      {render_slot(@icon)}
      <span class={@shimmer && "shimmer"}>{render_slot(@inner_block)}</span>
    </div>
    """
  end
end
