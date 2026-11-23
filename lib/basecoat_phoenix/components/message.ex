defmodule BasecoatPhoenix.Components.Message do
  @moduledoc """
  Basecoat message: one conversation turn. The caller composes the avatar,
  sender, and bubble inside the default slot. No `message-content` class.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:as, :string, default: "li")
  attr(:align, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_message(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@as}
      class={classes(["message", @class])}
      data-align={@align}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_message_group(assigns) do
    ~H"""
    <ol role="list" class={classes(["message-group", @class])} aria-label={@label} {@rest}>
      {render_slot(@inner_block)}
    </ol>
    """
  end
end
