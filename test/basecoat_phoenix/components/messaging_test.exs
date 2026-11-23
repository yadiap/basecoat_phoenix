defmodule BasecoatPhoenix.Components.MessagingFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Alert
  import BasecoatPhoenix.Components.Bubble
  import BasecoatPhoenix.Components.Message
  import BasecoatPhoenix.Components.Marker
  import BasecoatPhoenix.Components.Attachment
  import BasecoatPhoenix.Components.Trace
  import BasecoatPhoenix.Components.Avatar

  def alert(assigns) do
    ~H"""
    <.bc_alert>
      <:icon>
        <svg class="lucide lucide-circle-check" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" /><path d="m9 12 2 2 4-4" /></svg>
      </:icon>
      <.bc_alert_title>Payment successful</.bc_alert_title>
      <.bc_alert_description>Your payment has been processed.</.bc_alert_description>
    </.bc_alert>
    """
  end

  def alert_destructive(assigns) do
    ~H"""
    <.bc_alert variant="destructive">
      <.bc_alert_title>Payment failed</.bc_alert_title>
      <.bc_alert_description>Please try again.</.bc_alert_description>
      <.bc_alert_actions>Retry</.bc_alert_actions>
    </.bc_alert>
    """
  end

  def bubble(assigns) do
    ~H"""
    <.bc_bubble align="end">
      <p>Hey there! what's up?</p>
      <:reactions label="Reaction: thumbs up"><span>👍</span></:reactions>
    </.bc_bubble>
    """
  end

  def bubble_group(assigns) do
    ~H"""
    <.bc_bubble_group label="Conversation">
      <.bc_bubble>
        <p>First</p>
      </.bc_bubble>
      <.bc_bubble variant="muted">
        <p>Second</p>
      </.bc_bubble>
    </.bc_bubble_group>
    """
  end

  def message_group(assigns) do
    ~H"""
    <.bc_message_group label="Conversation">
      <.bc_message align="end">
        <.bc_avatar aria-hidden="true">
          <.bc_avatar_image src="/avatar-1.png" alt="" />
        </.bc_avatar>
        <div>
          <span class="sr-only">You</span>
          <.bc_bubble>
            <p>Deploying to prod real quick.</p>
          </.bc_bubble>
        </div>
      </.bc_message>
      <.bc_message>
        <.bc_avatar aria-hidden="true">
          <.bc_avatar_image src="/avatar-2.png" alt="" />
        </.bc_avatar>
        <div>
          <span class="sr-only">Oliver</span>
          <.bc_bubble variant="muted">
            <p>It's 4:55 PM. On a Friday.</p>
          </.bc_bubble>
        </div>
      </.bc_message>
    </.bc_message_group>
    """
  end

  def message_standalone(assigns) do
    ~H"""
    <.bc_message as="div">
      <div>
        <span class="sr-only">Oliver</span>
        <.bc_bubble variant="muted">
          <p>Standalone</p>
        </.bc_bubble>
      </div>
    </.bc_message>
    """
  end

  def marker(assigns) do
    ~H"""
    <.bc_marker role="status" shimmer>
      <:icon>
        <svg aria-hidden="true" class="animate-spin motion-reduce:animate-none" viewBox="0 0 24 24"><path d="M21 12a9 9 0 1 1-6.219-8.56" /></svg>
      </:icon>
      Thinking...
    </.bc_marker>
    """
  end

  def marker_separator(assigns) do
    ~H"""
    <.bc_marker variant="separator">Conversation compacted</.bc_marker>
    """
  end

  def attachment_group(assigns) do
    ~H"""
    <ul class="attachment-group" role="list" aria-label="Attached files">
      <.bc_attachment as="li" orientation="vertical">
        <.bc_attachment_media>
          <img src="/workspace.png" alt="Workspace" />
        </.bc_attachment_media>
        <.bc_attachment_content>
          <.bc_attachment_title>workspace.png</.bc_attachment_title>
          <.bc_attachment_description>PNG · 820 KB</.bc_attachment_description>
        </.bc_attachment_content>
      </.bc_attachment>
    </ul>
    """
  end

  def attachment_full(assigns) do
    ~H"""
    <.bc_attachment state="uploading">
      <.bc_attachment_media aria-hidden="true">Icon</.bc_attachment_media>
      <.bc_attachment_content>
        <.bc_attachment_title>sales-dashboard.pdf</.bc_attachment_title>
        <.bc_attachment_description>Uploading · 64%</.bc_attachment_description>
      </.bc_attachment_content>
      <a href="/sales-dashboard.pdf" aria-label="Open sales-dashboard.pdf"></a>
      <.bc_attachment_actions>Cancel</.bc_attachment_actions>
    </.bc_attachment>
    """
  end

  def trace(assigns) do
    ~H"""
    <.bc_trace label="Activity">
      <.bc_trace_item details open>
        <.bc_trace_line>
          <:icon>
            <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" /><path d="m9 12 2 2 4-4" /></svg>
          </:icon>
          Thought for 5s
        </.bc_trace_line>
        <.bc_trace_detail>Compared the manifest and lockfile.</.bc_trace_detail>
      </.bc_trace_item>
      <.bc_trace_item details>
        <.bc_trace_line meta="14s">
          <:icon>
            <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 19h8" /><path d="m4 17 6-6-6-6" /></svg>
          </:icon>
          Ran pnpm test
        </.bc_trace_line>
        <.bc_trace_detail>All green.</.bc_trace_detail>
      </.bc_trace_item>
      <.bc_trace_item>
        <.bc_trace_line as="p">Created branch fix/frozen-lockfile</.bc_trace_line>
      </.bc_trace_item>
    </.bc_trace>
    """
  end
