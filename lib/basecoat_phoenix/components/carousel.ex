defmodule BasecoatPhoenix.Components.Carousel do
  @moduledoc """
  Basecoat carousel: a scrollable `<ul>` of snap-aligned slides with optional
  previous/next buttons.

  The buttons are direct children of `.carousel`, Previous before Next, and
  stay `hidden` until Basecoat's carousel script initializes them.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_carousel(assigns) do
    ~H"""
    <div
      id={@id}
      class={classes(["carousel", @class])}
      role="region"
      aria-roledescription="carousel"
      aria-label={@label}
      phx-hook="BasecoatState"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:label, :string, default: "Slides")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_carousel_content(assigns) do
    ~H"""
    <ul
      role="list"
      class={classes(["scrollbar", @class])}
      tabindex="0"
      aria-label={@label}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def bc_carousel_item(assigns) do
    ~H"""
    <li class={classes([@class])} {@rest}>{render_slot(@inner_block)}</li>
    """
  end

  attr(:label, :string, default: "Previous slide")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_carousel_previous(assigns) do
    ~H"""
    <button
      type="button"
      class={classes(["btn absolute inset-y-0 -start-12 my-auto", @class])}
      data-variant="outline"
      data-size="icon-sm"
      aria-label={@label}
      hidden
      {@rest}
    >
      <svg
        class="rtl:rotate-180"
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="m15 18-6-6 6-6" />
      </svg>
    </button>
    """
  end

  attr(:label, :string, default: "Next slide")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_carousel_next(assigns) do
    ~H"""
    <button
      type="button"
      class={classes(["btn absolute inset-y-0 -end-12 my-auto", @class])}
      data-variant="outline"
      data-size="icon-sm"
      aria-label={@label}
      hidden
      {@rest}
    >
      <svg
        class="rtl:rotate-180"
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="m9 18 6-6-6-6" />
      </svg>
    </button>
    """
  end
end
