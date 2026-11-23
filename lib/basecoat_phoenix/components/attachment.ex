defmodule BasecoatPhoenix.Components.Attachment do
  @moduledoc """
  Basecoat attachment: a file or image card.

  The root is `<div>` by default; `as="li"` renders a list item. Children go in
  upstream order: media, content, optional full-card `<a>`/`<button>`, actions.
  No `attachment-*` classes.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:as, :string, default: "div")
  attr(:orientation, :string, default: nil)
  attr(:state, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_attachment(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@as}
      class={classes(["attachment", @class])}
      data-orientation={@orientation}
      data-state={@state}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_attachment_media(assigns) do
    ~H"""
    <figure {@rest}>{render_slot(@inner_block)}</figure>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_attachment_content(assigns) do
    ~H"""
    <section {@rest}>{render_slot(@inner_block)}</section>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_attachment_title(assigns) do
    ~H"""
    <p dir="auto" {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_attachment_description(assigns) do
    ~H"""
    <p {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_attachment_actions(assigns) do
    ~H"""
    <div {@rest}>{render_slot(@inner_block)}</div>
    """
  end
end
