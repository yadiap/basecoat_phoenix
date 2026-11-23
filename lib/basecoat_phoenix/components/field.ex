defmodule BasecoatPhoenix.Components.Field do
  @moduledoc """
  Basecoat field layout: fieldset, field, label, description, and error.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic

  attr(:legend, :string, default: nil)
  attr(:as, :string, default: "fieldset")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_fieldset(assigns) do
    ~H"""
    <fieldset :if={@as == "fieldset"} class={classes(["fieldset", @class])} {@rest}>
      <legend :if={@legend}>{@legend}</legend>
      {render_slot(@inner_block)}
    </fieldset>
    <div :if={@as != "fieldset"} role="group" class={classes(["fieldset", @class])} {@rest}>
      <legend :if={@legend}>{@legend}</legend>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:orientation, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_field(assigns) do
    ~H"""
    <div
      role="group"
      class={classes(["field", @class])}
      data-orientation={@orientation}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:for, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_field_label(assigns) do
    ~H"""
    <label for={@for} {@rest}>{render_slot(@inner_block)}</label>
    """
  end

  attr(:id, :string, required: true)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_field_description(assigns) do
    ~H"""
    <p id={"#{@id}-description"} {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  attr(:id, :string, required: true)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_field_error(assigns) do
    ~H"""
    <p
      id={"#{@id}-error"}
      role="alert"
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end
end
