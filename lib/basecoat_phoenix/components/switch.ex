defmodule BasecoatPhoenix.Components.Switch do
  @moduledoc """
  Basecoat switch: a native checkbox with `role="switch"`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]
  alias BasecoatPhoenix.Field

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:field, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_switch(assigns) do
    resolved = Field.resolve(assigns.field, id: assigns.id, name: assigns.name)

    assigns =
      assigns
      |> assign(:resolved, resolved)
      |> assign(:checked?, assigns.checked or truthy(assigns.field && assigns.field.value))

    ~H"""
    <div
      role="group"
      class={classes(["field", @class])}
      data-orientation="horizontal"
      {@rest}
    >
      <input
        type="checkbox"
        role="switch"
        id={@resolved.id}
        name={@resolved.name}
        value={@value}
        class="input"
        checked={@checked?}
        disabled={@disabled}
        aria-invalid={@resolved.invalid? && "true"}
        aria-describedby={@resolved.describedby}
      />
      <label for={@resolved.id}>{render_slot(@inner_block)}</label>
    </div>
    """
  end

  defp truthy(nil), do: false
  defp truthy(false), do: false
  defp truthy(""), do: false
  defp truthy("false"), do: false
  defp truthy(_), do: true
end
