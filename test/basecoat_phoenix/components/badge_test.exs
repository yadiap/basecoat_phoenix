defmodule BasecoatPhoenix.Components.BadgeTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Badge

  defp badge(value) do
    %{variant: value, inner_block: [%{inner_block: fn _, _ -> "Badge" end}]}
  end

  test "bc_badge omits the default variant" do
    assert_markup(&Badge.bc_badge/1, badge(nil), ~S(<span class="badge">Badge</span>))
    assert_markup(&Badge.bc_badge/1, badge("primary"), ~S(<span class="badge">Badge</span>))
  end

  test "bc_badge renders every non-default variant" do
    for variant <- ~w(secondary destructive outline ghost) do
      assert_markup(
        &Badge.bc_badge/1,
        badge(variant),
        ~s(<span class="badge" data-variant="#{variant}">Badge</span>)
      )
    end
  end
end
