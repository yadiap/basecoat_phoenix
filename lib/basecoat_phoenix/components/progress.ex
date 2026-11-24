defmodule BasecoatPhoenix.Components.Progress do
  @moduledoc """
  Basecoat progress bar.

  Pass `label` to render the upstream labeled layout: a header row with the
  label and the current percentage, then the bar. Without it the bar renders
  alone and `label` is not used. Use `labelledby` when an element elsewhere on
  the page names the bar.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:value, :any, required: true)
  attr(:max, :any, default: 100)
  attr(:min, :any, default: 0)
  attr(:label, :string, default: nil, doc: "visible label and accessible name")
  attr(:labelledby, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_progress(%{label: label} = assigns) when is_binary(label) and label != "" do
    assigns = assign(assigns, :percent, percent(assigns.value, assigns.max))

    ~H"""
    <div class="field">
      <div class="flex items-center gap-3 text-sm">
        <span>{@label}</span>
        <output class="ms-auto tabular-nums">{@percent}%</output>
      </div>
      <.progress_bar
        value={@value}
        max={@max}
        min={@min}
        label={@label}
        labelledby={@labelledby}
        percent={@percent}
        class={@class}
        {@rest}
      />
    </div>
    """
  end

  def bc_progress(assigns) do
    assigns = assign(assigns, :percent, percent(assigns.value, assigns.max))

    ~H"""
    <.progress_bar
      value={@value}
      max={@max}
      min={@min}
      label={@label}
      labelledby={@labelledby}
      percent={@percent}
      class={@class}
      {@rest}
    />
    """
  end

  attr(:value, :any, required: true)
  attr(:max, :any, required: true)
  attr(:min, :any, required: true)
  attr(:label, :string, default: nil)
  attr(:labelledby, :string, default: nil)
  attr(:percent, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  defp progress_bar(assigns) do
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
