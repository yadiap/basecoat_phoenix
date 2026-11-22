defmodule BasecoatPhoenix.Components.ProgressTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Progress

  test "bc_progress matches the upstream markup" do
    assert_markup(
      &Progress.bc_progress/1,
      %{value: 13, label: "Loading"},
      ~S"""
      <div class="progress" role="progressbar" aria-label="Loading" aria-valuenow="13" aria-valuemin="0" aria-valuemax="100">
        <span style="width: 13%"></span>
      </div>
      """
    )
  end

  test "bc_progress computes, clamps, and rounds the width" do
    assert attr(one(render(&Progress.bc_progress/1, %{value: 50, max: 200}), "span"), "style") ==
             "width: 25%"

    assert attr(one(render(&Progress.bc_progress/1, %{value: 300}), "span"), "style") ==
             "width: 100%"

    assert attr(one(render(&Progress.bc_progress/1, %{value: 1, max: 3}), "span"), "style") ==
             "width: 33.3%"
  end

  test "bc_progress supports aria-labelledby" do
    html = render(&Progress.bc_progress/1, %{value: 10, labelledby: "job-label"})

    root = one(html, "div.progress")
    assert attr(root, "aria-labelledby") == "job-label"
    refute attr(root, "aria-label")
  end
end
