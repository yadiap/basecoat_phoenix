defmodule BasecoatPhoenix.Components.Accordion do
  @moduledoc """
  Basecoat accordion: native `<details>` items with Basecoat's single-open
  behavior. Add `multiple` to allow several open items.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:multiple, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_accordion(assigns) do
    ~H"""
    <section
      class={classes(["accordion", @class])}
      data-multiple={@multiple}
      {@rest}
    >
      {render_slot(@inner_block)}
    </section>
    """
  end

  attr(:open, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_accordion_item(assigns) do
    ~H"""
    <details open={@open} aria-disabled={@disabled && "true"} {@rest}>
      {render_slot(@inner_block)}
    </details>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_accordion_trigger(assigns) do
    ~H"""
    <summary {@rest}>
      {render_slot(@inner_block)}
      <svg
        class="lucide lucide-chevron-down"
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
        <path d="m6 9 6 6 6-6" />
      </svg>
    </summary>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_accordion_content(assigns) do
    ~H"""
    <section {@rest}>{render_slot(@inner_block)}</section>
    """
  end
end
