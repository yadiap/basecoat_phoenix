defmodule BasecoatPhoenix.Components.RadioGroup do
  @moduledoc """
  Basecoat radio group and items.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_radio_group(assigns) do
    ~H"""
    <div
      role="radiogroup"
      aria-label={@label}
      data-slot="radio-group"
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:value, :string, required: true)
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:field, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_radio_group_item(assigns) do
    checked? =
      assigns.checked or
        (assigns.field && to_string(assigns.field.value) == to_string(assigns.value))

    assigns = assign(assigns, :checked?, checked?)

    ~H"""
    <div class={classes(["flex items-center gap-3", @class])} {@rest}>
      <input
        type="radio"
        id={@id}
        name={@name}
        value={@value}
        class="input"
        checked={@checked?}
        disabled={@disabled}
      />
      <label for={@id}>{render_slot(@inner_block)}</label>
    </div>
    """
  end
end
