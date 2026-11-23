defmodule BasecoatPhoenix.Components.Command do
  @moduledoc """
  Basecoat command menu, standalone or inside `bc_command_dialog`.

  Ids follow the upstream pattern: `bc_command_input` and `bc_command_list`
  take the base id and derive `ID-input` and `ID-menu`. Inside a dialog the base
  id is the dialog id, so `bc_command` itself needs no id.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:id, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:labelledby, :string, default: nil)
  attr(:manual_filter, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_command(assigns) do
    ~H"""
    <div
      id={@id}
      class={classes(["command", @class])}
      aria-label={@label}
      aria-labelledby={@labelledby}
      data-filter={@manual_filter && "manual"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:open, :boolean, default: false)
  attr(:label, :string, default: nil)
  attr(:labelledby, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_command_dialog(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={classes(["command-dialog", @class])}
      aria-label={@label}
      aria-labelledby={@labelledby}
      open={@open}
      phx-hook="BasecoatState"
      {@rest}
    >
      {render_slot(@inner_block)}
    </dialog>
    """
  end

  attr(:id, :string, required: true)
  attr(:placeholder, :string, default: "Type a command or search...")
  attr(:value, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_command_input(assigns) do
    ~H"""
    <header>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="lucide lucide-search-icon lucide-search"
      >
        <circle cx="11" cy="11" r="8" /><path d="m21 21-4.3-4.3" />
      </svg>
      <input
        type="text"
        id={"#{@id}-input"}
        placeholder={@placeholder}
        value={@value}
        autocomplete="off"
        autocorrect="off"
        spellcheck="false"
        aria-autocomplete="list"
        role="combobox"
        aria-expanded="true"
        aria-controls={"#{@id}-menu"}
        class={classes([@class])}
        {@rest}
      />
    </header>
    """
  end

  attr(:id, :string, required: true)
  attr(:empty, :string, default: "No results found.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_command_list(assigns) do
    ~H"""
    <div
      role="menu"
      id={"#{@id}-menu"}
      aria-orientation="vertical"
      data-empty={@empty}
      class={classes([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_command_group(assigns) do
    ~H"""
    <div role="group" aria-labelledby={@id} {@rest}>
      <span role="heading" id={@id}>{@label}</span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:filter, :string, default: nil)
  attr(:keywords, :string, default: nil)
  attr(:force, :boolean, default: false)
  attr(:keep_open, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:href, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_command_item(assigns) do
    ~H"""
    <a
      :if={@href}
      href={@href}
      role="menuitem"
      data-filter={@filter}
      data-keywords={@keywords}
      data-force={@force && ""}
      data-keep-command-open={@keep_open && ""}
      aria-disabled={@disabled && "true"}
      class={classes([@class])}
      {@rest}
    >{render_slot(@inner_block)}</a>
    <div
      :if={!@href}
      role="menuitem"
      data-filter={@filter}
      data-keywords={@keywords}
      data-force={@force && ""}
      data-keep-command-open={@keep_open && ""}
      aria-disabled={@disabled && "true"}
      class={classes([@class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:rest, :global)

  def bc_command_separator(assigns) do
    ~H"""
    <hr role="separator" {@rest} />
    """
  end

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_command_shortcut(assigns) do
    ~H"""
    <span data-shortcut {@rest}>{render_slot(@inner_block)}</span>
    """
  end
end
