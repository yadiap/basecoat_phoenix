defmodule BasecoatPhoenix.ComponentCase do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import BasecoatPhoenix.ComponentCase
      # `attr/2` here is the test helper; keep Phoenix.Component's macro out.
      import Phoenix.Component, except: [attr: 2, attr: 3]
      import Phoenix.LiveViewTest, only: [render_component: 2]
    end
  end

  # Needed here too: `render/2` and `assert_markup/3` are defined in this module.
  import ExUnit.Assertions
  import Phoenix.LiveViewTest, only: [render_component: 2]

  def render(component, assigns \\ %{}) do
    component |> render_component(assigns) |> Floki.parse_fragment!()
  end

  def one(fragment, selector) do
    fragment |> Floki.find(selector) |> List.first()
  end

  def attr(node, name) do
    node |> Floki.attribute(name) |> List.first()
  end

  def classes(node) do
    (attr(node, "class") || "") |> String.split()
  end

  def text(node), do: Floki.text(node)

  @doc """
  Asserts the rendered tree matches the upstream doc example.

  Whitespace is collapsed, attribute order is ignored, and a missing closing
  tag is tolerated. Use this for the markup-fidelity contract.
  """
  def assert_markup(component, assigns, expected) do
    actual = component |> render(assigns) |> normalize()
    assert actual == normalize(expected)
  end

  # `render/2` returns a parsed tree; `expected` is a string. Accept both.
  defp normalize(tree) when is_list(tree) do
    tree
    |> sort_attrs()
    |> Floki.raw_html()
    |> String.replace(~r/>\s+</, "><")
    |> String.trim()
  end

  defp normalize(html) when is_binary(html) do
    html |> Floki.parse_fragment!() |> normalize()
  end

  defp sort_attrs(nodes) when is_list(nodes), do: Enum.map(nodes, &sort_attrs/1)

  defp sort_attrs({tag, attrs, children}) do
    {tag, Enum.sort(attrs), sort_attrs(children)}
  end

  defp sort_attrs(node), do: node
end
