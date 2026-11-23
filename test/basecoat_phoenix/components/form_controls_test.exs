defmodule BasecoatPhoenix.Components.FormControlsFixture do
  @moduledoc false
  use Phoenix.Component
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

  def input(assigns) do
    ~H"""
    <.bc_input type="email" placeholder="Email" />
    """
  end

  def textarea(assigns) do
    ~H"""
    <.bc_textarea placeholder="Type your message here" />
    """
  end

  def native_select(assigns) do
    ~H"""
    <.bc_native_select
      aria-label="Fruit"
      options={[
        %{value: "", label: "Select a fruit"},
        %{value: "apple", label: "Apple"},
        %{value: "banana", label: "Banana"}
      ]}
    />
    """
  end

  def label(assigns) do
    ~H"""
    <.bc_label for="email">Your email address</.bc_label>
    """
  end

  def fieldset(assigns) do
    ~H"""
    <.bc_fieldset legend="Payment Method">
      <.bc_field>
        <.bc_field_label for="card">Name on Card</.bc_field_label>
        <.bc_input id="card" placeholder="Evil Rabbit" />
        <.bc_field_description id="card">Enter the name on the card</.bc_field_description>
        <.bc_field_error id="card">Name is required</.bc_field_error>
      </.bc_field>
    </.bc_fieldset>
    """
  end

  def checkbox(assigns) do
    ~H"""
    <.bc_checkbox id="terms" name="terms">Accept terms and conditions</.bc_checkbox>
    """
  end

  def checkbox_description(assigns) do
    ~H"""
    <.bc_checkbox id="terms" name="terms" description="By clicking this checkbox, you agree.">
      Accept terms and conditions
    </.bc_checkbox>
    """
  end

  def radio_group(assigns) do
    ~H"""
    <.bc_radio_group label="View density" class="w-fit">
      <.bc_radio_group_item id="r1" name="density" value="default">Default</.bc_radio_group_item>
      <.bc_radio_group_item id="r2" name="density" value="compact" checked>
        Compact
      </.bc_radio_group_item>
    </.bc_radio_group>
    """
  end

  def switch(assigns) do
    ~H"""
    <.bc_switch id="airplane-mode" name="airplane-mode">Airplane Mode</.bc_switch>
    """
  end

  def toggle(assigns) do
    ~H"""
    <.bc_toggle name="toggle" value="italic" variant="ghost">Italic</.bc_toggle>
    """
  end

  def toggle_group(assigns) do
    ~H"""
    <.bc_toggle_group
      legend="Position"
      name="position"
      size="sm"
      value="top"
      options={[
        %{value: "top", label: "Top"},
        %{value: "bottom", label: "Bottom"}
      ]}
    />
    """
  end

  def input_group(assigns) do
    ~H"""
    <.bc_input_group>
      <.bc_input placeholder="Search..." />
      <.bc_input_group_addon align="start" aria-hidden="true">Icon</.bc_input_group_addon>
      <.bc_input_group_button label="Clear">Clear</.bc_input_group_button>
    </.bc_input_group>
    """
  end
end

