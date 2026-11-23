defmodule BasecoatPhoenix.Components.OverlaysFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.AlertDialog
  import BasecoatPhoenix.Components.Button
  import BasecoatPhoenix.Components.Drawer
  import BasecoatPhoenix.Components.Sheet
  import BasecoatPhoenix.Components.Popover
  import BasecoatPhoenix.Components.Toast
  import BasecoatPhoenix.Components.Carousel

  def alert_dialog(assigns) do
    ~H"""
    <.bc_alert_dialog_trigger dialog="delete-account">Delete</.bc_alert_dialog_trigger>
    <.bc_alert_dialog
      id="delete-account"
      title="Are you absolutely sure?"
      description="This action cannot be undone."
      size="sm"
    >
      <:footer>
        <.bc_button variant="outline">Cancel</.bc_button>
        <.bc_button variant="destructive">Delete</.bc_button>
      </:footer>
    </.bc_alert_dialog>
    """
  end

  def alert_dialog_media(assigns) do
    ~H"""
    <.bc_alert_dialog id="share-project" title="Share this project?" open>
      <:figure><svg class="lucide lucide-share" aria-hidden="true"></svg></:figure>
      <:footer><.bc_button>Share</.bc_button></:footer>
    </.bc_alert_dialog>
    """
  end

  def drawer(assigns) do
    ~H"""
    <.bc_drawer_trigger dialog="move-goal">Open Drawer</.bc_drawer_trigger>
    <.bc_drawer id="move-goal" side="right" title="Move Goal" description="Set your daily goal.">
      <p>Body</p>
      <:footer>
        <.bc_button>Submit</.bc_button>
      </:footer>
    </.bc_drawer>
    """
  end

  def sheet(assigns) do
    ~H"""
    <.bc_sheet_trigger dialog="edit-profile">Open</.bc_sheet_trigger>
    <.bc_sheet id="edit-profile" title="Edit profile" description="Make changes here.">
      <p>Body</p>
      <:footer>
        <.bc_button>Save changes</.bc_button>
      </:footer>
    </.bc_sheet>
    """
  end

  def popover(assigns) do
    ~H"""
    <.bc_popover id="dimensions">
      <.bc_popover_trigger id="dimensions">Open popover</.bc_popover_trigger>
      <.bc_popover_content id="dimensions" align="center" class="w-72">
        <header>
          <h4>Dimensions</h4>
          <p>Set the dimensions for the layer.</p>
        </header>
      </.bc_popover_content>
    </.bc_popover>
    """
  end

  def toaster(assigns) do
    ~H"""
    <.bc_toaster />
    """
  end

  def toast(assigns) do
    ~H"""
    <.bc_toast
      category="error"
      duration="5000"
      title="Event could not be created"
      description="Try again later."
    >
      <:footer>
        <.bc_button variant="outline" size="sm">Retry</.bc_button>
      </:footer>
    </.bc_toast>
    """
  end

  def carousel(assigns) do
    ~H"""
    <.bc_carousel id="numbered-cards" label="Numbered cards">
      <.bc_carousel_content label="Slides">
        <.bc_carousel_item>1</.bc_carousel_item>
        <.bc_carousel_item>2</.bc_carousel_item>
      </.bc_carousel_content>
      <.bc_carousel_previous />
      <.bc_carousel_next />
    </.bc_carousel>
    """
  end
end

