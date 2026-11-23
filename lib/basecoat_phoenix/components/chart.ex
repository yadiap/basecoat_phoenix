defmodule BasecoatPhoenix.Components.Chart do
  @moduledoc """
  Basecoat chart. Renders a bare `<canvas>` with the `BasecoatChart` hook;
  Basecoat's chart script reads the `data-chart-*` attributes and draws.

  Chart.js must be loaded by the host app. `data`, `series`, `options`, and
  `chart_data` are JSON-encoded into their `data-chart-*` attributes.

  `type` is any Chart.js type: `bar`, `line`, `pie`, `doughnut`, `polarArea`,
  `radar`, `scatter`, `bubble`. A line with `surface` is an area chart, and a
  `series` entry with `type` mixes chart types.

  Use `chart_data` for a complete Chart.js data object, which `scatter` and
  `bubble` need, and `options` for raw Chart.js options such as `indexAxis`.
  Both override the row mapper the same way they do in `basecoat.chart/2`.
  """
  use Phoenix.Component

  attr(:id, :string, required: true)
  attr(:type, :string, default: nil)
  attr(:label_key, :string, default: nil)
  attr(:legend, :boolean, default: nil)
  attr(:tooltip, :boolean, default: nil)
  attr(:data, :any, default: nil)
  attr(:series, :any, default: nil)
  attr(:options, :map, default: nil, doc: "raw Chart.js options")
  attr(:chart_data, :map, default: nil, doc: "complete Chart.js data object")
  attr(:rest, :global)

  def bc_chart(assigns) do
    ~H"""
    <canvas
      id={@id}
      phx-hook="BasecoatChart"
      data-chart-type={@type}
      data-chart-label-key={@label_key}
      data-chart-legend={boolean(@legend)}
      data-chart-tooltip={boolean(@tooltip)}
      data-chart-data={@data && Jason.encode!(@data)}
      data-chart-series={@series && Jason.encode!(@series)}
      data-chart-options={@options && Jason.encode!(@options)}
      data-chart-chart-data={@chart_data && Jason.encode!(@chart_data)}
      {@rest}
    />
    """
  end

  # One wrapper per Chart.js type, so a call site can say what it draws without
  # repeating the type string. They forward every chart attribute unchanged.
  @type_components [
    bar: "bar",
    line: "line",
    pie: "pie",
    doughnut: "doughnut",
    polar_area: "polarArea",
    radar: "radar",
    scatter: "scatter",
    bubble: "bubble"
  ]

  for {name, type} <- @type_components do
    @doc """
    Renders a `#{type}` chart. Same attributes as `bc_chart/1` without `type`.
    """
    attr(:id, :string, required: true)
    attr(:label_key, :string, default: nil)
    attr(:legend, :boolean, default: nil)
    attr(:tooltip, :boolean, default: nil)
    attr(:data, :any, default: nil)
    attr(:series, :any, default: nil)
    attr(:options, :map, default: nil, doc: "raw Chart.js options")
    attr(:chart_data, :map, default: nil, doc: "complete Chart.js data object")
    attr(:rest, :global)

    def unquote(:"bc_#{name}_chart")(assigns) do
      assigns |> Map.put(:type, unquote(type)) |> bc_chart()
    end
  end

  # Basecoat reads these as strings; an explicit "true"/"false" is unambiguous.
  defp boolean(nil), do: nil
  defp boolean(true), do: "true"
  defp boolean(false), do: "false"
end
