defmodule BasecoatPhoenix.Components.Drawer do
  @moduledoc """
  Basecoat drawer: a native `<dialog class="drawer">` with an `<article>`
  surface. `side` picks the viewport edge; leave it unset for the default
  bottom drawer.

  Basecoat's drawer script owns the backdrop close and the exit animation.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  @sides ~w(top right bottom left)

  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:side, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:footer)
  slot(:inner_block)

  def bc_drawer(assigns) do
    unless assigns.side in [nil | @sides] do
      raise ArgumentError, "unknown drawer side: #{inspect(assigns.side)}"
    end

    ~H"""
    <dialog
      id={@id}
      class={classes(["drawer", @class])}
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
      </article>
    </dialog>
    """
  end

  attr(:dialog, :string, required: true)
  attr(:variant, :string, default: "outline")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_drawer_trigger(assigns) do
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