end

defmodule BasecoatPhoenix.Components.MessagingTest do
  use BasecoatPhoenix.ComponentCase

  test "bc_alert renders the icon, title, and description as direct children" do
    assert_markup(&BasecoatPhoenix.Components.MessagingFixture.alert/1, %{}, ~S"""
    <div class="alert">
      <svg class="lucide lucide-circle-check" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="m9 12 2 2 4-4"></path></svg>
      <h2>Payment successful</h2>
      <section>Your payment has been processed.</section>
    </div>
    """)
  end

  test "bc_alert marks a destructive variant and has no alert-title class" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.alert_destructive/1, %{})

    root = one(html, "div.alert")
    assert attr(root, "data-variant") == "destructive"
    assert classes(root) == ["alert"]
    assert text(one(root, "footer")) == "Retry"
  end

  test "bc_bubble renders content first and reactions as a direct role=img child" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.bubble/1, %{})

    root = one(html, "div.bubble")
    assert attr(root, "data-align") == "end"
    assert classes(root) == ["bubble"]

    children = Floki.children(root)
    assert elem(hd(children), 0) == "p"

    reactions = one(root, "div[role=img]")
    assert attr(reactions, "aria-label") == "Reaction: thumbs up"
    assert text(one(reactions, "span")) == "👍"
  end

  test "bc_bubble_group renders the upstream group container" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.bubble_group/1, %{})

    root = one(html, "div.bubble-group")
    assert attr(root, "aria-label") == "Conversation"
    assert length(Floki.find(root, "div.bubble")) == 2
    assert attr(one(root, "div.bubble[data-variant=muted]"), "data-variant") == "muted"
  end

  test "bc_message_group renders an ordered list of li.message rows" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.message_group/1, %{})

    root = one(html, "ol")
    assert attr(root, "role") == "list"
    assert attr(root, "aria-label") == "Conversation"

    rows = Floki.find(root, "li.message")
    assert length(rows) == 2
    assert attr(Enum.at(rows, 0), "data-align") == "end"
    assert attr(Enum.at(rows, 1), "data-align") == nil

    assert one(html, "li.message > span.avatar > img")
    assert text(one(html, "li.message span.sr-only")) == "You"
    assert one(html, "li.message div > div.bubble")
    refute one(html, "div.message-content")
  end

  test "bc_message renders a div when asked and has no message-content class" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.message_standalone/1, %{})

    root = one(html, "div.message")
    assert root
    assert classes(root) == ["message"]
  end

  test "bc_marker renders the icon before a shimmer span" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.marker/1, %{})

    root = one(html, "div.marker")
    assert attr(root, "role") == "status"

    children = Floki.children(root)
    assert elem(hd(children), 0) == "svg"

    span = one(root, "span")
    assert classes(span) == ["shimmer"]
    assert text(span) |> String.trim() == "Thinking..."
  end

  test "bc_marker renders a separator variant" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.marker_separator/1, %{})

    root = one(html, "div.marker")
    assert attr(root, "data-variant") == "separator"
    assert text(one(root, "span")) |> String.trim() == "Conversation compacted"
  end

  test "bc_attachment renders a list item with media, content, and no attachment-content class" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.attachment_group/1, %{})

    root = one(html, "ul.attachment-group > li.attachment")
    assert attr(root, "data-orientation") == "vertical"

    assert one(root, "figure > img")
    assert text(one(root, "section > p")) == "workspace.png"
    assert attr(one(root, "section > p"), "dir") == "auto"
    refute one(root, "[class*=attachment-content]")
  end

  test "bc_attachment renders a full-card trigger and a final actions div" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.attachment_full/1, %{})

    root = one(html, "div.attachment")
    assert attr(root, "data-state") == "uploading"

    link = one(root, "a")
    assert attr(link, "href") == "/sales-dashboard.pdf"
    assert attr(link, "aria-label") == "Open sales-dashboard.pdf"

    assert text(one(root, "a + div")) == "Cancel"
  end

  test "bc_trace renders the upstream list, details, line, and detail markup" do
    html = render(&BasecoatPhoenix.Components.MessagingFixture.trace/1, %{})

    root = one(html, "ol.trace")
    assert attr(root, "role") == "list"
    assert attr(root, "aria-label") == "Activity"

    items = Floki.find(root, "li")
    assert length(items) == 3

    details = one(Enum.at(items, 0), "details")
    assert attr(details, "open")

    summary = one(details, "summary.trace-line")
    assert elem(hd(Floki.children(summary)), 0) == "svg"
    assert text(one(summary, "span")) |> String.trim() == "Thought for 5s"
    assert text(one(details, "summary + div")) == "Compared the manifest and lockfile."

    second = one(Enum.at(items, 1), "summary.trace-line")
    assert text(one(second, "small")) |> String.trim() == "14s"

    third = one(Enum.at(items, 2), "p.trace-line")
    assert third
    assert text(one(third, "span")) |> String.trim() == "Created branch fix/frozen-lockfile"
  end
end
