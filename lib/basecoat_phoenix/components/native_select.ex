defmodule BasecoatPhoenix.Components.NativeSelect do
  @moduledoc """
  Native `<select>` with Basecoat styling.

  Pass `options` (`%{value:, label:, disabled:, selected:}`), or use the
  `inner_block` slot for custom `<option>` children.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]
  alias BasecoatPhoenix.Field

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:field, :any, default: nil)
  attr(:options, :list, default: [])
  attr(:multiple, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def bc_native_select(assigns) do
    resolved =
      Field.resolve(assigns.field, id: assigns.id, name: assigns.name, value: assigns.value)

    assigns = assign(assigns, :resolved, resolved)

    ~H"""
    <select
      class={classes(["select", @class])}
      id={@resolved.id}
      name={@resolved.name}
      multiple={@multiple}
      {@rest}
    >
      <%= if @inner_block != [] do %>
        {render_slot(@inner_block)}
      <% else %>
        <option
          :for={option <- @options}
          value={option_value(option)}
          disabled={option_flag(option, :disabled)}
          selected={
            option_flag(option, :selected) or selected?(option_value(option), @resolved.value)
          }
        >
          {option_label(option)}
        </option>
      <% end %>
    </select>
    """
  end

  defp option_value(option) when is_map(option),
    do: Map.get(option, :value) || Map.get(option, "value")

  defp option_value(option), do: option

  defp option_label(option) when is_map(option),
    do: Map.get(option, :label) || Map.get(option, "label") || option_value(option)

  defp option_label(option), do: option

  defp option_flag(option, key) when is_map(option),
    do: Map.get(option, key) || Map.get(option, to_string(key)) || false

  defp option_flag(_option, _key), do: false

  defp selected?(value, resolved_value) when not is_nil(resolved_value),
    do: to_string(value) == to_string(resolved_value)

  defp selected?(_value, _resolved_value), do: false
end
