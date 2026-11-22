defmodule BasecoatPhoenix.Components.ButtonGroupTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.ButtonGroup

  test "bc_button_group matches the upstream markup" do
    assigns = %{
      label: "Message actions",
      inner_block: [%{inner_block: fn _, _ -> "Actions" end}]
    }

    assert_markup(
      &ButtonGroup.bc_button_group/1,
      assigns,
      ~S"""
      <div role="group" aria-label="Message actions" class="button-group">Actions</div>
      """
    )
  end
end
