defmodule BasecoatPhoenix.Components.Item do
  @moduledoc """
  Basecoat item: a display row with media, content, actions, header, and footer.

  Renders `<article class="item">` or, with `href`, `<a class="item">`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:href, :string, default: nil)
  attr(:variant, :string, default: nil)
  attr(:size, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item(assigns) do
    ~H"""
    <a
      :if={@href}
      href={@href}
      class={classes(["item", @class])}
      data-variant={@variant}
      data-size={@size}
      {@rest}
    >{render_slot(@inner_block)}</a>
    <article
      :if={!@href}
      class={classes(["item", @class])}
      data-variant={@variant}
      data-size={@size}
      {@rest}
    >
      {render_slot(@inner_block)}
    </article>
    """
  end

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_group(assigns) do
    ~H"""
    <div role="list" class={classes(["item-group", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_media(assigns) do
    ~H"""
    <figure {@rest}>{render_slot(@inner_block)}</figure>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_content(assigns) do
    ~H"""
    <section {@rest}>{render_slot(@inner_block)}</section>
    """
  end

  attr(:as, :string, default: "h3")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_title(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest}>{render_slot(@inner_block)}</.dynamic_tag>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_description(assigns) do
    ~H"""
    <p {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_actions(assigns) do
    ~H"""
    <aside {@rest}>{render_slot(@inner_block)}</aside>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_header(assigns) do
    ~H"""
    <header {@rest}>{render_slot(@inner_block)}</header>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_item_footer(assigns) do
    ~H"""
    <footer {@rest}>{render_slot(@inner_block)}</footer>
    """
  end
end
