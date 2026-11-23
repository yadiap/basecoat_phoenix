defmodule BasecoatPhoenix.Components.ToggleGroup do
  @moduledoc """
  Basecoat toggle group.

  Pass `options` for the common case (`single: true` renders radios, otherwise
  checkboxes). Use the `inner_block` slot with `bc_toggle_group_item` when the
  items need custom content.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:legend, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:options, :list, default: [])
  attr(:value, :any, default: nil)
  attr(:single, :boolean, default: false)
  attr(:variant, :string, default: "outline")
  attr(:size, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def bc_toggle_group(assigns) do
    ~H"""
    <fieldset {@rest}>
      <legend class="sr-only">{@legend}</legend>
      <div class="flex gap-2">
        <%= if @options != [] do %>
          <label
            :for={option <- @options}
            class="btn"
            data-variant={@variant}
            data-size={@size}
          >
            <input
              type={if @single, do: "radio", else: "checkbox"}
              name={@name}
              value={option_value(option)}
              checked={selected?(option_value(option), @value, @single)}
              disabled={option_flag(option, :disabled)}
              aria-label={option_flag(option, :aria_label) || nil}
            />
            {option_label(option)}
          </label>
        <% else %>
          {render_slot(@inner_block)}
        <% end %>
      </div>
    </fieldset>
    """
  end

  attr(:name, :string, required: true)
  attr(:value, :string, required: true)
  attr(:type, :string, default: "checkbox")
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:variant, :string, default: "outline")
  attr(:size, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_toggle_group_item(assigns) do
    ~H"""
    <label
      class={classes(["btn", @class])}
      data-variant={@variant}
      data-size={@size}
      {@rest}
    >
      <input
        type={@type}
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
      />
      {render_slot(@inner_block)}
    </label>
    """
  end

  defp selected?(value, values, false) when is_list(values),
    do: Enum.any?(values, &(to_string(&1) == to_string(value)))

  defp selected?(value, value, _single) when not is_nil(value), do: true
  defp selected?(_value, _values, _single), do: false

  defp option_value(option) when is_map(option),
    do: Map.get(option, :value) || Map.get(option, "value")

  defp option_value(option), do: option

  defp option_label(option) when is_map(option),
    do: Map.get(option, :label) || Map.get(option, "label") || option_value(option)

  defp option_label(option), do: option

  defp option_flag(option, key) when is_map(option),
    do: Map.get(option, key) || Map.get(option, to_string(key)) || false

  defp option_flag(_option, _key), do: false
end
