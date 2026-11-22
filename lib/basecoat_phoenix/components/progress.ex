defmodule BasecoatPhoenix.Components.Progress do
  @moduledoc """
  Basecoat progress bar.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:value, :any, required: true)
  attr(:max, :any, default: 100)
  attr(:min, :any, default: 0)
  attr(:label, :string, default: nil)
  attr(:labelledby, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_progress(assigns) do
    assigns = assign(assigns, :percent, percent(assigns.value, assigns.max))

    ~H"""
    <div
      class={classes(["progress", @class])}
      role="progressbar"
      aria-label={@label}
      aria-labelledby={@labelledby}
      aria-valuenow={@value}
      aria-valuemin={@min}
      aria-valuemax={@max}
      {@rest}
    >
      <span style={"width: #{@percent}%"}></span>
    </div>
    """
  end

  defp percent(_value, max) when max in [nil, 0], do: "0"

  defp percent(value, max) do
    rounded =
      (value / max * 100)
      |> max(0.0)
      |> min(100.0)
      |> Float.round(1)

    if rounded == trunc(rounded) do
      Integer.to_string(trunc(rounded))
    else
      :erlang.float_to_binary(rounded, decimals: 1)
    end
  end
end
