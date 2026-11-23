defmodule BasecoatPhoenix.Components.Trace do
  @moduledoc """
  Basecoat trace: the steps in an agent turn.

  Each item holds one line. With `details`, the line is a `<summary>` and the
  detail slot expands below it; otherwise the line is static, a paragraph, or a
  link (`href`).
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_trace(assigns) do
    ~H"""
    <ol role="list" class={classes(["trace", @class])} aria-label={@label} {@rest}>
      {render_slot(@inner_block)}
    </ol>
    """
  end

  attr(:details, :boolean, default: false)
  attr(:open, :boolean, default: false)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_trace_item(assigns) do
    ~H"""
    <li {@rest}>
      <details :if={@details} open={@open}>{render_slot(@inner_block)}</details>
      <%= if !@details do %>
        {render_slot(@inner_block)}
      <% end %>
    </li>
    """
  end

  attr(:as, :string, default: nil)
  attr(:href, :string, default: nil)
  attr(:meta, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon)
  slot(:inner_block, required: true)

  def bc_trace_line(assigns) do
    assigns = assign(assigns, :tag_name, trace_line_tag(assigns))
    assigns = assign(assigns, :rest, trace_line_rest(assigns.rest, assigns.href))

    ~H"""
    <.dynamic_tag tag_name={@tag_name} class={classes(["trace-line", @class])} {@rest}>
      {render_slot(@icon)}
      <span>{render_slot(@inner_block)}</span>
      <small :if={@meta}>{@meta}</small>
    </.dynamic_tag>
    """
  end

  # A link is the whole line; otherwise the line is a summary or a paragraph.
  defp trace_line_tag(%{href: href}) when is_binary(href), do: "a"
  defp trace_line_tag(%{as: as}) when is_binary(as), do: as
  defp trace_line_tag(_assigns), do: "summary"

  defp trace_line_rest(rest, nil), do: rest
  defp trace_line_rest(rest, href), do: Map.put(rest, :href, href)

  attr(:rest, :global)
  slot(:inner_block, required: true)

  def bc_trace_detail(assigns) do
    ~H"""
    <div {@rest}>{render_slot(@inner_block)}</div>
    """
  end
end
