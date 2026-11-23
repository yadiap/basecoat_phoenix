defmodule BasecoatPhoenix.Components.Combobox do
  @moduledoc """
  Basecoat combobox: a text input with a filterable listbox.

  Options are a flat list or one level of groups, the same shape as
  `bc_select`:

      options={[
        %{value: "next", label: "Next.js"},
        %{label: "Frameworks", options: [%{value: "astro", label: "Astro"}]}
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
  attr(:options, :list, default: [])
  attr(:value, :any, default: nil)
  attr(:multiple, :boolean, default: false)
  attr(:format, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:clear, :boolean, default: false)
  attr(:empty, :string, default: "No items found.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_combobox(assigns) do
    resolved = Field.resolve(assigns.field, name: assigns.name, value: assigns.value)
    options = Options.normalize(assigns.options)

    assigns =
      assigns
      |> assign(:options, options)
      |> assign(:input_name, resolved.name)
      |> assign(:selected_label, selected_label(options, resolved.value, assigns.multiple))
      |> assign(
        :hidden_value,
        Options.hidden_value(options, resolved.value, assigns.multiple, assigns.format)
      )

    ~H"""
    <div
      id={@id}
      class={classes(["combobox", @class])}
      data-format={@format == "object" && "object"}
      phx-hook="BasecoatState"
      {@rest}
    >
      <%= if @clear do %>
        <div class="input-group">
          <.combobox_input id={@id} placeholder={@placeholder} value={@selected_label} />
          <span role="group" data-align="inline-end">
            <button type="button" data-clear aria-label="Clear selection">
              <svg
                class="size-4"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M18 6 6 18" /><path d="m6 6 12 12" />
              </svg>
            </button>
            <button
              type="button"
              class="btn"
              data-variant="ghost"
              data-size="icon-xs"
              aria-label="Open suggestions"
              aria-haspopup="listbox"
              aria-expanded="false"
              aria-controls={"#{@id}-listbox"}
            >
              <svg
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="m6 9 6 6 6-6" />
              </svg>
            </button>
          </span>
        </div>
      <% else %>
        <.combobox_input id={@id} placeholder={@placeholder} value={@selected_label} />
        <svg
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="combobox-trigger-icon"
        >
          <path d="m6 9 6 6 6-6" />
        </svg>
      <% end %>

      <div id={"#{@id}-popover"} data-popover aria-hidden="true">
        <div
          id={"#{@id}-listbox"}
          role="listbox"
          aria-orientation="vertical"
          aria-multiselectable={@multiple && "true"}
          data-empty={@empty}
        >
          <%= for option <- @options do %>
            <%= if option.options do %>
              <div role="group" aria-labelledby={"#{@id}-#{Options.slug(option.label)}"}>
                <div role="heading" id={"#{@id}-#{Options.slug(option.label)}"}>{option.label}</div>
                <%= for child <- option.options do %>
                  <div
                    role="option"
                    data-value={child.value}
                    data-filter={child.filter}
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
                data-filter={option.filter}
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

  # The text input is the query, so it starts empty. Basecoat fills it from the
  # hidden value on init.
  defp selected_label(_options, nil, false), do: nil
  defp selected_label(_options, [], true), do: nil
  defp selected_label(options, value, true), do: Options.selection_label(options, value, true, "")
  defp selected_label(options, value, false), do: Options.value_label(value, options)

  attr(:id, :string, required: true)
  attr(:placeholder, :string, default: nil)
  attr(:value, :string, default: nil)

  defp combobox_input(assigns) do
    ~H"""
    <input
      type="text"
      role="combobox"
      placeholder={@placeholder}
      autocomplete="off"
      autocorrect="off"
      spellcheck="false"
      aria-autocomplete="list"
      aria-expanded="false"
      aria-controls={"#{@id}-listbox"}
      value={@value}
    />
    """
  end
end
