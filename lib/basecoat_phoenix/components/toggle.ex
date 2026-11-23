defmodule BasecoatPhoenix.Components.Toggle do
  @moduledoc """
  Basecoat toggle: a native checkbox or radio styled as a button.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]
  alias BasecoatPhoenix.Field

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:type, :string, default: "checkbox")
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:variant, :string, default: nil)
  attr(:size, :string, default: nil)
  attr(:field, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_toggle(assigns) do
    resolved = Field.resolve(assigns.field, id: assigns.id, name: assigns.name)

    assigns =
      assigns
      |> assign(:resolved, resolved)
      |> assign(:checked?, assigns.checked or truthy(assigns.field && assigns.field.value))

    ~H"""
    <label
      class={classes(["btn", @class])}
      data-variant={@variant}
      data-size={@size}
      {@rest}
    >
      <input
        type={@type}
        id={@resolved.id}
        name={@resolved.name}
        value={@value}
        checked={@checked?}
        disabled={@disabled}
      />
      {render_slot(@inner_block)}
    </label>
    """
  end

  defp truthy(nil), do: false
  defp truthy(false), do: false
  defp truthy(""), do: false
  defp truthy("false"), do: false
  defp truthy(_), do: true
end
