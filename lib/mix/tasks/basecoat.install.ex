defmodule Mix.Tasks.Basecoat.Install do
  use Mix.Task

  @shortdoc "Copies Basecoat assets and patches app.css/app.js"

  @moduledoc """
  Installs Basecoat into a Phoenix 1.8 project.

      mix basecoat.install --replace-ui

  Options:

    * `--replace-ui` - remove the daisyUI plugin blocks and the
      `[data-theme=dark]` variant from `app.css` (required when they exist),
      and replace the generated `core_components.ex` with the
      `BasecoatPhoenix.CoreComponents` drop-in
    * `--style` - style pack: vega (default), nova, maia, lyra, mira, luma,
      sera, rhea
    * `--typeset` - also copy `typeset.css` and import it
    * `--chart` - also copy Chart.js and import it
    * `--dry-run` - report the changes without writing anything
    * `--core-components` - path to `core_components.ex` (defaults to
      `lib/*_web/components/core_components.ex`)
    * `--assets-path`, `--css`, `--js`, `--source-path` - override the default
      paths
  """

  @switches [
    replace_ui: :boolean,
    dry_run: :boolean,
    typeset: :boolean,
    chart: :boolean,
    style: :string,
    assets_path: :string,
    css: :string,
    js: :string,
    source_path: :string,
    core_components: :string
  ]

  @impl Mix.Task
  def run(args) do
    {opts, _argv} = OptionParser.parse!(args, strict: @switches)

    case BasecoatPhoenix.Installer.install(opts) do
      {:ok, messages} ->
        Enum.each(messages, fn message -> Mix.shell().info(message) end)

      {:error, message} ->
        Mix.raise(message)
    end
  end
end
