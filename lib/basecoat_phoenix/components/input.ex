defmodule BasecoatPhoenix.Components.Input do
  @moduledoc """
  Basecoat text input.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]
  alias BasecoatPhoenix.Field

  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:type, :string, default: "text")
  attr(:value, :any, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:field, :any, default: nil)
  attr(:errors, :list, default: [])
  attr(:invalid, :boolean, default: false)
  attr(:describedby, :string, default: nil)
  attr(:has_description, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_input(assigns) do
    resolved =
      Field.resolve(assigns.field,
        id: assigns.id,
        name: assigns.name,
        value: assigns.value,
        errors: assigns.errors,
        describedby: assigns.describedby,
        has_description: assigns.has_description,
        invalid: assigns.invalid
      )

    assigns = assign(assigns, :resolved, resolved)

    ~H"""
    <input
      type={@type}
      class={classes(["input", @class])}
      id={@resolved.id}
      name={@resolved.name}
      value={@resolved.value}
      placeholder={@placeholder}
      aria-invalid={@resolved.invalid? && "true"}
      aria-describedby={@resolved.describedby}
      {@rest}
    />
    """
  end
end