defmodule BasecoatPhoenix.Components.FormControlsTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.{InputOtp, Slider, Combobox}

  defp field(name, value, errors \\ []) do
    %Phoenix.HTML.FormField{
      id: "order_#{name}",
      name: "order[#{name}]",
      value: value,
      errors: errors,
      field: name,
      form: %Phoenix.HTML.Form{params: %{}}
    }
  end

  test "bc_input renders the upstream markup and merges a class" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.input/1,
      %{},
      ~S(<input class="input" type="email" placeholder="Email" />)
    )

    html = render(&BasecoatPhoenix.Components.Input.bc_input/1, %{class: "w-full"})
    assert classes(one(html, "input")) == ["input", "w-full"]
  end

  test "bc_input derives name, id, value, and errors from a form field" do
    html =
      render(&BasecoatPhoenix.Components.Input.bc_input/1, %{
        field: field(:email, "a@b.c", [{"is invalid", []}])
      })

    input = one(html, "input")
    assert attr(input, "id") == "order_email"
    assert attr(input, "name") == "order[email]"
    assert attr(input, "value") == "a@b.c"
    assert attr(input, "aria-invalid") == "true"
    assert attr(input, "aria-describedby") == "order_email-error"
  end

  test "bc_textarea renders the upstream markup" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.textarea/1,
      %{},
      ~S(<textarea class="textarea" placeholder="Type your message here"></textarea>)
    )
  end

  test "bc_textarea derives its value and description from a form field" do
    html =
      render(&BasecoatPhoenix.Components.Textarea.bc_textarea/1, %{
        field: field(:bio, "Hello"),
        has_description: true
      })

    textarea = one(html, "textarea")
    assert attr(textarea, "name") == "order[bio]"
    assert attr(textarea, "aria-describedby") == "order_bio-description"
    assert text(textarea) == "Hello"
  end

  test "bc_native_select renders options and selects the current value" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.native_select/1,
      %{},
      ~S"""
      <select class="select" aria-label="Fruit">
        <option value="">Select a fruit</option>
        <option value="apple">Apple</option>
        <option value="banana">Banana</option>
      </select>
      """
    )
  end

  test "bc_native_select marks the selected option and honours disabled" do
    html =
      render(&BasecoatPhoenix.Components.NativeSelect.bc_native_select/1, %{
        options: [
          %{value: "apple", label: "Apple"},
          %{value: "pear", label: "Pear", disabled: true}
        ],
        value: "apple"
      })

    options = Floki.find(html, "option")
    assert attr(Enum.at(options, 0), "selected")
    refute attr(Enum.at(options, 1), "selected")
    assert attr(Enum.at(options, 1), "disabled")
  end

  test "bc_native_select derives name and value from a form field" do
    html =
      render(&BasecoatPhoenix.Components.NativeSelect.bc_native_select/1, %{
        field: field(:fruit, "banana"),
        options: [%{value: "apple", label: "Apple"}, %{value: "banana", label: "Banana"}]
      })

    select = one(html, "select")
    assert attr(select, "id") == "order_fruit"
    assert attr(select, "name") == "order[fruit]"
    assert attr(one(html, "option[value=banana]"), "selected")
  end

  test "bc_label renders the upstream markup" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.label/1,
      %{},
      ~S(<label class="label" for="email">Your email address</label>)
    )
  end

  test "bc_fieldset renders a legend and the field parts" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.fieldset/1,
      %{},
      ~S"""
      <fieldset class="fieldset">
        <legend>Payment Method</legend>
        <div role="group" class="field">
          <label for="card">Name on Card</label>
          <input class="input" id="card" placeholder="Evil Rabbit" type="text" />
          <p id="card-description">Enter the name on the card</p>
          <p id="card-error" role="alert">Name is required</p>
        </div>
      </fieldset>
      """
    )
  end

  test "bc_fieldset renders a group div when as is not fieldset" do
    html =
      render(&BasecoatPhoenix.Components.Field.bc_fieldset/1, %{
        as: "div",
        legend: "Payment method fields",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })

    root = one(html, "div.fieldset")
    assert attr(root, "role") == "group"
    assert text(one(root, "legend")) == "Payment method fields"
  end

  test "bc_field renders the orientation data attribute" do
    html =
      render(&BasecoatPhoenix.Components.Field.bc_field/1, %{
        orientation: "horizontal",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })

    field = one(html, "div.field")
    assert attr(field, "role") == "group"
    assert attr(field, "data-orientation") == "horizontal"
  end

  test "bc_checkbox renders the upstream markup" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.checkbox/1,
      %{},
      ~S"""
      <div role="group" class="fieldset">
        <div role="group" class="field" data-orientation="horizontal">
          <input type="checkbox" id="terms" name="terms" class="input" />
          <label for="terms">Accept terms and conditions</label>
        </div>
      </div>
      """
    )
  end

  test "bc_checkbox renders a description section and wires aria-describedby" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.checkbox_description/1,
      %{},
      ~S"""
      <div role="group" class="fieldset">
        <div role="group" class="field" data-orientation="horizontal">
          <input type="checkbox" id="terms" name="terms" class="input" aria-describedby="terms-description" />
          <section>
            <label for="terms">Accept terms and conditions</label>
            <p id="terms-description">By clicking this checkbox, you agree.</p>
          </section>
        </div>
      </div>
      """
    )
  end

  test "bc_checkbox derives checked state from a form field" do
    html =
      render(&BasecoatPhoenix.Components.Checkbox.bc_checkbox/1, %{
        field: field(:terms, true),
        inner_block: [%{inner_block: fn _, _ -> "Accept" end}]
      })

    input = one(html, "input[type=checkbox]")
    assert attr(input, "name") == "order[terms]"
    assert attr(input, "checked")
  end

  test "bc_radio_group renders the upstream markup" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.radio_group/1,
      %{},
      ~S"""
      <div role="radiogroup" aria-label="View density" data-slot="radio-group" class="w-fit">
        <div class="flex items-center gap-3">
          <input type="radio" id="r1" name="density" value="default" class="input" />
          <label for="r1">Default</label>
        </div>
        <div class="flex items-center gap-3">
          <input type="radio" id="r2" name="density" value="compact" class="input" checked />
          <label for="r2">Compact</label>
        </div>
      </div>
      """
    )
  end

  test "bc_radio_group_item checks the item matching the form field" do
    html =
      render(&BasecoatPhoenix.Components.RadioGroup.bc_radio_group_item/1, %{
        id: "r2",
        name: "order[density]",
        value: "compact",
        field: field(:density, "compact"),
        inner_block: [%{inner_block: fn _, _ -> "Compact" end}]
      })

    assert attr(one(html, "input[type=radio]"), "checked")
  end

  test "bc_switch renders the upstream markup" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.switch/1,
      %{},
      ~S"""
      <div role="group" class="field" data-orientation="horizontal">
        <input type="checkbox" role="switch" id="airplane-mode" name="airplane-mode" class="input" />
        <label for="airplane-mode">Airplane Mode</label>
      </div>
      """
    )
  end

  test "bc_toggle renders a button-styled label with a native input" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.toggle/1,
      %{},
      ~S"""
      <label class="btn" data-variant="ghost">
        <input type="checkbox" name="toggle" value="italic" />
        Italic
      </label>
      """
    )
  end

  test "bc_toggle_group renders the upstream structure and selects the value" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.toggle_group/1,
      %{},
      ~S"""
      <fieldset>
        <legend class="sr-only">Position</legend>
        <div class="flex gap-2">
          <label class="btn" data-variant="outline" data-size="sm">
            <input type="checkbox" name="position" value="top" checked />
            Top
          </label>
          <label class="btn" data-variant="outline" data-size="sm">
            <input type="checkbox" name="position" value="bottom" />
            Bottom
          </label>
        </div>
      </fieldset>
      """
    )
  end

  test "bc_toggle_group renders radios in single mode and supports several checked values" do
    single =
      render(&BasecoatPhoenix.Components.ToggleGroup.bc_toggle_group/1, %{
        legend: "Position",
        name: "position",
        single: true,
        value: "top",
        options: [%{value: "top", label: "Top"}, %{value: "bottom", label: "Bottom"}]
      })

    assert attr(one(single, "input[value=top]"), "type") == "radio"
    assert attr(one(single, "input[value=top]"), "checked")

    multi =
      render(&BasecoatPhoenix.Components.ToggleGroup.bc_toggle_group/1, %{
        legend: "Text formatting",
        name: "format",
        value: ["bold", "underline"],
        options: [
          %{value: "bold", label: "Bold"},
          %{value: "italic", label: "Italic"},
          %{value: "underline", label: "Underline"}
        ]
      })

    assert attr(one(multi, "input[value=bold]"), "checked")
    refute attr(one(multi, "input[value=italic]"), "checked")
    assert attr(one(multi, "input[value=underline]"), "checked")
  end

  test "bc_input_group renders the upstream markup" do
    assert_markup(
      &BasecoatPhoenix.Components.FormControlsFixture.input_group/1,
      %{},
      ~S"""
      <div class="input-group">
        <input class="input" type="text" placeholder="Search..." />
        <span data-align="start" aria-hidden="true">Icon</span>
        <button type="button" aria-label="Clear">Clear</button>
      </div>
      """
    )
  end

  test "bc_input_group_button renders a group div when as is not button" do
    html =
      render(&BasecoatPhoenix.Components.InputGroup.bc_input_group_button/1, %{
        as: "group",
        label: "Password actions",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })

    assert attr(one(html, "div"), "role") == "group"
    assert attr(one(html, "div"), "aria-label") == "Password actions"
  end

  test "bc_input_otp renders one slot per character" do
    html =
      render(&InputOtp.bc_input_otp/1, %{
        id: "otp",
        name: "code",
        length: 6,
        value: "123456"
      })

    root = one(html, "div.input-otp")
    assert attr(root, "id") == "otp"
    assert attr(root, "phx-update") == "ignore"
    refute attr(root, "phx-hook")

    input = one(root, "input.input")
    assert attr(input, "type") == "text"
    assert attr(input, "name") == "code"
    assert attr(input, "aria-label") == "Verification code"
    assert attr(input, "inputmode") == "numeric"
    assert attr(input, "autocomplete") == "one-time-code"
    assert attr(input, "spellcheck") == "false"
    assert attr(input, "maxlength") == "6"
    assert attr(input, "value") == "123456"
    assert attr(input, "dir") == "ltr"

    slots = one(root, "div[aria-hidden=true] > div") |> Floki.find("span")
    assert length(slots) == 6
  end

  test "bc_input_otp renders the filter and pattern attributes on the real input" do
    html =
      render(&InputOtp.bc_input_otp/1, %{
        id: "otp",
        name: "code",
        length: 4,
        filter: true,
        pattern: "[0-9]+"
      })

    input = one(html, "input.input")
    assert attr(input, "data-filter")
    assert attr(input, "pattern") == "[0-9]+"
    assert attr(input, "maxlength") == "4"
    assert length(Floki.find(html, "div[aria-hidden=true] span")) == 4
  end

  test "bc_slider renders the range input with the server-computed fill" do
    html =
      render(&Slider.bc_slider/1, %{
        id: "temperature",
        name: "temperature",
        min: 0,
        max: 100,
        step: 5,
        value: 25
      })

    input = one(html, "input[type=range]")
    assert attr(input, "id") == "temperature"
    assert attr(input, "name") == "temperature"
    assert classes(input) == ["input"]
    assert attr(input, "min") == "0"
    assert attr(input, "max") == "100"
    assert attr(input, "step") == "5"
    assert attr(input, "value") == "25"
    assert attr(input, "style") == "--slider-value: 25%"
    assert attr(input, "phx-hook") == "BasecoatState"
  end

  test "bc_slider defaults the value to the midpoint and handles a degenerate range" do
    default = render(&Slider.bc_slider/1, %{id: "volume"})
    assert attr(one(default, "input"), "value") == "50"
    assert attr(one(default, "input"), "style") == "--slider-value: 50%"

    flat = render(&Slider.bc_slider/1, %{id: "flat", min: 5, max: 5, value: 5})
    assert attr(one(flat, "input"), "style") == "--slider-value: 0%"
  end

  test "bc_slider offsets the fill by the minimum" do
    html = render(&Slider.bc_slider/1, %{id: "temp", min: 10, max: 20, value: 15})
    assert attr(one(html, "input"), "style") == "--slider-value: 50%"
  end

  test "bc_combobox renders the upstream markup" do
    assert_markup(
      &Combobox.bc_combobox/1,
      %{
        id: "framework",
        name: "framework",
        placeholder: "Select a framework",
        options: [%{value: "Next.js", label: "Next.js"}]
      },
      ~S"""
      <div class="combobox" id="framework" phx-hook="BasecoatState">
        <input type="text" role="combobox" placeholder="Select a framework" autocomplete="off" autocorrect="off" spellcheck="false" aria-autocomplete="list" aria-expanded="false" aria-controls="framework-listbox" />
        <svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="combobox-trigger-icon"><path d="m6 9 6 6 6-6" /></svg>
        <div id="framework-popover" data-popover aria-hidden="true">
          <div role="listbox" id="framework-listbox" aria-orientation="vertical" data-empty="No items found.">
            <div role="option" data-value="Next.js">Next.js</div>
          </div>
        </div>
        <input type="hidden" name="framework" value="" />
      </div>
      """
    )
  end

  test "bc_combobox groups options with a heading" do
    html =
      render(&Combobox.bc_combobox/1, %{
        id: "timezone",
        name: "timezone",
        options: [
          %{label: "Americas", options: [%{value: "america/new_york", label: "New York"}]}
        ]
      })

    group = one(html, "div[role=group]")
    assert attr(group, "aria-labelledby") == "timezone-americas"
    assert attr(one(group, "div[role=heading]"), "id") == "timezone-americas"
  end

  test "bc_combobox renders the clear control inside an input group" do
    html =
      render(&Combobox.bc_combobox/1, %{
        id: "framework",
        name: "framework",
        clear: true,
        options: [%{value: "Next.js", label: "Next.js"}]
      })

    root = one(html, "div.combobox")
    group = one(root, "div.input-group")
    assert one(group, "input[role=combobox]")

    clear = one(group, "button[data-clear]")
    assert attr(clear, "type") == "button"
    assert attr(clear, "aria-label") == "Clear selection"

    trigger = one(group, "button[aria-haspopup=listbox]")
    assert attr(trigger, "aria-controls") == "framework-listbox"
    assert attr(trigger, "data-size") == "icon-xs"

    refute one(root, "svg.combobox-trigger-icon")
  end

  test "bc_combobox encodes multiple and object values as JSON" do
    multiple =
      render(&Combobox.bc_combobox/1, %{
        id: "frameworks",
        name: "frameworks",
        multiple: true,
        value: ["Next.js", "Astro"],
        options: [%{value: "Next.js", label: "Next.js"}, %{value: "Astro", label: "Astro"}]
      })

    assert attr(one(multiple, "div[role=listbox]"), "aria-multiselectable") == "true"
    assert attr(one(multiple, "input[type=hidden]"), "value") == ~s(["Next.js","Astro"])

    object =
      render(&Combobox.bc_combobox/1, %{
        id: "country",
        name: "country",
        format: "object",
        value: "japan",
        options: [%{value: "japan", label: "Japan"}]
      })

    assert attr(one(object, "div.combobox"), "data-format") == "object"

    assert attr(one(object, "input[type=hidden]"), "value") ==
             ~s({"label":"Japan","value":"japan"})

    assert attr(one(object, "input[role=combobox]"), "value") == "Japan"
  end

  test "bc_combobox derives name, id, and value from a form field" do
    html =
      render(&Combobox.bc_combobox/1, %{
        id: "framework",
        field: field(:framework, "Remix"),
        options: [%{value: "Remix", label: "Remix"}]
      })

    assert attr(one(html, "input[type=hidden]"), "name") == "order[framework]"
    assert attr(one(html, "input[type=hidden]"), "value") == "Remix"
    assert attr(one(html, "input[role=combobox]"), "value") == "Remix"
  end
end
