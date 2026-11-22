defmodule BasecoatPhoenix.InstallerTest do
  use ExUnit.Case, async: true

  alias BasecoatPhoenix.Installer

  @css """
  @import "tailwindcss" source(none);
  @plugin "daisyui/packages/bundle/daisyui" {
    themes: false;
  }
  @plugin "daisyui/packages/bundle/daisyui-theme" {
    name: "dark";
    default: false;
  }
  @plugin "daisyui/packages/bundle/daisyui-theme" {
    name: "light";
    default: true;
  }
  @custom-variant phx-click-loading (.phx-click-loading&, .phx-click-loading &);
  @custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));
  """

  @js """
  import {hooks as colocatedHooks} from "phoenix-colocated/my_app"
  const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  const liveSocket = new LiveSocket("/live", Socket, {hooks: {...colocatedHooks}})
  """

  setup do
    root = Path.join(System.tmp_dir!(), "bc_installer_#{System.unique_integer([:positive])}")
    css_path = Path.join(root, "assets/css/app.css")
    js_path = Path.join(root, "assets/js/app.js")
    assets = Path.join(root, "assets")

    File.mkdir_p!(Path.dirname(css_path))
    File.mkdir_p!(Path.dirname(js_path))
    File.write!(css_path, @css)
    File.write!(js_path, @js)

    on_exit(fn -> File.rm_rf!(root) end)

    %{root: root, assets: assets, css_path: css_path, js_path: js_path}
  end

  defp install(ctx, opts \\ []) do
    Installer.install(
      Keyword.merge(
        [
          assets_path: ctx.assets,
          css: ctx.css_path,
          js: ctx.js_path,
          replace_ui: true
        ],
        opts
      )
    )
  end

  test "copies the pinned assets and patches the CSS", ctx do
    assert {:ok, _messages} = install(ctx)

    vendor = Path.join(ctx.assets, "vendor/basecoat")
    assert File.exists?(Path.join(vendor, "basecoat.css"))
    assert File.exists?(Path.join(vendor, "basecoat.js"))
    assert File.exists?(Path.join(vendor, "basecoat_live.js"))

    css = File.read!(ctx.css_path)

    assert css =~
             ~s|@import "tailwindcss" source(none);\n@import "../vendor/basecoat/basecoat.css";|

    refute css =~ "daisyui"
    refute css =~ "[data-theme=dark]"
    assert css =~ ~s|@source "../../deps/basecoat_phoenix/lib";|
    assert File.exists?(ctx.css_path <> ".bak")
  end

  test "dark mode uses the html.dark contract", ctx do
    assert {:ok, _} = install(ctx)

    basecoat = File.read!(Path.join(ctx.assets, "vendor/basecoat/basecoat.css"))
    assert basecoat =~ "html.dark"
    refute File.read!(ctx.css_path) =~ "[data-theme=dark]"
  end

  test "running twice produces identical CSS and JS", ctx do
    assert {:ok, _} = install(ctx)
    css = File.read!(ctx.css_path)
    js = File.read!(ctx.js_path)

    assert {:ok, _} = install(ctx)
    assert File.read!(ctx.css_path) == css
    assert File.read!(ctx.js_path) == js
  end

  test "refuses to replace the UI without replace_ui", ctx do
    assert {:error, message} = install(ctx, replace_ui: false)
    assert message =~ "daisyui"
    refute File.exists?(Path.join(ctx.assets, "vendor"))
  end

  test "requires the Tailwind import", ctx do
    File.write!(ctx.css_path, "@theme { --x: 1; }\n")
    assert {:error, message} = install(ctx)
    assert message =~ "tailwindcss"
  end

  test "merges the hooks into the LiveSocket options", ctx do
    assert {:ok, _} = install(ctx)
    js = File.read!(ctx.js_path)

    assert js =~ ~s(import "../vendor/basecoat/basecoat.js";)
    assert js =~ ~s(import {BasecoatHooks} from "../vendor/basecoat/basecoat_live.js";)
    assert js =~ "hooks: {...colocatedHooks, ...BasecoatHooks}"
  end

  test "warns and leaves JS untouched without a csrf token", ctx do
    File.write!(
      ctx.js_path,
      "import \"phoenix_html\"\nconst liveSocket = new LiveSocket(\"/live\")\n"
    )

    assert {:ok, messages} = install(ctx)
    assert Enum.any?(messages, &(&1 =~ "csrfToken"))
    assert File.read!(ctx.js_path) =~ ~s(import "phoenix_html")
  end

  test "dry_run writes nothing", ctx do
    before_css = File.read!(ctx.css_path)
    before_js = File.read!(ctx.js_path)

    assert {:ok, messages} = install(ctx, dry_run: true)
    assert messages != []

    refute File.exists?(Path.join(ctx.assets, "vendor"))
    refute File.exists?(ctx.css_path <> ".bak")
    assert File.read!(ctx.css_path) == before_css
    assert File.read!(ctx.js_path) == before_js
  end
end
