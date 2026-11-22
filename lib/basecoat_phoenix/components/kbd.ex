defmodule BasecoatPhoenix.Components.Kbd do
  @moduledoc """
  Basecoat keyboard key.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic

  defsemantic(:bc_kbd, :kbd, class: "kbd")
end
