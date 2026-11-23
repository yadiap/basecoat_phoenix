defmodule BasecoatPhoenix.Components.Empty do
  @moduledoc """
  Basecoat empty state.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_empty(assigns) do
    ~H"""
    <section class={classes(["empty", @class])} {@rest}>{render_slot(@inner_block)}</section>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_empty_header(assigns) do
    ~H"""
    <header {@rest}>{render_slot(@inner_block)}</header>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_empty_media(assigns) do
    ~H"""
    <figure {@rest}>{render_slot(@inner_block)}</figure>
    """
  end

  attr(:as, :string, default: "h3")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_empty_title(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest}>{render_slot(@inner_block)}</.dynamic_tag>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_empty_description(assigns) do
    ~H"""
    <p {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_empty_content(assigns) do
    ~H"""
    <section {@rest}>{render_slot(@inner_block)}</section>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_empty_footer(assigns) do
    ~H"""
    <footer {@rest}>{render_slot(@inner_block)}</footer>
    """
  end
end
