defmodule BasecoatPhoenix.Components.ProgressTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Progress

  test "bc_progress renders the bare upstream bar without a label" do
    assert_markup(
      &Progress.bc_progress/1,
      %{value: 13},
      ~S"""
      <div class="progress" role="progressbar" aria-valuenow="13" aria-valuemin="0" aria-valuemax="100">
        <span style="width: 13%"></span>
      </div>
      """
    )
  end

  test "bc_progress renders the upstream labeled layout" do
    html = render(&Progress.bc_progress/1, %{value: 66, label: "Upload progress"})

    field = one(html, "div.field")
    assert field

    assert one(field, "div.flex > span") |> text() == "Upload progress"
    assert one(field, "output") |> text() == "66%"

    bar = one(field, "div.progress")
    assert attr(bar, "role") == "progressbar"
    assert attr(bar, "aria-label") == "Upload progress"
    assert attr(bar, "aria-valuenow") == "66"
    assert attr(one(bar, "span"), "style") == "width: 66%"
  end

  test "bc_progress computes, clamps, and rounds the width" do
    assert attr(one(render(&Progress.bc_progress/1, %{value: 50, max: 200}), "span"), "style") ==
             "width: 25%"

    assert attr(one(render(&Progress.bc_progress/1, %{value: 300}), "span"), "style") ==
             "width: 100%"

    assert attr(one(render(&Progress.bc_progress/1, %{value: 1, max: 3}), "span"), "style") ==
             "width: 33.3%"
  end

  test "bc_progress shows the rounded percentage next to the label" do
    html = render(&Progress.bc_progress/1, %{value: 1, max: 3, label: "Steps"})

    assert one(html, "output") |> text() == "33.3%"
  end

  test "bc_progress supports aria-labelledby" do
    html = render(&Progress.bc_progress/1, %{value: 10, labelledby: "job-label"})

    root = one(html, "div.progress")
    assert attr(root, "aria-labelledby") == "job-label"
    refute attr(root, "aria-label")
  end
end
