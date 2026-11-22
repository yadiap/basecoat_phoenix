defmodule BasecoatPhoenix.Forms do
  @moduledoc """
  Encodes and decodes Basecoat's hidden-input selection format.

  Basecoat stores multiple selections as a JSON array and object-format
  selections as JSON objects. Single selections stay plain strings.
  """

  @doc """
  Encodes a selection value for a hidden input.

  `format` documents intent at the call site; the encoding follows the Elixir
  value shape, so both formats use the same rules.
  """
  @spec encode_selection(term(), String.t()) :: String.t()
  def encode_selection(nil, _format), do: ""
  def encode_selection(value, _format) when is_binary(value), do: value

  def encode_selection(value, _format) when is_list(value) or is_map(value) do
    Jason.encode!(value)
  end

  def encode_selection(value, _format), do: to_string(value)

  @doc """
  Decodes a submitted multiple selection into a list.

  Returns `[]` for empty, malformed, or non-collection input.
  """
  @spec decode_multi(term()) :: [String.t()] | [map()]
  def decode_multi(nil), do: []
  def decode_multi(""), do: []

  def decode_multi(value) when is_binary(value) do
    case Jason.decode(value) do
      {:ok, list} when is_list(list) -> list
      {:ok, map} when is_map(map) -> [map]
      _ -> []
    end
  end

  def decode_multi(_), do: []
end
