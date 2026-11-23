defmodule BasecoatPhoenix.Components.Toast do
  @moduledoc """
  Basecoat toast and its `#toaster` container.

  `bc_toaster` renders the single fixed container. Basecoat's toast script
  initializes any `.toast` appended to it, including server-rendered ones, so
  the container uses `phx-update="ignore"` and no hook.

  `bc_toast` renders one toast. Use it for server-rendered notifications; for
  client-side ones use `BasecoatPhoenix.Toast.push/2`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  @doc """
  The single toaster container. Fixed `id="toaster"`; `basecoat_live.js` looks
  the element up by that id.
  """
  attr(:align, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def bc_toaster(assigns) do
    ~H"""
    <ol
      id="toaster"
      class={classes(["toaster", @class])}
      data-align={@align}
      role="list"
      aria-label="Notifications"
      phx-update="ignore"
      {@rest}
    >
      {render_slot(@inner_block)}
    </ol>
    """
  end

  attr(:category, :string, default: nil)
  attr(:duration, :any, default: nil)
  attr(:title, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:close_button, :boolean, default: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon)
  slot(:footer)
  slot(:inner_block)

  def bc_toast(assigns) do
    ~H"""
    <li
      class={classes(["toast", @class])}
      data-category={@category}
      data-duration={@duration}
      {@rest}
    >
      <div
        class="toast-content"
        role={(@category == "error" && "alert") || "status"}
        aria-atomic="true"
      >
        {render_slot(@icon)}
        <section :if={@title || @description || @inner_block != []}>
          <h2 :if={@title}>{@title}</h2>
          <p :if={@description}>{@description}</p>
          {render_slot(@inner_block)}
        </section>
        <footer :if={@footer != [] or @close_button}>
          {render_slot(@footer)}
          <button
            :if={@close_button}
            type="button"
            class="btn"
            data-variant="ghost"
            data-size="icon-sm"
            aria-label="Close toast"
          >
            <svg
              aria-hidden="true"
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
              <path d="M18 6 6 18" /><path d="m6 6 12 12" />
            </svg>
          </button>
        </footer>
      </div>
    </li>
    """
  end
end
