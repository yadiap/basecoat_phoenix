defmodule BasecoatPhoenix.Components.DropdownMenu do
  @moduledoc """
  Basecoat dropdown menu: a relative wrapper around a trigger button and an
  inline popover. Ids follow the upstream `ID-trigger`, `ID-popover`, and
  `ID-menu` pattern.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:id, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu(assigns) do
    ~H"""
    <div id={@id} class={classes(["dropdown-menu", @class])} phx-hook="BasecoatState" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:variant, :string, default: "outline")
  attr(:size, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_trigger(assigns) do
    ~H"""
    <button
      type="button"
      id={"#{@id}-trigger"}
      aria-haspopup="menu"
      aria-controls={"#{@id}-menu"}
      aria-expanded="false"
      class={classes(["btn", @class])}
      data-variant={@variant}
      data-size={@size}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  attr(:id, :string, required: true)
  attr(:side, :string, default: nil)
  attr(:align, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_content(assigns) do
    ~H"""
    <div
      id={"#{@id}-popover"}
      data-popover
      data-side={@side}
      data-align={@align}
      aria-hidden="true"
      class={classes([@class])}
      {@rest}
    >
      <div role="menu" id={"#{@id}-menu"} aria-labelledby={"#{@id}-trigger"}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr(:id, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_group(assigns) do
    ~H"""
    <div role="group" aria-labelledby={@id} {@rest}>
      <div :if={@label} role="heading" id={@id}>{@label}</div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:id, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_label(assigns) do
    ~H"""
    <div role="heading" id={@id} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  attr(:disabled, :boolean, default: false)
  attr(:variant, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_item(assigns) do
    ~H"""
    <div role="menuitem" aria-disabled={@disabled && "true"} data-variant={@variant} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_checkbox_item(assigns) do
    ~H"""
    <div
      role="menuitemcheckbox"
      aria-checked={to_string(@checked)}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      <span data-indicator>{indicator_svg()}</span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_radio_item(assigns) do
    ~H"""
    <div
      role="menuitemradio"
      aria-checked={to_string(@checked)}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      <span data-indicator>{indicator_svg()}</span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:rest, :global)

  def bc_dropdown_menu_separator(assigns) do
    ~H"""
    <hr role="separator" {@rest} />
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_dropdown_menu_shortcut(assigns) do
    ~H"""
    <kbd {@rest}>{render_slot(@inner_block)}</kbd>
    """
  end

  # Upstream repeats this check icon inside every checkbox and radio indicator.
  defp indicator_svg do
    Phoenix.HTML.raw("""
    <svg class="lucide lucide-check" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5" /></svg>
    """)
  end
end
