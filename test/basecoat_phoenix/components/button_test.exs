defmodule BasecoatPhoenix.Components.ButtonTest do
  use BasecoatPhoenix.ComponentCase
  alias BasecoatPhoenix.Components.Button

  test "bc_button renders a link with variant and size" do
    html =
      render(&Button.bc_button/1, %{
        variant: "outline",
        size: "sm",
        href: "/save",
        inner_block: [%{inner_block: fn _, _ -> "Save" end}]
      })

    link = one(html, "a.btn")
    assert attr(link, "href") == "/save"
    assert attr(link, "data-variant") == "outline"
    assert attr(link, "data-size") == "sm"
    assert text(link) == "Save"
  end

  test "bc_button omits default variant and size" do
    html = render(&Button.bc_button/1, %{inner_block: [%{inner_block: fn _, _ -> "Save" end}]})

    button = one(html, "button.btn")
    refute attr(button, "data-variant")
    refute attr(button, "data-size")
    assert attr(button, "type") == "button"
  end

  test "bc_button omits the documented default values too" do
    html =
      render(&Button.bc_button/1, %{
        variant: "primary",
        size: "default",
        inner_block: [%{inner_block: fn _, _ -> "Save" end}]
      })

    button = one(html, "button.btn")
    refute attr(button, "data-variant")
    refute attr(button, "data-size")
  end
end
