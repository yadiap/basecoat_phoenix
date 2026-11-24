defmodule BasecoatPhoenix.LiveJsTest do
  use ExUnit.Case, async: true

  setup do
    path = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat", "basecoat_live.js"])
    %{js: File.read!(path)}
  end

  test "exports the two hooks", %{js: js} do
    assert js =~ "export const BasecoatHooks"
    assert js =~ "BasecoatState"
    assert js =~ "BasecoatChart"
    refute js =~ "BasecoatRange"
    refute js =~ "BasecoatToaster"
  end

  test "wires Basecoat actions and the toast window listener", %{js: js} do
    for marker <-
          ~w(data-basecoat-dialog-open data-basecoat-dialog-close data-basecoat-drawer-open data-basecoat-drawer-close data-basecoat-sidebar-toggle data-basecoat-theme-toggle phx:basecoat_toast basecoat:toast),
        do: assert(js =~ marker)

    assert js =~ ~s{window.addEventListener("phx:basecoat_toast"}
  end

  test "refreshes server-driven components with the registry API", %{js: js} do
    assert js =~ "window.basecoat"
    assert js =~ "refresh"
    refute js =~ "childSignature"
    refute js =~ "data-basecoat-state"
  end

  test "switches and persists skins", %{js: js} do
    assert js =~ "data-basecoat-skin"
    assert js =~ ~s|localStorage.getItem(SKIN_KEY)|
    assert js =~ ~s|localStorage.setItem(SKIN_KEY|
    assert js =~ ~s|const SKIN_KEY = "themeSkin"|
    assert js =~ "basecoat:skinchange"
    assert js =~ "window.basecoat.skin"
    assert js =~ "aria-checked"
    assert js =~ "delete document.documentElement.dataset.skin"
  end

  test "syncs skin state only on ARIA roles that allow it", %{js: js} do
    assert js =~ "menuitemradio"
    assert js =~ "aria-disabled"
    assert js =~ "attachSkinApi"
    assert length(String.split(js, "syncSkinItems();")) >= 4
    assert js =~ ~s|applyStoredSkin();\n  syncSkinItems();|
  end
end
