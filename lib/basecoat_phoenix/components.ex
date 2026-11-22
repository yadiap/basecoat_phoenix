defmodule BasecoatPhoenix.Components do
  @moduledoc """
  Imports every Basecoat Phoenix component.

      def html_helpers do
        quote do
          use BasecoatPhoenix.Components
        end
      end
  """

  defmacro __using__(_opts) do
    quote do
      import BasecoatPhoenix.Components.Button
      import BasecoatPhoenix.Components.Card
      import BasecoatPhoenix.Components.Dialog
      import BasecoatPhoenix.Components.Select
    end
  end
end
