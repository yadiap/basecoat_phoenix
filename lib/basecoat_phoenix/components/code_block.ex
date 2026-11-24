defmodule BasecoatPhoenix.Components.CodeBlock do
  @moduledoc """
  Basecoat code block. The code body is a plain `<pre class="scrollbar">` you
  pass in, so syntax highlighting, wrapping, and `data-line-numbers` stay
  caller-owned. `size` sets the root `data-size`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:size, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_code_block(assigns) do
    ~H"""
    <div class={classes(["code-block", @class])} data-size={@size} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_code_block_header(assigns) do
    ~H"""
    <header {@rest}>{render_slot(@inner_block)}</header>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_code_block_title(assigns) do
    ~H"""
    <span {@rest}>{render_slot(@inner_block)}</span>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_code_block_actions(assigns) do
    ~H"""
    <div {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_code_block_copy(assigns) do
    ~H"""
    <button
      type="button"
      class={classes(["btn", @class])}
      data-variant="ghost"
      data-size="xs"
      data-copy
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
