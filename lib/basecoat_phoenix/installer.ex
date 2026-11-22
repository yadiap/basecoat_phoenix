defmodule BasecoatPhoenix.Installer do
  @moduledoc """
  Copies the pinned Basecoat assets into a Phoenix project and patches
  `assets/css/app.css` and `assets/js/app.js`.

  Returns `{:ok, messages}` with written paths and warnings, or `{:error, msg}`
  when the project does not look like a Phoenix 1.8 app or still needs the
  explicit `replace_ui: true` opt-in.
  """

  alias BasecoatPhoenix.Installer.CSS

  @daisy_plugin_prefix ~s(@plugin "daisyui/)
  @daisy_dark_variant "@custom-variant dark (&:where([data-theme=dark]"
  @dark_variant_line "@custom-variant dark"
  @tailwind_import ~s(@import "tailwindcss")
  @hooks_needle "hooks: {...colocatedHooks}"
  @hooks_merged "hooks: {...colocatedHooks, ...BasecoatHooks}"
  @csrf_anchor "const csrfToken"

  @spec install(keyword()) :: {:ok, [String.t()]} | {:error, String.t()}
  def install(opts \\ []) do
    root = opts[:root] || File.cwd!()
    assets = Path.expand(opts[:assets_path] || "assets", root)
    css_path = Path.expand(opts[:css] || "assets/css/app.css", root)
    js_path = Path.expand(opts[:js] || "assets/js/app.js", root)
    style = opts[:style] || "vega"
    source_path = opts[:source_path] || "../../deps/basecoat_phoenix/lib"
    dry_run = !!opts[:dry_run]

    with {:ok, css} <- read(css_path),
         :ok <- check_tailwind(css, css_path),
         {:ok, css, destructive?} <- replace_ui(css, opts[:replace_ui]),
         {:ok, js} <- read(js_path) do
      build(assets, css_path, js_path, style, source_path, opts, css, js, dry_run, destructive?)
    end
  end

  defp build(assets, css_path, js_path, style, source_path, opts, css, js, dry_run, destructive?) do
    vendor = Path.join(assets, "vendor/basecoat")
    css_dir = Path.dirname(css_path)
    js_dir = Path.dirname(js_path)

    basecoat_css = relative(Path.join(vendor, "basecoat.css"), css_dir)
    basecoat_js = relative(Path.join(vendor, "basecoat.js"), js_dir)
    live_js = relative(Path.join(vendor, "basecoat_live.js"), js_dir)

    css =
      css
      |> CSS.insert_after(@tailwind_import, ~s(@import "#{basecoat_css}";))
      |> append_once(~s(@source "#{source_path}";))
      |> maybe_typeset(opts, vendor, css_dir, basecoat_css)

    {js, warnings} = patch_js(js, opts, vendor, js_dir, basecoat_js, live_js)

    messages = []

    messages =
      if destructive? and not File.exists?(css_path <> ".bak") do
        unless dry_run, do: File.cp!(css_path, css_path <> ".bak")
        ["backup: #{css_path}.bak" | messages]
      else
        messages
      end

    messages = maybe_write(messages, css_path, css, dry_run)
    messages = maybe_write(messages, js_path, js, dry_run)

    messages =
      Enum.reduce(copies(style, opts, vendor), messages, fn {source, target}, acc ->
        copy_asset(source, target, acc, dry_run)
      end)

    {:ok, warnings ++ Enum.reverse(messages)}
  end

  defp copies(style, opts, vendor) do
    priv = to_string(:code.priv_dir(:basecoat_phoenix)) |> Path.join("basecoat")

    [
      {Path.join(priv, "basecoat-#{style}.bundle.css"), Path.join(vendor, "basecoat.css")},
      {Path.join(priv, "all.min.js"), Path.join(vendor, "basecoat.js")},
      {Path.join(priv, "basecoat_live.js"), Path.join(vendor, "basecoat_live.js")}
    ] ++
      if(opts[:typeset],
        do: [{Path.join(priv, "typeset.css"), Path.join(vendor, "typeset.css")}],
        else: []
      ) ++
      if(opts[:chart],
        do: [{Path.join(priv, "chart.min.js"), Path.join(vendor, "chart.js")}],
        else: []
      )
  end

  defp copy_asset(source, target, messages, dry_run) do
    unless dry_run do
      File.mkdir_p!(Path.dirname(target))
      File.cp!(source, target)
    end

    ["wrote: #{target}" | messages]
  end

  defp maybe_write(messages, path, content, dry_run) do
    unless dry_run, do: File.write!(path, content)
    ["wrote: #{path}" | messages]
  end

  defp maybe_typeset(css, opts, vendor, css_dir, basecoat_css) do
    if opts[:typeset] do
      typeset = relative(Path.join(vendor, "typeset.css"), css_dir)
      CSS.insert_after(css, ~s(@import "#{basecoat_css}";), ~s(@import "#{typeset}";))
    else
      css
    end
  end

  defp patch_js(js, opts, vendor, js_dir, basecoat_js, live_js) do
    cond do
      not String.contains?(js, @csrf_anchor) ->
        {js,
         [
           "warning: could not find `const csrfToken` in app.js, so it was left untouched. " <>
             "Add the Basecoat imports and spread BasecoatHooks into your LiveSocket hooks manually."
         ]}

      not String.contains?(js, @hooks_needle) and not String.contains?(js, @hooks_merged) ->
        {js,
         [
           "warning: could not find `#{@hooks_needle}` in app.js, so it was left untouched. " <>
             "Spread BasecoatHooks into your LiveSocket hooks manually."
         ]}

      true ->
        chart_import =
          if opts[:chart] do
            chart = relative(Path.join(vendor, "chart.js"), js_dir)
            [~s|import "#{chart}";|]
          else
            []
          end

        imports =
          [~s|import "#{basecoat_js}";|] ++
            chart_import ++ [~s|import {BasecoatHooks} from "#{live_js}";|]

        js =
          if String.contains?(js, "BasecoatHooks") do
            js
          else
            insert_before(js, @csrf_anchor, imports)
          end

        {String.replace(js, @hooks_needle, @hooks_merged), []}
    end
  end

  defp insert_before(text, anchor, lines) do
    split = String.split(text, "\n")

    case Enum.find_index(split, &String.starts_with?(String.trim_leading(&1), anchor)) do
      nil -> text
      index -> split |> List.insert_at(index, lines) |> List.flatten() |> Enum.join("\n")
    end
  end

  defp append_once(css, line) do
    if css |> String.split("\n") |> Enum.any?(&(String.trim_leading(&1) == line)) do
      css
    else
      String.trim_trailing(css) <> "\n" <> line <> "\n"
    end
  end

  defp check_tailwind(css, path) do
    if css
       |> String.split("\n")
       |> Enum.any?(&String.starts_with?(String.trim_leading(&1), @tailwind_import)) do
      :ok
    else
      {:error,
       "#{path} does not import Tailwind. Expected a line starting with `#{@tailwind_import}` " <>
         "(Phoenix 1.8 generates `@import \"tailwindcss\" source(none);`)."}
    end
  end

  defp replace_ui(css, true) do
    stripped =
      css
      |> remove_all("daisyui/packages/bundle/daisyui-theme")
      |> remove_all("daisyui/packages/bundle/daisyui")
      |> remove_dark_variant()

    {:ok, stripped, stripped != css}
  end

  defp replace_ui(css, _) do
    if String.contains?(css, @daisy_plugin_prefix) or String.contains?(css, @daisy_dark_variant) do
      {:error,
       "app.css still configures daisyUI (`@plugin \"daisyui/...\"`) or the `[data-theme=dark]` variant. " <>
         "Pass --replace-ui to remove every daisyUI plugin block and the dark variant. " <>
         "Basecoat dark mode uses the `html.dark` class instead."}
    else
      {:ok, css, false}
    end
  end

  defp remove_all(css, name) do
    next = CSS.remove_plugin_block(css, name)
    if next == css, do: css, else: remove_all(next, name)
  end

  defp remove_dark_variant(css) do
    css
    |> String.split("\n")
    |> Enum.reject(&String.starts_with?(String.trim_leading(&1), @dark_variant_line))
    |> Enum.join("\n")
  end

  defp read(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, "could not read #{path}: #{:file.format_error(reason)}"}
    end
  end

  # `Path.relative_to/2` only strips a common prefix; it never adds `..`.
  defp relative(target, from_dir) do
    target = Path.expand(target)
    from_dir = Path.expand(from_dir)

    {target_rest, from_rest} = drop_common(Path.split(target), Path.split(from_dir))

    (Enum.map(from_rest, fn _ -> ".." end) ++ target_rest) |> Path.join()
  end

  defp drop_common([same | a], [same | b]), do: drop_common(a, b)
  defp drop_common(a, b), do: {a, b}
end
