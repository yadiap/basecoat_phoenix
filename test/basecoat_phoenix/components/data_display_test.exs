defmodule BasecoatPhoenix.Components.DataDisplayFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Table
  import BasecoatPhoenix.Components.CodeBlock
  import BasecoatPhoenix.Components.Chart

  def table(assigns) do
    ~H"""
    <.bc_table_container>
      <.bc_table>
        <.bc_table_caption>A list of your recent invoices.</.bc_table_caption>
        <.bc_table_header>
          <.bc_table_row>
            <.bc_table_head>Invoice</.bc_table_head>
            <.bc_table_head>Status</.bc_table_head>
          </.bc_table_row>
        </.bc_table_header>
        <.bc_table_body>
          <.bc_table_row>
            <.bc_table_cell class="font-medium">INV001</.bc_table_cell>
            <.bc_table_cell>Paid</.bc_table_cell>
          </.bc_table_row>
        </.bc_table_body>
        <.bc_table_footer>
          <.bc_table_row>
            <.bc_table_cell colspan="1">Total</.bc_table_cell>
            <.bc_table_cell class="text-end">$250.00</.bc_table_cell>
          </.bc_table_row>
        </.bc_table_footer>
      </.bc_table>
    </.bc_table_container>
    """
  end

  def code_block(assigns) do
    ~H"""
    <.bc_code_block size="sm">
      <.bc_code_block_header>
        <.bc_code_block_title>Terminal</.bc_code_block_title>
        <.bc_code_block_actions>
          <.bc_code_block_copy>Copy</.bc_code_block_copy>
        </.bc_code_block_actions>
      </.bc_code_block_header>
      <pre class="scrollbar" tabindex="0" aria-label="Terminal output" data-line-numbers><code>npm run build</code></pre>
    </.bc_code_block>
    """
  end

  def code_block_no_copy(assigns) do
    ~H"""
    <.bc_code_block>
      <pre class="scrollbar" tabindex="0"><code>plain</code></pre>
    </.bc_code_block>
    """
  end

  def chart(assigns) do
    ~H"""
    <.bc_chart
      id="visitors-chart"
      aria-label="Monthly visitors"
      type="bar"
      label_key="month"
      legend
      data={[
        %{month: "Jan", desktop: 186, mobile: 80},
        %{month: "Feb", desktop: 305, mobile: 200}
      ]}
      series={%{desktop: %{label: "Desktop", color: "var(--chart-1)"}}}
    />
    """
  end

  def charts(assigns) do
    ~H"""
    <.bc_bar_chart id="bar" data={rows()} series={%{value: %{label: "Value"}}} />
    <.bc_line_chart id="line" data={rows()} series={%{value: %{label: "Value"}}} />
    <.bc_pie_chart id="pie" data={rows()} series={%{value: %{label: "Value"}}} />
    <.bc_doughnut_chart id="doughnut" data={rows()} series={%{value: %{label: "Value"}}} />
    <.bc_polar_area_chart id="polar" data={rows()} series={%{value: %{label: "Value"}}} />
    <.bc_radar_chart id="radar" data={rows()} series={%{value: %{label: "Value"}}} />
    <.bc_scatter_chart
      id="scatter"
      aria-label="Samples"
      chart_data={%{datasets: [%{label: "Samples", data: [%{x: 1, y: 2}]}]}}
      options={%{scales: %{x: %{type: "linear"}}}}
    />
    <.bc_bubble_chart id="bubble" chart_data={%{datasets: [%{label: "Deals", data: []}]}} />
    """
  end

  defp rows do
    [%{label: "A", value: 1}, %{label: "B", value: 2}]
  end
end

