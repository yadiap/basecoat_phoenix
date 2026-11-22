defmodule BasecoatPhoenix.Components.KbdTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Kbd

  test "bc_kbd matches the upstream markup" do
    assigns = %{inner_block: [%{inner_block: fn _, _ -> "Ctrl" end}]}
    assert_markup(&Kbd.bc_kbd/1, assigns, ~S(<kbd class="kbd">Ctrl</kbd>))
  end

  test "bc_kbd merges a utility class" do
    assigns = %{
      class: "translate-x-0.5",
      inner_block: [%{inner_block: fn _, _ -> "⏎" end}]
    }

    html = render(&Kbd.bc_kbd/1, assigns)
    assert classes(one(html, "kbd")) == ["kbd", "translate-x-0.5"]
  end
end
