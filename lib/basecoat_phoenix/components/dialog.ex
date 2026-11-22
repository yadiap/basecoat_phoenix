defmodule BasecoatPhoenix.Components.Dialog do
  @moduledoc """
  Basecoat dialog built on the native `<dialog>` element.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:footer)

  def bc_dialog(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={classes(["dialog", @class])}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={@description && "#{@id}-description"}
      open={@open}
      phx-hook="BasecoatState"
      {@rest}
    >
      <div>
        <header>
          <h2 id={"#{@id}-title"}>{@title}</h2>
          <p :if={@description} id={"#{@id}-description"}>{@description}</p>
        </header>
        <section :if={@inner_block != []}>
          {render_slot(@inner_block)}
        </section>
        <footer :if={@footer != []}>
          {render_slot(@footer)}
        </footer>
        <button
          type="button"
          class="btn"
          data-variant="ghost"
          data-size="icon-sm"
          aria-label="Close dialog"
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
            class="lucide lucide-x-icon lucide-x"
          >
            <path d="M18 6 6 18" /><path d="m6 6 12 12" />
          </svg>
        </button>
      </div>
    </dialog>
    """
  end

  attr(:dialog, :string, required: true)
  attr(:variant, :string, default: "outline")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dialog_trigger(assigns) do
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
