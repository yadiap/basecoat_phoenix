defmodule BasecoatPhoenix.Components.AlertDialog do
  @moduledoc """
  Basecoat alert dialog: a native `<dialog class="alert-dialog">` that
  interrupts with a title, an optional description, and explicit actions.

  There is no close button and no backdrop close: the user must choose an
  action, as upstream requires.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:size, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:figure)
  slot(:footer)

  def bc_alert_dialog(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={classes(["alert-dialog", @class])}
      data-size={@size}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={@description && "#{@id}-description"}
      open={@open}
      phx-hook="BasecoatState"
      {@rest}
    >
      <div>
        <header>
          <figure :if={@figure != []}>{render_slot(@figure)}</figure>
          <h2 id={"#{@id}-title"}>{@title}</h2>
          <p :if={@description} id={"#{@id}-description"}>{@description}</p>
        </header>
        <footer :if={@footer != []}>{render_slot(@footer)}</footer>
      </div>
    </dialog>
    """
  end

  attr(:dialog, :string, required: true)
  attr(:variant, :string, default: "outline")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_alert_dialog_trigger(assigns) do
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
