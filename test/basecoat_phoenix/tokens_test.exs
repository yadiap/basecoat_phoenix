defmodule BasecoatPhoenix.TokensTest do
  use ExUnit.Case, async: true

  alias BasecoatPhoenix.Installer

  # The tokens a shadcn/ui theme sets, which tweakcn.com exports verbatim.
  @shadcn_tokens ~w(
    background foreground
    card card-foreground
    popover popover-foreground
    primary primary-foreground
    secondary secondary-foreground
    muted muted-foreground
    accent accent-foreground
    destructive
    border input ring
    chart-1 chart-2 chart-3 chart-4 chart-5
    sidebar sidebar-foreground
    sidebar-primary sidebar-primary-foreground
    sidebar-accent sidebar-accent-foreground
    sidebar-border sidebar-ring
  )

  # Tokens Basecoat's own theme block omits; theme.css supplies them.
  @bridged_tokens ~w(font-serif destructive-foreground)

  test "every shadcn token is mapped to a Tailwind color" do
    css = File.read!(bundle())

    missing =
      Enum.reject(@shadcn_tokens, fn token ->
        String.contains?(css, "--color-#{token}: var(--#{token});")
      end)

    assert missing == [], """
    These shadcn tokens have no `--color-*` mapping in the Basecoat bundle, so
    a tweakcn theme would set them without any utility using them:

    #{Enum.map_join(missing, "\n", &"  * --#{&1}")}
    """
  end

  test "theme.css bridges the tokens Basecoat leaves out" do
    {:ok, messages} = Installer.install(project() ++ [dry_run: true])
    assert Enum.any?(messages, &(&1 =~ "theme.css"))

    theme = theme_template()

    for token <- @bridged_tokens do
      assert theme =~ "--#{token}:", "theme.css does not define --#{token}"
    end

    assert theme =~ "--color-destructive-foreground: var(--destructive-foreground);"
    assert theme =~ "--font-serif: var(--font-serif);"
  end

  test "the shadcn token set is defined in both light and dark" do
    css = File.read!(bundle())

    [light, dark] =
      Regex.run(~r/:root \{(.*?)\n\}\n\n\.dark \{(.*?)\n\}/s, css, capture: :all_but_first)

    for token <- @shadcn_tokens do
      assert light =~ "--#{token}:", ":root is missing --#{token}"
      assert dark =~ "--#{token}:", ".dark is missing --#{token}"
    end
  end

  defp bundle do
    Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat", "basecoat-vega.bundle.css"])
  end

  defp theme_template do
    root = Path.join(System.tmp_dir!(), "bc_theme_#{System.unique_integer([:positive])}")
    css = Path.join(root, "assets/css/app.css")
    js = Path.join(root, "assets/js/app.js")
    File.mkdir_p!(Path.dirname(css))
    File.mkdir_p!(Path.dirname(js))
    File.write!(css, ~s|@import "tailwindcss" source(none);\n|)
    File.write!(js, "const csrfToken = 1\n")

    on_exit(fn -> File.rm_rf!(root) end)

    assert {:ok, _} = Installer.install(root: root, css: css, js: js)

    File.read!(Path.join(root, "assets/css/theme.css"))
  end

  defp project do
    root = Path.join(System.tmp_dir!(), "bc_theme_dry_#{System.unique_integer([:positive])}")
    css = Path.join(root, "assets/css/app.css")
    js = Path.join(root, "assets/js/app.js")
    File.mkdir_p!(Path.dirname(css))
    File.mkdir_p!(Path.dirname(js))
    File.write!(css, ~s|@import "tailwindcss" source(none);\n|)
    File.write!(js, "const csrfToken = 1\n")
    on_exit(fn -> File.rm_rf!(root) end)
    [root: root, css: css, js: js]
  end
end
