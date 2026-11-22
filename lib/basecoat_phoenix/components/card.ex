defmodule BasecoatPhoenix.Components.Card do
  @moduledoc """
  Basecoat card components.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_card(assigns) do
    ~H"""
    <div class={classes(["card", @class])} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  defsemantic(:bc_card_header, :header)
  defsemantic(:bc_card_title, :h2)
  defsemantic(:bc_card_description, :p)
  defsemantic(:bc_card_action, :div, class: "card-action")
  defsemantic(:bc_card_content, :section)
  defsemantic(:bc_card_footer, :footer)
end
