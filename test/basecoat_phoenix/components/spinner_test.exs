defmodule BasecoatPhoenix.Components.SpinnerTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Spinner

  @markup ~S"""
  <svg aria-label="Loading" role="status" class="animate-spin lucide lucide-loader-circle" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M21 12a9 9 0 1 1-6.219-8.56" />
  </svg>
  """

  test "bc_spinner renders the upstream loader SVG" do
    assert_markup(&Spinner.bc_spinner/1, %{}, @markup)
  end

  test "bc_spinner merges size utilities" do
    html = render(&Spinner.bc_spinner/1, %{class: "size-3"})
    assert classes(one(html, "svg")) |> Enum.member?("size-3")
  end

  test "bc_spinner renders the label as visible text" do
    html = render(&Spinner.bc_spinner/1, %{label: "Saving"})

    root = one(html, "span[role=status]")
    assert root
    assert one(root, "span") |> text() == "Saving"

    svg = one(root, "svg")
    assert attr(svg, "aria-hidden") == "true"
    refute attr(svg, "aria-label")
  end

  test "bc_spinner keeps the label alongside a size class" do
    html = render(&Spinner.bc_spinner/1, %{label: "Saving", class: "size-4"})

    svg = one(html, "svg")
    assert classes(svg) |> Enum.member?("size-4")
    assert one(html, "span[role=status] > span") |> text() == "Saving"
  end
end
