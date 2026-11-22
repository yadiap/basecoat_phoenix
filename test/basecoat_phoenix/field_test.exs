defmodule BasecoatPhoenix.FieldTest do
  use ExUnit.Case, async: true

  test "resolve reads a form field" do
    field = %Phoenix.HTML.FormField{
      name: "user[name]",
      id: "user_name",
      value: "Ada",
      errors: [{"is required", []}],
      field: :name,
      form: %Phoenix.HTML.Form{params: %{}}
    }

    result = BasecoatPhoenix.Field.resolve(field, describedby: "user_name-description")
    assert result.name == "user[name]"
    assert result.id == "user_name"
    assert result.value == "Ada"
    assert result.errors == ["is required"]
    assert result.invalid?
    assert result.describedby == "user_name-description user_name-error"
  end

  test "resolve reads explicit attrs" do
    result = BasecoatPhoenix.Field.resolve(nil, name: "email", id: "email", value: "a@b.c")
    assert result.name == "email"
    assert result.id == "email"
    assert result.value == "a@b.c"
    refute result.invalid?
    assert result.describedby == nil
  end
end
