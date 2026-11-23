defmodule BasecoatPhoenix.ExamplesTest do
  use ExUnit.Case, async: true

  @doc_path Path.expand("../../docs/examples.md", __DIR__)
  @components_path Path.expand("../../lib/basecoat_phoenix/components", __DIR__)

  test "every component has an example in docs/examples.md" do
    documented =
      @doc_path
      |> File.read!()
      |> then(&Regex.scan(~r/\.(bc_[a-z0-9_]+)/, &1, capture: :all_but_first))
      |> List.flatten()
      |> MapSet.new()

    shipped =
      @components_path
      |> Path.join("*.ex")
      |> Path.wildcard()
      |> Enum.flat_map(fn path ->
        Regex.scan(~r/def (bc_[a-z0-9_]+)\(/, File.read!(path), capture: :all_but_first)
      end)
      |> List.flatten()
      |> MapSet.new()

    missing = MapSet.difference(shipped, documented) |> Enum.sort()

    assert missing == [], """
    These components have no example in docs/examples.md:

    #{Enum.map_join(missing, "\n", &"  * #{&1}")}
    """
  end
end
