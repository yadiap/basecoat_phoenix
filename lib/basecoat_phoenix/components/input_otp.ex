defmodule BasecoatPhoenix.Components.InputOtp do
  @moduledoc """
  Basecoat one-time-code input.

  Basecoat writes each character into the pre-rendered slot spans, so the root
  carries `phx-update="ignore"`: a patch would delete that client state. The
  real input still submits normally.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]
  alias BasecoatPhoenix.Field

  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:field, :any, default: nil)
  attr(:length, :integer, default: 6)
  attr(:value, :any, default: nil)
  attr(:filter, :boolean, default: false)
  attr(:pattern, :string, default: nil)
  attr(:label, :string, default: "Verification code")
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_input_otp(assigns) do
    resolved = Field.resolve(assigns.field, name: assigns.name, value: assigns.value)
    assigns = assign(assigns, :resolved, resolved)

    ~H"""
    <div id={@id} class={classes(["input-otp", @class])} phx-update="ignore" {@rest}>
      <input
        class="input"
        type="text"
        id={"#{@id}-input"}
        name={@resolved.name}
        value={@resolved.value}
        aria-label={@label}
        inputmode="numeric"
        autocomplete="one-time-code"
        spellcheck="false"
        maxlength={@length}
        pattern={@pattern}
        data-filter={@filter && ""}
        disabled={@disabled}
        dir="ltr"
      />
      <div aria-hidden="true">
        <div>
          <span :for={_ <- 1..@length//1}></span>
        </div>
      </div>
    </div>
    """
  end
end
