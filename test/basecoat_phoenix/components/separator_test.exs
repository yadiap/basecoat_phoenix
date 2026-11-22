defmodule BasecoatPhoenix.Components.SeparatorTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Separator

  test "bc_separator renders the native separator" do
    assert_markup(&Separator.bc_separator/1, %{}, ~S(<hr role="separator" />))
  end

  test "bc_separator renders a decorative separator" do
    assert_markup(
      &Separator.bc_separator/1,
      %{decorative: true},
      ~S(<hr role="none" />)
    )
  end

  test "bc_separator supports a vertical orientation" do
    html = render(&Separator.bc_separator/1, %{orientation: "vertical"})
    assert attr(one(html, "hr"), "aria-orientation") == "vertical"
  end
end
