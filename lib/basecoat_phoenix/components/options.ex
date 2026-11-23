defmodule BasecoatPhoenix.Components.Options do
  @moduledoc false
  # Shared option handling for Select and Combobox: Basecoat stores the selection
  # in a hidden input and reads `data-value`/`data-label` off the option nodes.

  alias BasecoatPhoenix.Forms

  def normalize(nil), do: []
  def normalize(options) when is_list(options), do: Enum.map(options, &normalize_option/1)

  defp normalize_option(option) when is_map(option) do
    children = Map.get(option, :options) || Map.get(option, "options")

    %{
      value: Map.get(option, :value) || Map.get(option, "value"),
      label: Map.get(option, :label) || Map.get(option, "label"),
      disabled: Map.get(option, :disabled) || Map.get(option, "disabled") || false,
      filter: Map.get(option, :filter) || Map.get(option, "filter"),
      options: if(is_list(children), do: normalize(children))
    }
  end

  @doc "Label for a value, either the placeholder or the joined selection labels."
  def selection_label(options, value, multiple, placeholder)

  def selection_label(options, value, true, placeholder) do
    case List.wrap(value) do
      [] -> placeholder || ""
      values -> Enum.map_join(values, ", ", &value_label(&1, options))
    end
  end

  def selection_label(_options, value, false, placeholder) when value in [nil, ""],
    do: placeholder || ""

  def selection_label(options, value, false, _placeholder), do: value_label(value, options)

  @doc "Label for a single value: an explicit map label, the option label, or the value."
  def value_label(value, _options) when is_map(value) do
    Map.get(value, :label) || Map.get(value, "label") || scalar(value)
  end

  def value_label(value, options), do: option_label(options, value) || scalar(value)

  def option_label([], _value), do: nil

  def option_label([option | rest], value) do
    cond do
      option.options -> option_label(option.options, value) || option_label(rest, value)
      to_string(option.value) == to_string(value) -> option.label
      true -> option_label(rest, value)
    end
  end

  @doc "Value for the hidden input, encoded the way Basecoat decodes it."
  def hidden_value(options, value, multiple, format)

  def hidden_value(_options, nil, false, _format), do: ""

  def hidden_value(options, value, true, format) do
    items =
      value
      |> List.wrap()
      |> Enum.map(fn item ->
        if format == "object", do: detail(item, options), else: scalar(item)
      end)

    Forms.encode_selection(items, format)
  end

  def hidden_value(options, value, false, "object") do
    Forms.encode_selection(detail(value, options), "object")
  end

  def hidden_value(_options, value, false, _format), do: scalar(value)

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

  @doc "Slug used for group heading ids."
  def slug(label) do
    label
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
