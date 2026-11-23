defmodule BasecoatPhoenix.Components.Sheet do
  @moduledoc """
  Basecoat sheet: a native `<dialog class="sheet">` panel pinned to a viewport
  edge. Defaults to the right side; it reuses Basecoat's drawer script.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  @sides ~w(top right bottom left)

  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:side, :string, default: "right")
  attr(:close_button, :boolean, default: true)
  attr(:open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:footer)
  slot(:inner_block)

  def bc_sheet(assigns) do
    unless assigns.side in @sides do
      raise ArgumentError, "unknown sheet side: #{inspect(assigns.side)}"
    end

    ~H"""
    <dialog
      id={@id}
      class={classes(["sheet", @class])}
      data-side={@side}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={@description && "#{@id}-description"}
      open={@open}
      phx-hook="BasecoatState"
      {@rest}
    >
      <article>
        <header>
          <h2 id={"#{@id}-title"}>{@title}</h2>
          <p :if={@description} id={"#{@id}-description"}>{@description}</p>
        </header>
        <section :if={@inner_block != []}>{render_slot(@inner_block)}</section>
        <footer :if={@footer != []}>{render_slot(@footer)}</footer>
        <button
          :if={@close_button}
          type="button"
          class="btn"
          data-variant="ghost"
          data-size="icon-sm"
          aria-label="Close sheet"
          data-basecoat-dialog-close
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="size-4"
            aria-hidden="true"
          >
            <path d="M18 6 6 18" /><path d="m6 6 12 12" />
          </svg>
        </button>
      </article>
    </dialog>
    """
  end

  attr(:dialog, :string, required: true)
  attr(:variant, :string, default: "outline")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_sheet_trigger(assigns) do
    ~H"""
    <button
      type="button"
      class={classes(["btn", @class])}
      data-variant={@variant}
      data-basecoat-dialog-open={@dialog}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end
end
