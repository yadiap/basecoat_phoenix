defmodule BasecoatPhoenix.Components.Slider do
  @moduledoc """
  Basecoat slider: a native range input.

  Basecoat's range controller listens to `input` events only and has no
  registry refresh, so a server-side value change would leave the filled track
  stale. The component renders `--slider-value` itself, computed the way
  Basecoat computes it, and `BasecoatState` preserves the client-written style
  across patches.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  alias BasecoatPhoenix.Field

  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:field, :any, default: nil)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:step, :any, default: nil)
  attr(:value, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_slider(assigns) do
    resolved =
      Field.resolve(assigns.field, id: assigns.id, name: assigns.name, value: assigns.value)

    value = resolved.value || midpoint(assigns.min, assigns.max)

    assigns =
      assigns
      |> assign(:resolved, resolved)
      |> assign(:value, number(value))
      |> assign(:percent, percent(value, assigns.min, assigns.max))

    ~H"""
    <input
      type="range"
      class={classes(["input", @class])}
      id={@resolved.id}
      name={@resolved.name}
      min={@min}
      max={@max}
      step={@step}
      value={@value}
      style={"--slider-value: #{@percent}%"}
      phx-hook="BasecoatState"
      {@rest}
    />
    """
  end

  defp midpoint(min, max), do: (to_number(min) + to_number(max)) / 2

  # Mirrors Basecoat's `updateRange`: a zero-width range renders 0%.
  defp percent(value, min, max) do
    min = to_number(min)
    max = to_number(max)
    percent = if max == min, do: 0, else: (to_number(value) - min) / (max - min) * 100

    number(percent)
  end

  defp number(value) when is_integer(value), do: Integer.to_string(value)

  defp number(value) do
    rounded = Float.round(to_number(value) * 1.0, 4)

    if rounded == trunc(rounded) do
      Integer.to_string(trunc(rounded))
    else
      :erlang.float_to_binary(rounded, [:compact, decimals: 4])
    end
  end

  defp to_number(value) when is_number(value), do: value
  defp to_number(value) when is_binary(value), do: String.to_float(value)
end
