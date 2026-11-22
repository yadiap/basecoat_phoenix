defmodule BasecoatPhoenix.Installer.CSS do
  @moduledoc """
  Pure string surgery for `app.css`.

  Tailwind 4 config is not a regular language (nested `{ ... }` blocks), so the
  plugin removal scans brace depth instead of using a regex.
  """

  @doc """
  Removes the `@plugin "<name>" { ... }` block, including its brace body.

  Matches the full quoted name, so `daisyui` does not match `daisyui-theme`.
  Returns the input unchanged when the plugin is absent.
  """
  @spec remove_plugin_block(String.t(), String.t()) :: String.t()
  def remove_plugin_block(css, name) do
    needle = ~s(@plugin "#{name}")

    case :binary.match(css, needle) do
      :nomatch ->
        css

      {start, length} ->
        rest_start = start + length
        rest = binary_part(css, rest_start, byte_size(css) - rest_start)

        with {open, 1} <- :binary.match(rest, "{"),
             close when is_integer(close) <- closing_brace(rest, open, 0) do
          tail = binary_part(rest, close + 1, byte_size(rest) - close - 1)
          tail = String.replace_prefix(tail, "\n", "")
          binary_part(css, 0, start) <> tail
        else
          # No brace body, or unbalanced input: leave it alone rather than
          # corrupt the file.
          _ -> css
        end
    end
  end

  @doc """
  Inserts `line` after the first line whose trimmed text starts with `prefix`.

  Idempotent: returns the input unchanged when the line is already present.
  """
  @spec insert_after(String.t(), String.t(), String.t()) :: String.t()
  def insert_after(css, prefix, line) do
    lines = String.split(css, "\n")

    if Enum.any?(lines, &(String.trim_leading(&1) == line)) do
      css
    else
      case Enum.find_index(lines, &String.starts_with?(String.trim_leading(&1), prefix)) do
        nil -> css
        index -> lines |> List.insert_at(index + 1, line) |> Enum.join("\n")
      end
    end
  end

  # shortcut: braces inside quoted values would miscount, which no Tailwind
  # plugin config in the Phoenix template does; upgrade to a tokenizer if a
  # plugin config ever needs a brace in a string.
  defp closing_brace(binary, index, _depth) when index >= byte_size(binary), do: nil

  defp closing_brace(binary, index, depth) do
    case binary_part(binary, index, 1) do
      "{" ->
        closing_brace(binary, index + 1, depth + 1)

      "}" when depth == 1 ->
        index

      "}" ->
        closing_brace(binary, index + 1, depth - 1)

      _ ->
        closing_brace(binary, index + 1, depth)
    end
  end
end
