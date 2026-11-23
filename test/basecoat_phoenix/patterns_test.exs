defmodule BasecoatPhoenix.PatternsTest do
  use ExUnit.Case, async: true

  test "pattern pages do not ship components" do
    for module <- ~w(Direction AspectRatio ScrollArea DataTable Tooltip) do
      refute Code.ensure_loaded?(Module.concat(BasecoatPhoenix.Components, module))
    end
  end
end
