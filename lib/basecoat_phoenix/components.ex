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
      import BasecoatPhoenix.Components.ButtonGroup
      import BasecoatPhoenix.Components.Badge
      import BasecoatPhoenix.Components.Avatar
      import BasecoatPhoenix.Components.Kbd
      import BasecoatPhoenix.Components.Separator
      import BasecoatPhoenix.Components.Skeleton
      import BasecoatPhoenix.Components.Spinner
      import BasecoatPhoenix.Components.Progress
      import BasecoatPhoenix.Components.Input
      import BasecoatPhoenix.Components.Textarea
      import BasecoatPhoenix.Components.NativeSelect
      import BasecoatPhoenix.Components.Label
      import BasecoatPhoenix.Components.Field
      import BasecoatPhoenix.Components.Checkbox
      import BasecoatPhoenix.Components.RadioGroup
      import BasecoatPhoenix.Components.Switch
      import BasecoatPhoenix.Components.Toggle
      import BasecoatPhoenix.Components.ToggleGroup
      import BasecoatPhoenix.Components.InputGroup
      import BasecoatPhoenix.Components.InputOtp
      import BasecoatPhoenix.Components.Slider
      import BasecoatPhoenix.Components.Combobox
    end
  end
end
