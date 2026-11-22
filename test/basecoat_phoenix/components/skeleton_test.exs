defmodule BasecoatPhoenix.Components.SkeletonTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Skeleton

  test "bc_skeleton matches the upstream markup" do
    assert_markup(
      &Skeleton.bc_skeleton/1,
      %{class: "h-4 w-full"},
      ~S(<div class="skeleton h-4 w-full"></div>)
    )
  end
end
