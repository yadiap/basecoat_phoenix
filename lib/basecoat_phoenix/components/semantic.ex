defmodule BasecoatPhoenix.Components.Semantic do
  @moduledoc false

  @doc """
  Declares a subcomponent that renders one upstream tag with an optional class.
  """
  defmacro defsemantic(name, tag, opts \\ []) do
    class = opts[:class]

    quote do
      attr(:class, :string, default: nil)
      attr(:rest, :global)
      slot(:inner_block, required: true)

      # Phoenix only accepts attr/slot next to a bodyless head.
      def unquote(name)(assigns)

      def unquote(name)(assigns) do
        BasecoatPhoenix.Components.Semantic.render(unquote(tag), unquote(class), assigns)
      end
    end
  end

  @doc false
  def classes(list) do
    list |> List.flatten() |> Enum.reject(&is_nil/1) |> Enum.join(" ")
  end

  @doc false
  def render(tag, base_class, assigns) do
    classes = [base_class, assigns.class] |> List.flatten() |> Enum.reject(&is_nil/1)

    rest =
      if classes == [],
        do: assigns.rest,
        else: Map.put(assigns.rest, :class, Enum.join(classes, " "))

    Phoenix.Component.dynamic_tag(%{
      __changed__: Map.get(assigns, :__changed__, %{}),
      tag_name: to_string(tag),
      rest: rest,
      inner_block: assigns.inner_block
    })
  end
end
