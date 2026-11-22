defmodule BasecoatPhoenix.SmokeTest do
  use ExUnit.Case, async: true

  test "library module is loaded" do
    assert Code.ensure_loaded?(BasecoatPhoenix)
  end
end
