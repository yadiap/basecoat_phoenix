defmodule BasecoatPhoenix.Components.ConventionsFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Button
  import BasecoatPhoenix.Components.Card

  def button(assigns) do
    ~H"""
    <.bc_button class="extra" id="save" phx-click="save">Save</.bc_button>
    """
  end

  def card(assigns) do
    ~H"""
    <.bc_card class="extra" id="box" data-test="x">Body</.bc_card>
    """
  end
end

defmodule BasecoatPhoenix.Components.ConventionsTest do
  use BasecoatPhoenix.ComponentCase

  defp fixture(fun), do: render(fun, %{})

  test "components append the caller's class and pass global attributes through" do
    button = fixture(&BasecoatPhoenix.Components.ConventionsFixture.button/1) |> one("button.btn")
    assert classes(button) == ["btn", "extra"]
    assert attr(button, "id") == "save"
    assert attr(button, "phx-click") == "save"

    card = fixture(&BasecoatPhoenix.Components.ConventionsFixture.card/1) |> one("div.card")
    assert classes(card) == ["card", "extra"]
    assert attr(card, "id") == "box"
    assert attr(card, "data-test") == "x"
  end
end
