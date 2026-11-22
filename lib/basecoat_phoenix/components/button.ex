defmodule BasecoatPhoenix.Components.Button do
  @moduledoc """
  Basecoat button. Renders `<button>` or, with `href`, `<a>`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:variant, :string, default: nil)
  attr(:size, :string, default: nil)
  attr(:type, :string, default: "button")
  attr(:href, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_button(assigns) do
    ~H"""
    <a
      :if={@href}
      href={@href}
      class={classes(["btn", @class])}
      data-variant={default(@variant, "primary")}
      data-size={default(@size, "default")}
      {@rest}
    >{render_slot(@inner_block)}</a>
    <button
      :if={!@href}
      type={@type}
      class={classes(["btn", @class])}
      data-variant={default(@variant, "primary")}
      data-size={default(@size, "default")}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  defp default(nil, _default), do: nil
  defp default(value, value), do: nil
  defp default(value, _default), do: value
end
