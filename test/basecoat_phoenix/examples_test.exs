defmodule BasecoatPhoenix.ExamplesTest do
  use ExUnit.Case, async: true

  @doc_path Path.expand("../../docs/examples.md", __DIR__)
  @components_path Path.expand("../../lib/basecoat_phoenix/components", __DIR__)

  # Attributes every component accepts through the shared prose, not per section.
  @shared ~w(class rest)

  # Components whose name does not prefix a heading.
  @section_aliases %{
    "bc_toaster" => "toast",
    "bc_label" => "label-input-textarea",
    "bc_input" => "label-input-textarea",
    "bc_textarea" => "label-input-textarea",
    "bc_field" => "fieldset",
    "bc_field_label" => "label-input-textarea",
    "bc_field_description" => "label-input-textarea",
    "bc_field_error" => "label-input-textarea"
  }

  setup_all do
    %{doc: File.read!(@doc_path), components: components()}
  end

  test "every component has an example in docs/examples.md", %{doc: doc, components: components} do
    documented =
      doc
      |> then(&Regex.scan(~r/\.(bc_[a-z0-9_]+)/, &1, capture: :all_but_first))
      |> List.flatten()
      |> MapSet.new()

    missing =
      components |> Map.keys() |> MapSet.new() |> MapSet.difference(documented) |> Enum.sort()

    assert missing == [], """
    These components have no example in docs/examples.md:

    #{Enum.map_join(missing, "\n", &"  * #{&1}")}
    """
  end

  test "every component attribute appears in its section", %{doc: doc, components: components} do
    sections = sections(doc)

    missing =
      for {name, attrs} <- components,
          section = sections[section_slug(name, sections)],
          attr <- attrs,
          attr not in @shared,
          not mentions?(section, attr),
          do: "#{name}: `#{attr}` is undocumented"

    assert missing == [], """
    These attributes have no mention in their docs/examples.md section:

    #{Enum.map_join(Enum.sort(missing), "\n", &"  * #{&1}")}
    """
  end

  test "every section a component resolves to exists", %{doc: doc, components: components} do
    sections = sections(doc)

    unresolved =
      for {name, _attrs} <- components,
          section_slug(name, sections) == nil,
          do: name

    assert unresolved == [], """
    These components resolve to no heading in docs/examples.md:

    #{Enum.map_join(Enum.sort(unresolved), "\n", &"  * #{&1}")}
    """
  end

  defp mentions?(section, attr) do
    Regex.match?(~r/(?<![a-z0-9_])#{Regex.escape(attr)}(?![a-z0-9_])/, section)
  end

  defp section_slug(name, sections) do
    slug = String.replace_prefix(name, "bc_", "") |> String.replace("_", "-")
    Map.get(@section_aliases, name) || resolve(slug, sections)
  end

  # bc_tab_list -> "tab-list", "tab", "tabs"; bc_sidebar_menu_button -> "sidebar".
  defp resolve(slug, sections) do
    slug
    |> String.split("-")
    |> prefixes()
    |> Enum.find_value(fn prefix ->
      cond do
        Map.has_key?(sections, prefix) -> prefix
        Map.has_key?(sections, prefix <> "s") -> prefix <> "s"
        true -> nil
      end
    end)
  end

  defp prefixes(parts) do
    parts
    |> Enum.with_index()
    |> Enum.map(fn {_part, index} -> parts |> Enum.take(index + 1) |> Enum.join("-") end)
    |> Enum.reverse()
  end

  defp sections(doc) do
    doc
    |> String.split(~r/^[#]{2,3} /m)
    |> Enum.drop(1)
    |> Map.new(fn chunk ->
      [heading | rest] = String.split(chunk, "\n", parts: 2)
      {slug(heading), Enum.join(rest, "\n")}
    end)
  end

  defp slug(heading) do
    heading
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  defp components do
    @components_path
    |> Path.join("*.ex")
    |> Path.wildcard()
    |> Enum.reduce(%{}, fn path, acc ->
      path
      |> File.read!()
      |> collect([])
      |> Map.merge(acc, fn _key, new, old -> Enum.uniq(new ++ old) end)
    end)
  end

  # Attributes are declared right before the def they belong to.
  defp collect(source, pending) do
    source
    |> String.split("\n")
    |> Enum.reduce({%{}, pending}, fn line, {found, pending} ->
      cond do
        match = Regex.run(~r/^\s*attr\(:([a-z_]+)/, line) ->
          {found, [Enum.at(match, 1) | pending]}

        match = Regex.run(~r/^\s*def (bc_[a-z0-9_]+)\(/, line) ->
          name = Enum.at(match, 1)
          {Map.update(found, name, pending, &Enum.uniq(pending ++ &1)), []}

        match = Regex.run(~r/^\s*defsemantic\(:(bc_[a-z0-9_]+)/, line) ->
          {Map.put_new(found, Enum.at(match, 1), []), []}

        true ->
          {found, pending}
      end
    end)
    |> elem(0)
  end
end
