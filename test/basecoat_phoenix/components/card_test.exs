defmodule BasecoatPhoenix.Components.CardFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Card

  def card(assigns) do
    ~H"""
    <.bc_card>
      <.bc_card_header>
        <.bc_card_title>Title</.bc_card_title>
        <.bc_card_description>Description.</.bc_card_description>
        <.bc_card_action>Action</.bc_card_action>
      </.bc_card_header>
      <.bc_card_content>Body</.bc_card_content>
      <.bc_card_footer>Footer</.bc_card_footer>
    </.bc_card>
    """
  end
end

defmodule BasecoatPhoenix.Components.CardTest do
  use BasecoatPhoenix.ComponentCase

  test "bc_card matches the upstream card structure" do
    assert_markup(&BasecoatPhoenix.Components.CardFixture.card/1, %{}, ~S"""
    <div class="card">
      <header>
        <h2>Title</h2>
        <p>Description.</p>
        <div class="card-action">Action</div>
      </header>
      <section>Body</section>
      <footer>Footer</footer>
    </div>
    """)
  end
end