defmodule BasecoatPhoenix.Components.OverlaysTest do
  use BasecoatPhoenix.ComponentCase

  alias BasecoatPhoenix.Components.OverlaysFixture, as: F

  test "bc_alert_dialog renders the header and footer with wired ids" do
    html = render(&F.alert_dialog/1, %{})

    trigger = one(html, "button.btn")
    assert attr(trigger, "type") == "button"
    assert attr(trigger, "data-basecoat-dialog-open") == "delete-account"

    dialog = one(html, "dialog.alert-dialog#delete-account")
    assert attr(dialog, "aria-labelledby") == "delete-account-title"
    assert attr(dialog, "aria-describedby") == "delete-account-description"
    assert attr(dialog, "data-size") == "sm"
    assert attr(dialog, "phx-hook") == "BasecoatState"
    refute attr(dialog, "open")

    header = one(dialog, "div > header")
    assert text(one(header, "h2#delete-account-title")) == "Are you absolutely sure?"
    assert text(one(header, "p#delete-account-description")) == "This action cannot be undone."

    footer = one(dialog, "div > footer")
    assert attr(one(footer, "button"), "data-variant") == "outline"
    assert attr(one(footer, "button[data-variant=destructive]"), "data-variant") == "destructive"
  end

  test "bc_alert_dialog renders an optional figure and the native open attribute" do
    html = render(&F.alert_dialog_media/1, %{})

    dialog = one(html, "dialog.alert-dialog#share-project")
    assert one(dialog, "div > header > figure > svg.lucide-share")
    refute attr(dialog, "aria-describedby")
    assert attr(dialog, "open")
    refute attr(dialog, "data-size")
  end

  test "bc_drawer renders a sided dialog with article sections" do
    html = render(&F.drawer/1, %{})

    assert attr(one(html, "button.btn"), "data-basecoat-dialog-open") == "move-goal"

    dialog = one(html, "dialog.drawer#move-goal")
    assert attr(dialog, "data-side") == "right"
    assert attr(dialog, "phx-hook") == "BasecoatState"

    article = one(dialog, "article")
    assert text(one(article, "header > h2#move-goal-title")) == "Move Goal"
    assert text(one(article, "header > p#move-goal-description")) == "Set your daily goal."
    assert text(one(article, "section")) |> String.trim() == "Body"
    assert text(one(article, "footer")) |> String.trim() == "Submit"
  end

  test "bc_drawer rejects an unknown side" do
    assert_raise ArgumentError, ~r/unknown drawer side/, fn ->
      render_component(&BasecoatPhoenix.Components.Drawer.bc_drawer/1, %{
        id: "bad",
        title: "Bad",
        side: "diagonal"
      })
    end
  end

  test "bc_sheet defaults to the right side" do
    html = render(&F.sheet/1, %{})

    assert attr(one(html, "button.btn"), "data-basecoat-dialog-open") == "edit-profile"

    dialog = one(html, "dialog.sheet#edit-profile")
    assert attr(dialog, "data-side") == "right"
    assert attr(dialog, "phx-hook") == "BasecoatState"
    assert one(dialog, "article > header > h2#edit-profile-title")
    assert one(dialog, "article > section")
    assert one(dialog, "article > footer")
  end

  test "bc_popover renders the wrapper, trigger, and positioned content" do
    html = render(&F.popover/1, %{})

    root = one(html, "div.popover#dimensions")
    assert attr(root, "phx-hook") == "BasecoatState"

    trigger = one(root, "button#dimensions-trigger")
    assert attr(trigger, "type") == "button"
    assert attr(trigger, "aria-expanded") == "false"
    assert attr(trigger, "aria-controls") == "dimensions-popover"

    content = one(root, "div#dimensions-popover[data-popover]")
    assert attr(content, "aria-hidden") == "true"
    assert attr(content, "data-align") == "center"
    assert classes(content) == ["w-72"]
    assert text(one(content, "header > h4")) == "Dimensions"
  end

  test "bc_toaster renders the fixed toaster container" do
    html = render(&F.toaster/1, %{})

    toaster = one(html, "ol#toaster.toaster")
    assert attr(toaster, "role") == "list"
    assert attr(toaster, "aria-label") == "Notifications"
    assert attr(toaster, "phx-update") == "ignore"
    refute attr(toaster, "phx-hook")
  end

  test "bc_toast renders an error toast with alert role and footer actions" do
    html = render(&F.toast/1, %{})

    toast = one(html, "li.toast")
    assert attr(toast, "data-category") == "error"
    assert attr(toast, "data-duration") == "5000"

    content = one(toast, "div.toast-content")
    assert attr(content, "role") == "alert"
    assert attr(content, "aria-atomic") == "true"

    section = one(content, "section")
    assert text(one(section, "h2")) == "Event could not be created"
    assert text(one(section, "p")) == "Try again later."

    footer = one(content, "footer")
    assert attr(one(footer, "button"), "data-size") == "sm"
    assert one(footer, "button[aria-label='Close toast']")
  end

  test "bc_toast uses status role for non-error categories and omits empty attrs" do
    html =
      render_component(&BasecoatPhoenix.Components.Toast.bc_toast/1, %{
        title: "Event created",
        close_button: false
      })
      |> Floki.parse_fragment!()

    toast = one(html, "li.toast")
    refute attr(toast, "data-category")
    refute attr(toast, "data-duration")

    content = one(toast, "div.toast-content")
    assert attr(content, "role") == "status"
    refute one(content, "footer button[aria-label='Close toast']")
  end

  test "bc_carousel renders the region, scroll list, slides, and hidden buttons" do
    html = render(&F.carousel/1, %{})

    root = one(html, "div.carousel#numbered-cards")
    assert attr(root, "role") == "region"
    assert attr(root, "aria-roledescription") == "carousel"
    assert attr(root, "aria-label") == "Numbered cards"
    assert attr(root, "phx-hook") == "BasecoatState"

    list = one(root, "ul")
    assert attr(list, "role") == "list"
    assert attr(list, "tabindex") == "0"
    assert attr(list, "aria-label") == "Slides"
    assert classes(list) == ["scrollbar"]

    assert length(Floki.find(list, "li")) == 2

    previous = one(root, "button[aria-label='Previous slide']")
    assert attr(previous, "data-size") == "icon-sm"
    assert attr(previous, "hidden")

    next = one(root, "button[aria-label='Next slide']")
    assert attr(next, "hidden")
    assert one(next, "svg")
  end
end
