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

  @core_components """
  defmodule MyAppWeb.CoreComponents do
    @moduledoc "Provides core UI components."

    use Gettext, backend: MyAppWeb.Gettext

    attr :type, :string, default: nil
    def button(assigns), do: ~H"<button>{@type}</button>"
  end
  """

  setup do
    root = Path.join(System.tmp_dir!(), "bc_installer_#{System.unique_integer([:positive])}")
    css_path = Path.join(root, "assets/css/app.css")
    js_path = Path.join(root, "assets/js/app.js")
    core_path = Path.join(root, "lib/my_app_web/components/core_components.ex")
    assets = Path.join(root, "assets")

    File.mkdir_p!(Path.dirname(css_path))
    File.mkdir_p!(Path.dirname(js_path))
    File.mkdir_p!(Path.dirname(core_path))
    File.write!(css_path, @css)
    File.write!(js_path, @js)
    File.write!(core_path, @core_components)

    on_exit(fn -> File.rm_rf!(root) end)

    %{root: root, assets: assets, css_path: css_path, js_path: js_path, core_path: core_path}
  end

  defp install(ctx, opts \\ []) do
    Installer.install(
      Keyword.merge(
        [
          root: ctx.root,
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
    refute File.exists?(ctx.core_path <> ".bak")
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

  test "replaces core_components with the BasecoatPhoenix drop-in", ctx do
    assert {:ok, _messages} = install(ctx)

    content = File.read!(ctx.core_path)

    assert content == """
           defmodule MyAppWeb.CoreComponents do
             @moduledoc \"\"\"
             Basecoat-backed core components. See `BasecoatPhoenix.CoreComponents`.
             \"\"\"

             use BasecoatPhoenix.CoreComponents, gettext_backend: MyAppWeb.Gettext
           end
           """

    assert File.read!(ctx.core_path <> ".bak") == @core_components
  end

  test "omits the gettext backend when the generated module has none", ctx do
    File.write!(ctx.core_path, """
    defmodule MyAppWeb.CoreComponents do
      def button(assigns), do: ~H"<button></button>"
    end
    """)

    assert {:ok, _} = install(ctx)
    content = File.read!(ctx.core_path)

    assert content =~ "use BasecoatPhoenix.CoreComponents\n"
    refute content =~ "gettext_backend"
  end

  test "keeps an already migrated core_components", ctx do
    migrated = """
    defmodule MyAppWeb.CoreComponents do
      use BasecoatPhoenix.CoreComponents, gettext_backend: MyAppWeb.Gettext
    end
    """

    File.write!(ctx.core_path, migrated)

    assert {:ok, messages} = install(ctx)
    assert Enum.any?(messages, &(&1 =~ "kept: #{ctx.core_path}"))
    assert File.read!(ctx.core_path) == migrated
    refute File.exists?(ctx.core_path <> ".bak")
  end

  test "replaces core_components even when the CSS is already clean", ctx do
    File.write!(ctx.css_path, ~s|@import "tailwindcss" source(none);\n|)

    assert {:ok, _} = install(ctx)
    assert File.read!(ctx.core_path) =~ "use BasecoatPhoenix.CoreComponents"
  end

  test "honours the core_components path override", ctx do
    custom = Path.join(ctx.root, "lib/custom/core_components.ex")
    File.mkdir_p!(Path.dirname(custom))
    File.write!(custom, @core_components)

    assert {:ok, _} = install(ctx, core_components: "lib/custom/core_components.ex")

    assert File.read!(custom) =~ "use BasecoatPhoenix.CoreComponents"
    assert File.read!(ctx.core_path) == @core_components
  end

  test "warns when core_components is missing", ctx do
    File.rm!(ctx.core_path)

    assert {:ok, messages} = install(ctx)
    assert Enum.any?(messages, &(&1 =~ "CoreComponents was left untouched"))
  end

  test "dry_run writes nothing", ctx do
    before_css = File.read!(ctx.css_path)
    before_js = File.read!(ctx.js_path)
    before_core = File.read!(ctx.core_path)

    assert {:ok, messages} = install(ctx, dry_run: true)
    assert messages != []

    refute File.exists?(Path.join(ctx.assets, "vendor"))
    refute File.exists?(ctx.css_path <> ".bak")
    refute File.exists?(ctx.core_path <> ".bak")
    assert File.read!(ctx.css_path) == before_css
    assert File.read!(ctx.js_path) == before_js
    assert File.read!(ctx.core_path) == before_core
  end
end
