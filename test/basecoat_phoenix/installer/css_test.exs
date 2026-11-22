defmodule BasecoatPhoenix.Installer.CssTest do
  use ExUnit.Case, async: true

  alias BasecoatPhoenix.Installer.CSS

  test "remove_plugin_block removes the block and its brace body" do
    css = ~S"""
    @import "tailwindcss";
    @plugin "daisyui/packages/bundle/daisyui" {
      themes: false;
    }
    @custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));
    """

    out = CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui")
    refute out =~ "daisyui"
    assert out =~ ~s(@import "tailwindcss";)
    assert out =~ "@custom-variant dark"
  end

  test "remove_plugin_block leaves other content untouched" do
    css = ~s(@plugin "daisyui/packages/bundle/daisyui" { themes: false; }\n@theme { --x: 1; })
    out = CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui")
    assert out == "@theme { --x: 1; }"
  end

  test "remove_plugin_block matches the quoted plugin name, not a prefix" do
    css =
      ~s(@plugin "daisyui/packages/bundle/daisyui-theme" { name: "dark"; }\n@theme { --x: 1; })

    out = CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui")
    assert out == css
  end

  test "remove_plugin_block is idempotent" do
    css = ~s(@import "tailwindcss";\n)
    assert CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui") == css
  end

  test "insert_after matches a line prefix and is idempotent" do
    css = ~s|@import "tailwindcss" source(none);\n@source "../js";\n|
    line = ~s(@import "../vendor/basecoat/basecoat.css";)
    once = CSS.insert_after(css, ~s(@import "tailwindcss"), line)

    assert once ==
             ~s|@import "tailwindcss" source(none);\n#{line}\n@source "../js";\n|

    assert CSS.insert_after(once, ~s(@import "tailwindcss"), line) == once
  end

  test "insert_after returns the input unchanged when the anchor is missing" do
    assert CSS.insert_after("a\n", "zzz", "b") == "a\n"
  end
end
