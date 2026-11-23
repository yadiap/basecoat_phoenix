defmodule BasecoatPhoenix.Components.Pagination do
  @moduledoc """
  Basecoat pagination. Upstream documents no dedicated component: this renders
  the documented nav, list, button, and ellipsis markup. No `.pagination` class.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:label, :string, default: "pagination")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_pagination(assigns) do
    ~H"""
    <nav
      role="navigation"
      aria-label={@label}
      class={classes(["mx-auto flex w-full justify-center", @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </nav>
    """
  end

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_pagination_list(assigns) do
    ~H"""
    <ul class={classes(["flex flex-row items-center gap-1", @class])} {@rest}>
      {render_slot(@inner_block)}
    </ul>
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_pagination_item(assigns) do
    ~H"""
    <li {@rest}>{render_slot(@inner_block)}</li>
    """
  end

  attr(:href, :string, required: true)
  attr(:current, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_pagination_link(assigns) do
    ~H"""
    <a
      href={@href}
      class={classes(["btn", @class])}
      data-variant={(@current && "outline") || "ghost"}
      data-size="icon"
      {@rest}
    >{render_slot(@inner_block)}</a>
    """
  end

  attr(:href, :string, required: true)
  attr(:label, :string, default: "Previous")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_pagination_previous(assigns) do
    ~H"""
    <a href={@href} class={classes(["btn", @class])} data-variant="ghost" {@rest}>
      <svg
        class="lucide lucide-chevron-left"
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
        <path d="m15 18-6-6 6-6" />
      </svg>
      <span>{@label}</span>
    </a>
    """
  end

  attr(:href, :string, required: true)
  attr(:label, :string, default: "Next")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_pagination_next(assigns) do
    ~H"""
    <a href={@href} class={classes(["btn", @class])} data-variant="ghost" {@rest}>
      <span>{@label}</span>
      <svg
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
    </a>
    """
  end

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_pagination_ellipsis(assigns) do
    ~H"""
    <div class={classes(["size-9 flex items-center justify-center", @class])} {@rest}>
      <svg
        class="size-4 shrink-0 lucide lucide-ellipsis"
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
        <circle cx="12" cy="12" r="1" /><circle cx="19" cy="12" r="1" /><circle
          cx="5"
          cy="12"
          r="1"
        />
      </svg>
    </div>
    """
  end
end
