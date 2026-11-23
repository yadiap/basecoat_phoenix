defmodule BasecoatPhoenix.Components.Chart do
  @moduledoc """
  Basecoat chart. Renders a bare `<canvas>` with the `BasecoatChart` hook;
  Basecoat's chart script reads the `data-chart-*` attributes and draws.

  Chart.js must be loaded by the host app. `data` and `series` are
  JSON-encoded into `data-chart-data` and `data-chart-series`.
  """
  use Phoenix.Component

  attr(:id, :string, required: true)
  attr(:type, :string, default: nil)
  attr(:label_key, :string, default: nil)
  attr(:legend, :boolean, default: nil)
  attr(:tooltip, :boolean, default: nil)
  attr(:data, :any, default: nil)
  attr(:series, :any, default: nil)
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
      {@rest}
    />
    """
  end

  # Basecoat reads these as strings; an explicit "true"/"false" is unambiguous.
  defp boolean(nil), do: nil
  defp boolean(true), do: "true"
  defp boolean(false), do: "false"
end
