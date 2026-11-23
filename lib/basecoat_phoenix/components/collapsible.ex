defmodule BasecoatPhoenix.Components.Collapsible do
  @moduledoc """
  Basecoat collapsible: a native `<details>` disclosure.
  """
  use Phoenix.Component

  attr(:open, :boolean, default: false)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_collapsible(assigns) do
    ~H"""
    <details open={@open} {@rest}>{render_slot(@inner_block)}</details>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_collapsible_trigger(assigns) do
    ~H"""
    <summary {@rest}>{render_slot(@inner_block)}</summary>
    """
  end

  # Upstream has no wrapper element around disclosure content.
  slot(:inner_block, required: true)

  def bc_collapsible_content(assigns) do
    ~H"""
    {render_slot(@inner_block)}
    """
  end
end
