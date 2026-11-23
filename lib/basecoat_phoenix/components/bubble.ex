defmodule BasecoatPhoenix.Components.Bubble do
  @moduledoc """
  Basecoat bubble. The default slot is the content; the optional `:reactions`
  slot renders a direct `<div role="img">` after it. No `bubble-content` class.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:variant, :string, default: nil)
  attr(:align, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :reactions do
    attr(:label, :string)
    attr(:side, :string)
    attr(:align, :string)
  end

  slot(:inner_block, required: true)

  def bc_bubble(assigns) do
    ~H"""
    <div class={classes(["bubble", @class])} data-variant={@variant} data-align={@align} {@rest}>
      {render_slot(@inner_block)}
      <div
        :for={reaction <- @reactions}
        role="img"
        aria-label={reaction[:label]}
        data-side={reaction[:side]}
        data-align={reaction[:align]}
      >
        {render_slot(reaction)}
      </div>
    </div>
    """
  end

  attr(:as, :string, default: "div")
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_bubble_group(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@as}
      class={classes(["bubble-group", @class])}
      role={@as in ["ol", "ul"] && "list"}
      aria-label={@label}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end
end
