defmodule BasecoatPhoenix.Components.Checkbox do
  @moduledoc """
  Basecoat checkbox with its field wrapper.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]
  alias BasecoatPhoenix.Field

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:field, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_checkbox(assigns) do
    resolved =
      Field.resolve(assigns.field,
        id: assigns.id,
        name: assigns.name,
        has_description: assigns.description != nil
      )

    # A checkbox submits its own `value`; the field only says whether it starts
    # checked.
    assigns =
      assigns
      |> assign(:resolved, resolved)
      |> assign(:checked?, assigns.checked or truthy(assigns.field && assigns.field.value))

    ~H"""
    <div role="group" class={classes(["fieldset", @class])} {@rest}>
      <div
        role="group"
        class="field"
        data-orientation="horizontal"
        data-disabled={@disabled}
      >
        <input
          type="checkbox"
          id={@resolved.id}
          name={@resolved.name}
          value={@value}
          class="input"
          checked={@checked?}
          disabled={@disabled}
          aria-invalid={@resolved.invalid? && "true"}
          aria-describedby={@resolved.describedby}
        />
        <section :if={@description}>
          <label for={@resolved.id}>{render_slot(@inner_block)}</label>
          <p id={"#{@resolved.id}-description"}>{@description}</p>
        </section>
        <label :if={!@description} for={@resolved.id}>{render_slot(@inner_block)}</label>
      </div>
    </div>
    """
  end

  defp truthy(nil), do: false
  defp truthy(false), do: false
  defp truthy(""), do: false
  defp truthy("false"), do: false
  defp truthy(_), do: true
end
