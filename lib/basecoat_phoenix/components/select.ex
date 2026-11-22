defmodule BasecoatPhoenix.Components.Select do
  @moduledoc """
  Basecoat select. Options are a flat list or one level of groups:

      options={[
        %{value: "apple", label: "Apple"},
        %{label: "Fruits", options: [%{value: "pear", label: "Pear"}]}
      ]}

  Values are stored in Basecoat's hidden input: a string for single select,
  JSON for multiple select, and JSON objects with `format: "object"`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  import BasecoatPhoenix.Forms
  alias BasecoatPhoenix.Field

  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:field, :any, default: nil)
  attr(:options, :list, required: true)
  attr(:value, :any, default: nil)
  attr(:multiple, :boolean, default: false)
  attr(:format, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_select(assigns) do
    resolved = Field.resolve(assigns.field, name: assigns.name, value: assigns.value)
    options = normalize_options(assigns.options)

    assigns =
      assigns
      |> assign(:options, options)
      |> assign(:input_name, resolved.name)
      |> assign(
        :selected_label,
        trigger_label(options, resolved.value, assigns.multiple, assigns.placeholder)
      )
      |> assign(
        :hidden_value,
        hidden_value(options, resolved.value, assigns.multiple, assigns.format)
      )

    ~H"""
    <div
      id={@id}
      class={classes(["select", @class])}
      data-placeholder={@placeholder}
      data-format={@format == "object" && "object"}
      phx-hook="BasecoatState"
      {@rest}
    >
      <button
        type="button"
        id={"#{@id}-trigger"}
        aria-haspopup="listbox"
        aria-expanded="false"
        aria-controls={"#{@id}-listbox"}
      >
        <span class="truncate">{@selected_label}</span>
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
          class="lucide lucide-chevron-down text-muted-foreground opacity-50 shrink-0"
        >
          <path d="m6 9 6 6 6-6" />
        </svg>
      </button>
      <div id={"#{@id}-popover"} data-popover aria-hidden="true">
        <div
          id={"#{@id}-listbox"}
          role="listbox"
          aria-orientation="vertical"
          aria-labelledby={"#{@id}-trigger"}
          aria-multiselectable={@multiple && "true"}
        >
          <%= for option <- @options do %>
            <%= if option.options do %>
              <div role="group" aria-labelledby={"#{@id}-#{slug(option.label)}"}>
                <span role="heading" id={"#{@id}-#{slug(option.label)}"}>{option.label}</span>
                <%= for child <- option.options do %>
                  <div
                    role="option"
                    data-value={child.value}
                    aria-disabled={child.disabled && "true"}
                  >
                    {child.label}
                  </div>
                <% end %>
              </div>
            <% else %>
              <div
                role="option"
                data-value={option.value}
                aria-disabled={option.disabled && "true"}
              >
                {option.label}
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
      <input type="hidden" name={@input_name} value={@hidden_value} />
    </div>
    """
  end

  defp normalize_options(nil), do: []

  defp normalize_options(options) when is_list(options),
    do: Enum.map(options, &normalize_option/1)

  defp normalize_option(option) when is_map(option) do
    children = Map.get(option, :options) || Map.get(option, "options")

    %{
      value: Map.get(option, :value) || Map.get(option, "value"),
      label: Map.get(option, :label) || Map.get(option, "label"),
      disabled: Map.get(option, :disabled) || Map.get(option, "disabled") || false,
      options: if(is_list(children), do: normalize_options(children))
    }
  end

  defp trigger_label(options, value, true, placeholder) do
    case List.wrap(value) do
      [] -> placeholder || ""
      values -> Enum.map_join(values, ", ", &detail_label(&1, options))
    end
  end

  defp trigger_label(_options, value, false, placeholder) when value in [nil, ""],
    do: placeholder || ""

  defp trigger_label(options, value, false, _placeholder), do: detail_label(value, options)

  defp detail_label(value, _options) when is_map(value) do
    Map.get(value, :label) || Map.get(value, "label") || scalar(value)
  end

  defp detail_label(value, options), do: option_label(options, value) || scalar(value)

  defp option_label([], _value), do: nil

  defp option_label([option | rest], value) do
    cond do
      option.options -> option_label(option.options, value) || option_label(rest, value)
      to_string(option.value) == to_string(value) -> option.label
      true -> option_label(rest, value)
    end
  end

  defp hidden_value(_options, nil, false, _format), do: ""

  defp hidden_value(options, value, true, format) do
    items =
      value
      |> List.wrap()
      |> Enum.map(fn item ->
        if format == "object", do: detail(item, options), else: scalar(item)
      end)

    encode_selection(items, format)
  end

  defp hidden_value(options, value, false, "object") do
    encode_selection(detail(value, options), "object")
  end

  defp hidden_value(_options, value, false, _format), do: scalar(value)

  defp detail(value, _options) when is_map(value) do
    %{
      "value" => scalar(value),
      "label" => Map.get(value, :label) || Map.get(value, "label") || scalar(value)
    }
  end

  defp detail(value, options) do
    %{"value" => scalar(value), "label" => option_label(options, value) || scalar(value)}
  end

  defp scalar(value) when is_map(value) do
    Map.get(value, :value) || Map.get(value, "value") || value
  end

  defp scalar(value), do: to_string(value)

  defp slug(label) do
    label
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