defmodule BasecoatPhoenix.Components.DataDisplayTest do
  use BasecoatPhoenix.ComponentCase

  test "bc_table renders the container and full table structure" do
    html = render(&BasecoatPhoenix.Components.DataDisplayFixture.table/1, %{})

    container = one(html, "div.table-container")
    assert container

    table = one(container, "table.table")
    assert table
    assert text(one(table, "caption")) == "A list of your recent invoices."
    assert length(Floki.find(table, "thead > tr > th")) == 2
    assert length(Floki.find(table, "tbody > tr > td")) == 2
    assert attr(one(table, "tbody td"), "class") == "font-medium"
    assert text(one(table, "tfoot td")) == "Total"
  end

  test "bc_table_cell passes colspan through" do
    html = render(&BasecoatPhoenix.Components.DataDisplayFixture.table/1, %{})

    cell = one(html, "tfoot td")
    assert attr(cell, "colspan") == "1"
  end

  test "bc_code_block renders the header, actions, and copy button" do
    html = render(&BasecoatPhoenix.Components.DataDisplayFixture.code_block/1, %{})

    root = one(html, "div.code-block")
    assert attr(root, "data-size") == "sm"

    assert text(one(root, "header > span")) == "Terminal"

    button = one(root, "header > div > button.btn")
    assert attr(button, "data-variant") == "ghost"
    assert attr(button, "data-size") == "xs"
    assert attr(button, "data-copy")
    assert text(button) |> String.trim() == "Copy"

    pre = one(root, "pre.scrollbar")
    assert attr(pre, "tabindex") == "0"
    assert attr(pre, "data-line-numbers")
    assert text(one(pre, "code")) == "npm run build"
  end

  test "bc_code_block omits the copy button and size by default" do
    html = render(&BasecoatPhoenix.Components.DataDisplayFixture.code_block_no_copy/1, %{})

    root = one(html, "div.code-block")
    refute attr(root, "data-size")
    refute one(root, "button")
    refute attr(one(root, "pre"), "data-line-numbers")
  end

  test "bc_chart renders a bare canvas with JSON attributes and the chart hook" do
    html = render(&BasecoatPhoenix.Components.DataDisplayFixture.chart/1, %{})

    canvas = one(html, "canvas#visitors-chart")
    assert canvas
    assert attr(canvas, "aria-label") == "Monthly visitors"
    assert attr(canvas, "class") == nil
    assert attr(canvas, "phx-hook") == "BasecoatChart"
    assert attr(canvas, "data-chart-type") == "bar"
    assert attr(canvas, "data-chart-label-key") == "month"
    assert attr(canvas, "data-chart-legend") == "true"

    data = canvas |> attr("data-chart-data") |> Jason.decode!()

    assert data == [
             %{"month" => "Jan", "desktop" => 186, "mobile" => 80},
             %{"month" => "Feb", "desktop" => 305, "mobile" => 200}
           ]

    series = canvas |> attr("data-chart-series") |> Jason.decode!()
    assert series == %{"desktop" => %{"label" => "Desktop", "color" => "var(--chart-1)"}}
  end

  test "each chart type has a wrapper that sets only the type" do
    html = render(&BasecoatPhoenix.Components.DataDisplayFixture.charts/1, %{})

    for {id, type} <- [
          bar: "bar",
          line: "line",
          pie: "pie",
          doughnut: "doughnut",
          polar: "polarArea",
          radar: "radar",
          scatter: "scatter",
          bubble: "bubble"
        ] do
      canvas = one(html, "canvas##{id}")
      assert canvas, "missing wrapper canvas ##{id}"
      assert attr(canvas, "data-chart-type") == type
      assert attr(canvas, "phx-hook") == "BasecoatChart"
    end

    scatter = one(html, "canvas#scatter")
    assert attr(scatter, "aria-label") == "Samples"

    assert scatter |> attr("data-chart-options") |> Jason.decode!() ==
             %{"scales" => %{"x" => %{"type" => "linear"}}}

    assert scatter |> attr("data-chart-chart-data") |> Jason.decode!() ==
             %{"datasets" => [%{"label" => "Samples", "data" => [%{"x" => 1, "y" => 2}]}]}
  end
end
