defmodule BasecoatPhoenix.Components.SelectTest do
  use BasecoatPhoenix.ComponentCase
  alias BasecoatPhoenix.Components.Select

  @options [
    %{value: "apple", label: "Apple"},
    %{value: "banana", label: "Banana"}
  ]

  defp select(overrides \\ %{}) do
    Map.merge(
      %{
        id: "fruit",
        name: "fruit",
        placeholder: "Select a fruit",
        options: @options
      },
      overrides
    )
  end

  test "bc_select renders the upstream select structure" do
    html = render(&Select.bc_select/1, select())

    root = one(html, "div.select")
    assert attr(root, "id") == "fruit"
    assert attr(root, "data-placeholder") == "Select a fruit"
    assert attr(root, "phx-hook") == "BasecoatState"

    trigger = one(root, "button#fruit-trigger")
    assert attr(trigger, "type") == "button"
    assert attr(trigger, "aria-haspopup") == "listbox"
    assert attr(trigger, "aria-expanded") == "false"
    assert attr(trigger, "aria-controls") == "fruit-listbox"
    assert text(one(trigger, "span")) == "Select a fruit"
    assert one(trigger, "svg.lucide-chevron-down")

    popover = one(root, "div#fruit-popover[data-popover]")
    assert attr(popover, "aria-hidden") == "true"

    listbox = one(root, "div#fruit-listbox[role=listbox]")
    assert attr(listbox, "aria-labelledby") == "fruit-trigger"

    options = Floki.find(listbox, "[role=option]")

    assert Enum.map(options, &attr(&1, "data-value")) == ["apple", "banana"]
    assert Enum.map(options, &(text(&1) |> String.trim())) == ["Apple", "Banana"]

    hidden = one(root, "input[type=hidden]")
    assert attr(hidden, "name") == "fruit"
    assert attr(hidden, "value") == ""
  end

  test "bc_select shows and submits the selected value" do
    html = render(&Select.bc_select/1, select(%{value: "banana"}))

    assert text(one(html, "button span")) == "Banana"
    assert attr(one(html, "input[type=hidden]"), "value") == "banana"
  end

  test "bc_select groups options and wires the heading id" do
    options = [
      %{label: "Fruits", options: [%{value: "apple", label: "Apple"}]},
      %{label: "Vegetables", options: [%{value: "carrot", label: "Carrot"}]}
    ]

    html = render(&Select.bc_select/1, select(%{options: options}))

    group = one(html, "div[role=group]")
    assert attr(group, "aria-labelledby") == "fruit-fruits"

    heading = one(group, "span[role=heading]")
    assert attr(heading, "id") == "fruit-fruits"
    assert text(heading) |> String.trim() == "Fruits"
    assert length(Floki.find(html, "div[role=group]")) == 2
  end

  test "bc_select marks disabled options" do
    options = [%{value: "pear", label: "Pear", disabled: true}]
    html = render(&Select.bc_select/1, select(%{options: options}))

    assert attr(one(html, "[role=option]"), "aria-disabled") == "true"
  end

  test "bc_select encodes a multiple selection as JSON" do
    html =
      render(&Select.bc_select/1, select(%{multiple: true, value: ["apple", "banana"]}))

    assert attr(one(html, "div[role=listbox]"), "aria-multiselectable") == "true"
    assert attr(one(html, "input[type=hidden]"), "value") == ~s(["apple","banana"])
  end

  test "bc_select encodes object format as JSON" do
    html =
      render(
        &Select.bc_select/1,
        select(%{
          multiple: true,
          format: "object",
          value: [%{value: "apple", label: "Apple"}]
        })
      )

    assert attr(one(html, "div.select"), "data-format") == "object"

    assert attr(one(html, "input[type=hidden]"), "value") ==
             ~s([{"label":"Apple","value":"apple"}])
  end

  test "bc_select derives name and value from a form field" do
    field = %Phoenix.HTML.FormField{
      name: "order[fruit]",
      id: "order_fruit",
      value: "banana",
      errors: [],
      field: :fruit,
      form: %Phoenix.HTML.Form{params: %{}}
    }

    html = render(&Select.bc_select/1, select(%{id: "order-fruit", field: field, name: nil}))
    hidden = one(html, "input[type=hidden]")

    assert attr(hidden, "name") == "order[fruit]"
    assert attr(hidden, "value") == "banana"
    assert text(one(html, "button span")) == "Banana"
  end
end
