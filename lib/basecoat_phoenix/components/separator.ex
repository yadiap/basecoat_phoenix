defmodule BasecoatPhoenix.Components.Separator do
  @moduledoc """
  Basecoat separator. `decorative` renders `role="none"`.
  """
  use Phoenix.Component

  attr(:orientation, :string, default: nil)
  attr(:decorative, :boolean, default: false)
  attr(:rest, :global)

  def bc_separator(assigns) do
    ~H"""
    <hr
      role={if @decorative, do: "none", else: "separator"}
      aria-orientation={@orientation}
      {@rest}
    />
    """
  end
end
