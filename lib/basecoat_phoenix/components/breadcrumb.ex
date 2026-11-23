defmodule BasecoatPhoenix.Components.Breadcrumb do
  @moduledoc """
  Basecoat breadcrumb: a navigation landmark around an ordered list.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:label, :string, default: "Breadcrumb")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_breadcrumb(assigns) do
    ~H"""
    <nav class={classes(["breadcrumb", @class])} aria-label={@label} {@rest}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_breadcrumb_list(assigns) do
    ~H"""
    <ol {@rest}>{render_slot(@inner_block)}</ol>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_breadcrumb_item(assigns) do
    ~H"""
    <li {@rest}>{render_slot(@inner_block)}</li>
    """
  end

  attr(:href, :string, required: true)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_breadcrumb_link(assigns) do
    ~H"""
    <a href={@href} {@rest}>{render_slot(@inner_block)}</a>
    """
  end

  attr(:href, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_breadcrumb_page(assigns) do
    ~H"""
    <a :if={@href} href={@href} aria-current="page" {@rest}>{render_slot(@inner_block)}</a>
    <span :if={!@href} aria-current="page" {@rest}>{render_slot(@inner_block)}</span>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)

  def bc_breadcrumb_separator(assigns) do
    ~H"""
    <li aria-hidden="true" {@rest}>
      {render_slot(@inner_block)}
      <svg
        :if={@inner_block == []}
        data-rtl-flip
        class="lucide lucide-chevron-right"
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <path d="m9 18 6-6-6-6" />
      </svg>
    </li>
    """
  end

  attr(:rest, :global)

  def bc_breadcrumb_ellipsis(assigns) do
    ~H"""
    <li {@rest}><span aria-hidden="true">…</span></li>
    """
  end
end
