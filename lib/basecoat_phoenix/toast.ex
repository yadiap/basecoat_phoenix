defmodule BasecoatPhoenix.Toast do
  @moduledoc """
  Server-side helper for pushing Basecoat toasts.
  """

  @doc """
  Pushes a `basecoat_toast` event to the client.

  `basecoat_live.js` listens for `phx:basecoat_toast` on `window` and hands the
  payload to the single `#toaster` in the root layout.
  """
  @spec push(Phoenix.LiveView.Socket.t(), keyword() | map()) :: Phoenix.LiveView.Socket.t()
  def push(socket, opts), do: Phoenix.LiveView.push_event(socket, "basecoat_toast", payload(opts))

  @doc """
  Builds Basecoat's camelCase toast payload from snake_case options.

  `:action` and `:cancel` keep `:label` and `:href`; any `:onclick` is dropped so
  the output stays CSP-safe.
  """
  def payload(opts) do
    opts = Map.new(opts)

    %{
      "title" => opts[:title],
      "description" => opts[:description],
      "category" => stringify(opts[:category]),
      "duration" => opts[:duration],
      "closeButton" => opts[:close_button]
    }
    |> reject_nil()
    |> put_present("action", action(opts[:action]))
    |> put_present("cancel", action(opts[:cancel]))
  end

  defp reject_nil(map), do: map |> Enum.reject(fn {_key, value} -> is_nil(value) end) |> Map.new()

  defp action(nil), do: nil

  defp action(action) do
    action = Map.new(action)

    %{"label" => action[:label], "href" => action[:href]}
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp put_present(map, _key, nil), do: map
  defp put_present(map, key, value), do: Map.put(map, key, value)

  defp stringify(nil), do: nil
  defp stringify(value) when is_atom(value), do: Atom.to_string(value)
  defp stringify(value), do: value
end
