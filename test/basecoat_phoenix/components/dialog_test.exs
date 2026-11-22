defmodule BasecoatPhoenix.Components.DialogTest do
  use BasecoatPhoenix.ComponentCase
  alias BasecoatPhoenix.Components.Dialog

  defp dialog(overrides \\ %{}) do
    Map.merge(
      %{
        id: "edit-profile",
        title: "Edit profile",
        description: "Make changes to your profile.",
        inner_block: [%{inner_block: fn _, _ -> "Body" end}],
        footer: [%{inner_block: fn _, _ -> "Footer" end}]
      },
      overrides
    )
  end

  test "bc_dialog renders the upstream dialog structure" do
    html = render(&Dialog.bc_dialog/1, dialog())

    root = one(html, "dialog.dialog")
    assert attr(root, "id") == "edit-profile"
    assert attr(root, "aria-labelledby") == "edit-profile-title"
    assert attr(root, "aria-describedby") == "edit-profile-description"
    assert attr(root, "phx-hook") == "BasecoatState"

    assert attr(one(root, "header > h2"), "id") == "edit-profile-title"
    assert text(one(root, "header > h2")) == "Edit profile"
    assert attr(one(root, "header > p"), "id") == "edit-profile-description"
    assert text(one(root, "section")) |> String.trim() == "Body"
    assert text(one(root, "footer")) |> String.trim() == "Footer"

    close = one(root, "button[data-basecoat-dialog-close]")
    assert attr(close, "type") == "button"
    assert attr(close, "data-variant") == "ghost"
    assert attr(close, "data-size") == "icon-sm"
    assert attr(close, "aria-label") == "Close dialog"
  end

  test "bc_dialog renders the native open attribute only when open" do
    closed = render(&Dialog.bc_dialog/1, dialog())
    refute attr(one(closed, "dialog"), "open")

    open = render(&Dialog.bc_dialog/1, dialog(%{open: true}))
    assert attr(one(open, "dialog"), "open")
  end

  test "bc_dialog omits the description wiring when there is none" do
    html = render(&Dialog.bc_dialog/1, dialog(%{description: nil}))

    root = one(html, "dialog.dialog")
    refute attr(root, "aria-describedby")
    assert one(root, "header > p") == nil
  end

  test "bc_dialog_trigger opens the dialog" do
    html =
      render(&Dialog.bc_dialog_trigger/1, %{
        dialog: "edit-profile",
        inner_block: [%{inner_block: fn _, _ -> "Edit" end}]
      })

    button = one(html, "button.btn")
    assert attr(button, "type") == "button"
    assert attr(button, "data-variant") == "outline"
    assert attr(button, "data-basecoat-dialog-open") == "edit-profile"
    assert text(button) == "Edit"
  end
end
