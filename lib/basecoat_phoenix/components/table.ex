defmodule BasecoatPhoenix.Components.Table do
  @moduledoc """
  Basecoat table. Wrap it in `bc_table_container` so wide tables scroll.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_container(assigns) do
    ~H"""
    <div class={classes(["table-container", @class])} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table(assigns) do
    ~H"""
    <table class={classes(["table", @class])} {@rest}>{render_slot(@inner_block)}</table>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_caption(assigns) do
    ~H"""
    <caption {@rest}>{render_slot(@inner_block)}</caption>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_header(assigns) do
    ~H"""
    <thead {@rest}>{render_slot(@inner_block)}</thead>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_body(assigns) do
    ~H"""
    <tbody {@rest}>{render_slot(@inner_block)}</tbody>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_footer(assigns) do
    ~H"""
    <tfoot {@rest}>{render_slot(@inner_block)}</tfoot>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_row(assigns) do
    ~H"""
    <tr {@rest}>{render_slot(@inner_block)}</tr>
    """
  end

  attr(:scope, :string, default: nil)
  attr(:colspan, :any, default: nil)
  attr(:rowspan, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_head(assigns) do
    ~H"""
    <th scope={@scope} colspan={@colspan} rowspan={@rowspan} {@rest}>
      {render_slot(@inner_block)}
    </th>
    """
  end

  attr(:colspan, :any, default: nil)
  attr(:rowspan, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_table_cell(assigns) do
    ~H"""
    <td colspan={@colspan} rowspan={@rowspan} {@rest}>{render_slot(@inner_block)}</td>
    """
  end
end
