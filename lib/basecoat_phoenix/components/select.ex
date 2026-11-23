defmodule BasecoatPhoenix.Components.Select do
  @moduledoc """
  Basecoat select. Options are a flat list or one level of groups:

      options={[
        %{value: "apple", label: "Apple"},
        %{label: "Fruits", options: [%{value: "pear", label: "Pear"}]}
      ]}

  Values are stored in Basecoat's hidden input: a string for single select,
  JSON for multiple select, and JSON objects with `format: "object"`.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  alias BasecoatPhoenix.Components.Options
  alias BasecoatPhoenix.Field

  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:field, :any, default: nil)
  attr(:options, :list, required: true)
  attr(:value, :any, default: nil)
  attr(:multiple, :boolean, default: false)
  attr(:format, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_select(assigns) do
    resolved = Field.resolve(assigns.field, name: assigns.name, value: assigns.value)
    options = Options.normalize(assigns.options)

    assigns =
      assigns
      |> assign(:options, options)
      |> assign(:input_name, resolved.name)
      |> assign(
        :selected_label,
        Options.selection_label(options, resolved.value, assigns.multiple, assigns.placeholder)
      )
      |> assign(
        :hidden_value,
        Options.hidden_value(options, resolved.value, assigns.multiple, assigns.format)
      )

    ~H"""
    <div
      id={@id}
      class={classes(["select", @class])}
      data-placeholder={@placeholder}
      data-format={@format == "object" && "object"}
      phx-hook="BasecoatState"
      {@rest}
    >
      <button
        type="button"
        id={"#{@id}-trigger"}
        aria-haspopup="listbox"
        aria-expanded="false"
        aria-controls={"#{@id}-listbox"}
      >
        <span class="truncate">{@selected_label}</span>
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
          class="lucide lucide-chevron-down text-muted-foreground opacity-50 shrink-0"
        >
          <path d="m6 9 6 6 6-6" />
        </svg>
      </button>
      <div id={"#{@id}-popover"} data-popover aria-hidden="true">
        <div
          id={"#{@id}-listbox"}
          role="listbox"
          aria-orientation="vertical"
          aria-labelledby={"#{@id}-trigger"}
          aria-multiselectable={@multiple && "true"}
        >
          <%= for option <- @options do %>
            <%= if option.options do %>
              <div role="group" aria-labelledby={"#{@id}-#{Options.slug(option.label)}"}>
                <span role="heading" id={"#{@id}-#{Options.slug(option.label)}"}>
                  {option.label}
                </span>
                <%= for child <- option.options do %>
                  <div
                    role="option"
                    data-value={child.value}
                    aria-disabled={child.disabled && "true"}
                  >
                    {child.label}
                  </div>
                <% end %>
              </div>
            <% else %>
              <div
                role="option"
                data-value={option.value}
                aria-disabled={option.disabled && "true"}
              >
                {option.label}
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
      <input type="hidden" name={@input_name} value={@hidden_value} />
    </div>
    """
  end
end
