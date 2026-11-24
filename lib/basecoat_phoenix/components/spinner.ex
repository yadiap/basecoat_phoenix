defmodule BasecoatPhoenix.Components.Spinner do
  @moduledoc """
  Convenience spinner. Basecoat documents no Spinner component; this renders
  the upstream `loader-circle` SVG markup as-is.

  `label` is visible text placed after the spinner. Without it the SVG keeps
  `aria-label="Loading"`, exactly as upstream.
  """
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  attr(:label, :string, default: nil, doc: "visible text next to the spinner")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def bc_spinner(%{label: label} = assigns) when is_binary(label) and label != "" do
    ~H"""
    <span role="status" class="inline-flex items-center gap-2">
      <svg
        aria-hidden="true"
        class={classes(["animate-spin lucide lucide-loader-circle", @class])}
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        {@rest}
      >
        <path d="M21 12a9 9 0 1 1-6.219-8.56" />
      </svg>
      <span>{@label}</span>
    </span>
    """
  end

  def bc_spinner(assigns) do
    ~H"""
    <svg
      aria-label="Loading"
      role="status"
      class={classes(["animate-spin lucide lucide-loader-circle", @class])}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      {@rest}
    >
      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
    </svg>
    """
  end
end
