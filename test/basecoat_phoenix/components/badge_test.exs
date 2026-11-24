defmodule BasecoatPhoenix.Components.BadgeFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Badge

  def badge_with_icon(assigns) do
    ~H"""
    <.bc_badge>
      <svg data-icon="inline-start" class="lucide lucide-check"></svg> Verified
    </.bc_badge>
    """
  end
end

defmodule BasecoatPhoenix.Components.BadgeTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.Badge
  alias BasecoatPhoenix.Components.BadgeFixture

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

  test "bc_badge keeps the icon marker that drives the 1.3.0 spacing" do
    html = render(&BadgeFixture.badge_with_icon/1)

    badge = one(html, "span.badge")
    assert attr(one(badge, "svg"), "data-icon") == "inline-start"
    assert text(badge) |> String.trim() == "Verified"
  end
end
