defmodule BasecoatPhoenix.Components.Avatar do
  @moduledoc """
  Basecoat avatar, its image, fallback, badge, and group.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic

  attr(:size, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_avatar(assigns) do
    ~H"""
    <span
      class={classes(["avatar", @class])}
      data-size={@size}
      {@rest}
    >{render_slot(@inner_block)}</span>
    """
  end

  attr(:src, :string, required: true)
  attr(:alt, :string, default: nil)
  attr(:rest, :global)

  def bc_avatar_image(assigns) do
    ~H"""
    <img src={@src} alt={@alt} {@rest} />
    """
  end

  defsemantic(:bc_avatar_fallback, :span)

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def bc_avatar_badge(assigns) do
    ~H"""
    <span class={classes(["avatar-badge", @class])} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defsemantic(:bc_avatar_group, :div, class: "avatar-group")
end
