# Basecoat Phoenix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `basecoat_phoenix`, a standalone Elixir library that renders Basecoat 1.2.1 markup as `bc_*` Phoenix function components and wires Basecoat CSS/JS into a Phoenix 1.8 LiveView app with one installer task.

**Architecture:** One module per component under `BasecoatPhoenix.Components.*`; an umbrella `use BasecoatPhoenix.Components` imports all of them. Basecoat's vendored JS owns client state. A library-owned `BasecoatState` hook preserves that state across LiveView patches. A `mix basecoat.install` task copies pinned assets and patches `app.css`/`app.js`.

**Tech Stack:** Elixir 1.15+, Phoenix LiveView 1.2, phoenix_html 4, Jason, Floki (test only), Basecoat 1.2.1, Tailwind 4.3.

**Spec:** `docs/superpowers/specs/2026-11-21-basecoat-phoenix-design.md`

## Global Constraints

- Elixir `~> 1.15`; Phoenix `~> 1.8`; `phoenix_live_view ~> 1.2`; `phoenix_html ~> 4.0`; Tailwind CSS 4.3+.
- Basecoat pinned at **1.2.1**. All upstream files are vendored under `priv/basecoat/`; installation never needs the network.
- 51 upstream components plus one convenience helper (`bc_spinner`). Five upstream pages are patterns only: Direction, Aspect Ratio, Scroll Area, Data Table, Tooltip. Do not create components for them.
- Every component renders upstream tags, nesting, classes, `role`, `aria-*`, and `data-*` exactly. The only allowed additions: `phx-hook`, stable `id`s, `data-basecoat-dialog-open|close`, `data-basecoat-drawer-open|close`, `data-basecoat-sidebar-toggle`, `data-basecoat-theme-toggle`, and LiveView attributes in `{@rest}`.
- No inline `onclick` or other inline handlers in library output.
- Every component accepts `attr :class, :string` and `attr :rest, :global`. Class-bearing roots merge `["base-class", @class]`; class-less semantic subcomponents pass `@class` through.
- Variants/sizes render `data-variant`/`data-size` only when not the upstream default. Default values omit the attribute.
- Linked ARIA ids are deterministic and caller-supplied. Never generate ids at render time.
- Installer must be idempotent, must back up `app.css` before destructive edits, and must never corrupt a hand-edited file.
- `basecoat.js` from upstream is runtime only. Vendor and copy `all.min.js` instead.
- Component tests assert the upstream markup contract with `assert_markup/3` (normalized tree comparison). Plain assertions are kept only for things a tree cannot express: default-attribute omission, tag switching on `href`, and encoded hidden-input values.
- A subcomponent that is one tag plus an optional class plus a slot is declared with `BasecoatPhoenix.Components.Semantic.defsemantic/3` from Task 6. Do not hand-write those bodies.
- Each component task appends its controller's manual check to `docs/manual-verification.md` and verifies it in the Task 6 browser app before committing.

## Review Focus

These are the failure modes most likely to bite a real app. Each gets a test or a manual check in the task named.

1. **LiveView patch wipes Basecoat state.** Dropdown open, tab selected, dialog open, select value, and initialized markers must survive an unrelated assign update. Owning task: 4, plus the manual checklist from 6.
2. **Installer meets a real Phoenix 1.8 `app.css`/`app.js`.** daisyUI blocks, the `[data-theme=dark]` variant, hand edits, and a second run must not duplicate or corrupt anything. Owning task: 5.
3. **Nested LiveView toast reaches the root layout.** A child LiveView `push_event` must reach the single `#toaster` in the root layout. Owning task: 4 (window listener), manual check in 13.
4. **Server changes select/combobox options or value.** The hidden input, trigger label, and visual selection must refresh after a patch. Owning task: 4 (`window.basecoat.refresh`) plus component tests in 8.
5. **Malformed form input.** Empty, malformed JSON, object-format maps, and `field={@form[:x]}` errors must not crash. Owning tasks: 3, 6, 8.

---

### Task 1: Project Skeleton and Test Harness

**Files:**
- Create: `mix.exs`
- Create: `.formatter.exs`
- Create: `.gitignore`
- Create: `lib/basecoat_phoenix.ex`
- Create: `test/test_helper.exs`
- Create: `test/support/component_case.ex`
- Create: `test/basecoat_phoenix/smoke_test.exs`
- Create: `LICENSE` (library MIT)
- Test: `test/basecoat_phoenix/smoke_test.exs`

**Interfaces:**
- Consumes: nothing.
- Produces: `BasecoatPhoenix` module; `BasecoatPhoenix.ComponentCase` test helper (`use`-able, with `render/2`, `one/2`, `attr/2`, `classes/1`, `text/1`, `assert_markup/3`); project compiles under Elixir 1.15.

- [ ] **Step 1: Initialize git and write the failing smoke test**

```bash
cd /Users/yadi/Workspaces/elixir/basecoat_phoenix
git init
```

```elixir
# test/basecoat_phoenix/smoke_test.exs
defmodule BasecoatPhoenix.SmokeTest do
  use ExUnit.Case, async: true

  test "library module is loaded" do
    assert Code.ensure_loaded?(BasecoatPhoenix)
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `mix test test/basecoat_phoenix/smoke_test.exs`
Expected: FAIL because `mix.exs` or `BasecoatPhoenix` does not exist.

- [ ] **Step 3: Create the project files and test helper**

`mix.exs`:

```elixir
defmodule BasecoatPhoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :basecoat_phoenix,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: "Basecoat UI components for Phoenix LiveView",
      package: package()
    ]
  end

  def application, do: [extra_applications: [:logger, :crypto]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix_live_view, "~> 1.2"},
      {:phoenix_html, "~> 4.0"},
      {:jason, "~> 1.4"},
      {:floki, "~> 0.36", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      files: ~w(lib priv mix.exs README.md LICENSE .formatter.exs)
    ]
  end
end
```

`lib/basecoat_phoenix.ex`:

```elixir
defmodule BasecoatPhoenix do
  @moduledoc """
  Basecoat UI components for Phoenix LiveView.
  """
end
```

`test/test_helper.exs`:

```elixir
ExUnit.start()
```

`test/support/component_case.ex`:

```elixir
defmodule BasecoatPhoenix.ComponentCase do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import BasecoatPhoenix.ComponentCase
      # `attr/2` here is the test helper; keep Phoenix.Component's macro out.
      import Phoenix.Component, except: [attr: 2, attr: 3]
      import Phoenix.LiveViewTest, only: [render_component: 2]
    end
  end

  # Needed here too: `render/2` and `assert_markup/3` are defined in this module.
  import ExUnit.Assertions
  import Phoenix.LiveViewTest, only: [render_component: 2]

  def render(component, assigns \\ %{}) do
    component |> render_component(assigns) |> Floki.parse_fragment!()
  end

  def one(fragment, selector) do
    fragment |> Floki.find(selector) |> List.first()
  end

  def attr(node, name) do
    node |> Floki.attribute(name) |> List.first()
  end

  def classes(node) do
    (attr(node, "class") || "") |> String.split()
  end

  def text(node), do: Floki.text(node)

  @doc """
  Asserts the rendered tree matches the upstream doc example.

  Whitespace is collapsed, attribute order is ignored, and a missing closing
  tag is tolerated. Use this for the markup-fidelity contract.
  """
  def assert_markup(component, assigns, expected) do
    actual = component |> render(assigns) |> normalize()
    assert actual == normalize(expected)
  end

  # `render/2` returns a parsed tree; `expected` is a string. Accept both.
  defp normalize(tree) when is_list(tree) do
    tree
    |> sort_attrs()
    |> Floki.raw_html()
    |> String.replace(~r/>\s+/, ">")
    |> String.replace(~r/\s+</, "<")
    |> String.trim()
  end

  defp normalize(html) when is_binary(html) do
    html |> Floki.parse_fragment!() |> normalize()
  end

  defp sort_attrs(nodes) when is_list(nodes), do: Enum.map(nodes, &sort_attrs/1)

  defp sort_attrs({tag, attrs, children}) do
    {tag, Enum.sort(attrs), sort_attrs(children)}
  end

  defp sort_attrs(node), do: node
end
```

`.formatter.exs`:

```elixir
[
  import_deps: [:phoenix_html, :phoenix_live_view],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
```

`.gitignore`:

```text
/_build/
/cover/
/deps/
/doc/
erl_crash.dump
*.ez
*.beam
.elixir_ls/
```

`LICENSE`: standard MIT text for the library author.

- [ ] **Step 4: Run the test to verify it passes**

Run: `mix deps.get && mix test test/basecoat_phoenix/smoke_test.exs`
Expected: 1 test, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "chore: initialize basecoat_phoenix project"
```

---

### Task 2: Vendor Basecoat 1.2.1 Assets

**Files:**
- Create: `priv/basecoat/VERSION`
- Create: `priv/basecoat/LICENSE`
- Create: `priv/basecoat/basecoat-{vega,nova,maia,lyra,mira,luma,sera,rhea}.bundle.css`
- Create: `priv/basecoat/all.min.js`
- Create: `priv/basecoat/chart.min.js`
- Create: `priv/basecoat/typeset.css`
- Create: `priv/basecoat/SHA256SUMS`
- Test: `test/basecoat_phoenix/assets_test.exs`

**Interfaces:**
- Consumes: Task 1 project.
- Produces: pinned asset files consumed by the installer in Task 5. `VERSION` contains `1.2.1`.

- [ ] **Step 1: Write the failing integrity test**

```elixir
# test/basecoat_phoenix/assets_test.exs
defmodule BasecoatPhoenix.AssetsTest do
  use ExUnit.Case, async: true

  @hashes %{
    "all.min.js" => "6dd11f6ea6f2e6321c2ead587bebfeec985ef48a8f108e21722e65be0c94fe73",
    "basecoat-luma.bundle.css" => "d80a645d5b0b106bfd866c82e780aa749d2c57ff30dabf92fa74ef2e6f55fba5",
    "basecoat-lyra.bundle.css" => "4a0fbd15fd67cb714c041b21325aef45ceae7de743a133566afc57bfdb9416fe",
    "basecoat-maia.bundle.css" => "aca88c9cce78f87591acc5ecb97b8029a5e286808c78ba4a5db1428bfc6505c1",
    "basecoat-mira.bundle.css" => "8417b612dba5dde923754719d6e2d8fc5a16c3e688443f2c87ae0f71aaa24e7f",
    "basecoat-nova.bundle.css" => "1d504788b864cffa88b25e257c052b09d0a92f697b978491716a6e96f38e5789",
    "basecoat-rhea.bundle.css" => "a24302291fe3d83433b8b6dbddfb426810121d7d81f53e50d7d5f62f76c1692b",
    "basecoat-sera.bundle.css" => "817abad93b33782d976c54a5223a6b980cb87b9129597e05fb7a7c476e23b214",
    "basecoat-vega.bundle.css" => "c3ebec72289acda7c3ea1ecad39c203b387b332e964b7ae15c9e5814219ff751",
    "chart.min.js" => "4e82a2bc45d8ae9f5fc74341d38e71b6bfd4d691075f0cd08fd8ed6b01feff5c",
    "LICENSE" => "160a6cea26ff1931297957499ab739e94c4bc79ecea18b490c9f533fa76ace78",
    "typeset.css" => "84aa4d5efea52f00ade2327c041e0d75e94ca5ce61d0708e12134531e4c08ec6"
  }

  test "vendored files match the pinned hashes" do
    dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])

    for {name, hash} <- @hashes do
      path = Path.join(dir, name)
      assert File.exists?(path), "missing #{path}"
      assert :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower) == hash
    end
  end

  test "version file is 1.2.1" do
    dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])
    assert File.read!(Path.join(dir, "VERSION")) |> String.trim() == "1.2.1"
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `mix test test/basecoat_phoenix/assets_test.exs`
Expected: FAIL with "missing .../priv/basecoat/...".

- [ ] **Step 3: Download the pinned files once and commit them**

Download from these exact URLs into `priv/basecoat/`:

```text
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-vega.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-nova.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-maia.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-lyra.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-mira.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-luma.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-sera.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/basecoat-rhea.bundle.css
https://unpkg.com/basecoat-css@1.2.1/dist/js/all.min.js
https://unpkg.com/basecoat-css@1.2.1/dist/js/chart.min.js
https://unpkg.com/basecoat-css@1.2.1/dist/typeset.css
https://raw.githubusercontent.com/hunvreus/basecoat/1.2.1/LICENSE.md
```

Write `VERSION` with exactly `1.2.1` plus a trailing newline. Write `SHA256SUMS` as `hash  filename` lines in sorted filename order.

- [ ] **Step 4: Run the test to verify it passes**

Run: `mix test test/basecoat_phoenix/assets_test.exs`
Expected: 2 tests, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add priv/basecoat
git commit -m "chore: vendor Basecoat 1.2.1 assets"
```

---

### Task 3: Shared Field, Forms, and Toast Helpers

**Files:**
- Create: `lib/basecoat_phoenix/field.ex`
- Create: `lib/basecoat_phoenix/forms.ex`
- Create: `lib/basecoat_phoenix/toast.ex`
- Test: `test/basecoat_phoenix/field_test.exs`
- Test: `test/basecoat_phoenix/forms_test.exs`
- Test: `test/basecoat_phoenix/toast_test.exs`

**Interfaces:**
- Consumes: `Phoenix.HTML.FormField`, `Phoenix.LiveView.push_event/3`, `Jason`.
- Produces:
  - `BasecoatPhoenix.Field.resolve(field, opts) :: %{name: String.t() | nil, id: String.t() | nil, value: term(), errors: [String.t()], invalid?: boolean(), describedby: String.t() | nil}`
  - `BasecoatPhoenix.Forms.encode_selection(value, format) :: String.t()`
  - `BasecoatPhoenix.Forms.decode_multi(value) :: [String.t()] | [map()]`
  - `BasecoatPhoenix.Toast.push(socket, opts) :: Phoenix.LiveView.Socket.t()`

- [ ] **Step 1: Write the failing helper tests**

`Field` tests:

```elixir
test "resolve reads a form field" do
  field = %Phoenix.HTML.FormField{name: "user[name]", id: "user_name", value: "Ada", errors: [{"is required", []}]}
  result = BasecoatPhoenix.Field.resolve(field, describedby: "user_name-description")
  assert result.name == "user[name]"
  assert result.id == "user_name"
  assert result.value == "Ada"
  assert result.errors == ["is required"]
  assert result.invalid?
  assert result.describedby == "user_name-description user_name-error"
end

test "resolve reads explicit attrs" do
  result = BasecoatPhoenix.Field.resolve(nil, name: "email", id: "email", value: "a@b.c")
  assert result.name == "email"
  assert result.id == "email"
  assert result.value == "a@b.c"
  refute result.invalid?
  assert result.describedby == nil
end
```

`Forms` tests:

```elixir
test "encode_selection encodes multiple values as JSON" do
  assert BasecoatPhoenix.Forms.encode_selection(["apple", "banana"], "value") == ~s(["apple","banana"])
end

test "encode_selection encodes object format" do
  assert BasecoatPhoenix.Forms.encode_selection([%{value: "a", label: "A"}], "object") == ~s([{"label":"A","value":"a"}])
end

test "decode_multi handles empty, malformed, strings, and maps" do
  assert BasecoatPhoenix.Forms.decode_multi(nil) == []
  assert BasecoatPhoenix.Forms.decode_multi("") == []
  assert BasecoatPhoenix.Forms.decode_multi("not json") == []
  assert BasecoatPhoenix.Forms.decode_multi(~s(["a","b"])) == ["a", "b"]
  assert BasecoatPhoenix.Forms.decode_multi(~s([{"value":"a","label":"A"}])) == [%{"label" => "A", "value" => "a"}]
end
```

`Toast` tests target `payload/1`, the tested interface. `push/2` is a one-line wrapper around it:

```elixir
test "payload converts snake_case options to Basecoat keys" do
  payload = BasecoatPhoenix.Toast.payload(title: "Saved", close_button: false, category: :success, duration: 4000)
  assert payload == %{"title" => "Saved", "closeButton" => false, "category" => "success", "duration" => 4000}
end

test "payload keeps action labels and hrefs without onclick" do
  payload = BasecoatPhoenix.Toast.payload(title: "Saved", action: %{label: "Undo", href: "/undo", onclick: "x"}, cancel: %{label: "Dismiss"})
  assert payload["action"] == %{"label" => "Undo", "href" => "/undo"}
  assert payload["cancel"] == %{"label" => "Dismiss"}
end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/field_test.exs test/basecoat_phoenix/forms_test.exs test/basecoat_phoenix/toast_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the helpers**

`Field.resolve/2`:
- `field` is a `%Phoenix.HTML.FormField{}` when not nil. Use `field.name`, `field.id`, `field.value`, `field.errors`.
- `field.errors` is `[{message, meta}]`; take the messages.
- Else use `opts[:name]`, `opts[:id]`, `opts[:value]`, `opts[:errors] || []`.
- `describedby` is a space-joined list of `opts[:describedby]` (string or list), `"#{id}-description"` when `opts[:has_description]`, and `"#{id}-error"` when errors exist.
- `invalid?` is `opts[:invalid] || errors != []`.

`Forms.encode_selection/2`:
- `nil` -> `""`; binary -> unchanged.
- list or map -> `Jason.encode!/1`.
- other scalar -> `to_string/1`.
- `format` is accepted for call-site clarity; encoding depends on the Elixir value shape, so both formats use the same function.

`Forms.decode_multi/1`:
- `nil` or `""` -> `[]`.
- JSON array -> decoded list.
- JSON object -> `[decoded_object]`.
- any decode error or non-list/non-map -> `[]`.

`Toast`:
- `payload(opts)` builds a map with `"title"`, `"description"`, `"category"` (atom to string), `"duration"`, `"closeButton"`.
- `"action"` and `"cancel"` maps keep `"label"` and `"href"`; drop `:onclick`.
- `push(socket, opts)` calls `Phoenix.LiveView.push_event(socket, "basecoat_toast", payload(opts))`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/field_test.exs test/basecoat_phoenix/forms_test.exs test/basecoat_phoenix/toast_test.exs`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/basecoat_phoenix/field.ex lib/basecoat_phoenix/forms.ex lib/basecoat_phoenix/toast.ex test/basecoat_phoenix/field_test.exs test/basecoat_phoenix/forms_test.exs test/basecoat_phoenix/toast_test.exs
git commit -m "feat: add field, forms, and toast helpers"
```

---

### Task 4: LiveView JS Glue and Hooks

**Files:**
- Create: `priv/basecoat/basecoat_live.js`
- Test: `test/basecoat_phoenix/live_js_test.exs`

**Interfaces:**
- Consumes: `window.basecoat.initAll/1`, `window.basecoat.refresh/1`, `window.basecoat.chart/2`, `window.basecoat.theme.toggle/0`, Basecoat drawer/select/combobox behavior.
- Produces: `export const BasecoatHooks = {BasecoatState, BasecoatChart}`. Hook names are exact and used by component `phx-hook` attributes. `BasecoatState` also owns overlay `showModal()`/`close()` sync for every root `<dialog>`, because Basecoat 1.2.1 has no dialog controller. `basecoat_live.js` also registers a window listener for `phx:basecoat_toast` and delegated `data-basecoat-*` click handlers.

- [ ] **Step 1: Write the static contract test**

```elixir
# test/basecoat_phoenix/live_js_test.exs
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
    for marker <- ~w(data-basecoat-dialog-open data-basecoat-dialog-close data-basecoat-drawer-open data-basecoat-drawer-close data-basecoat-sidebar-toggle data-basecoat-theme-toggle phx:basecoat_toast basecoat:toast), do: assert(js =~ marker)
    assert js =~ ~s{window.addEventListener("phx:basecoat_toast"}
  end

  test "refreshes server-driven components with the registry API", %{js: js} do
    assert js =~ "window.basecoat"
    assert js =~ "refresh"
    refute js =~ "childSignature"
    refute js =~ "data-basecoat-state"
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `mix test test/basecoat_phoenix/live_js_test.exs`
Expected: FAIL because `priv/basecoat/basecoat_live.js` does not exist.

- [ ] **Step 3: Implement `basecoat_live.js`**

Plain ESM. `export const BasecoatHooks = {BasecoatState, BasecoatChart}`.

`BasecoatState`:
- Preservation scope is the hook element and its whole subtree. No marker or key attributes exist.
- `snapshot(root)` returns a `Map` keyed by element identity: `id` when present, else `name`, else `"#{tag}##{n}"` where `n` is the index among same-tag siblings. Never key on absolute position, so inserting or removing siblings does not shift matching. Each entry is `{attrs, props}`. `attrs` is a plain object of every attribute except `phx-*` and `data-phx-*`; `props` holds `value`, `checked`, `selectedIndex`, `open`, and `hidden` for form elements and `<details>`.
- `mounted()`: `this._baseline = snapshot(this.el)`. For every root `<dialog>` in the subtree whose native `open` property is true and which is not already `:modal`, call `showModal()`.
- `beforeUpdate(toEl)`: `this._client = snapshot(this.el)`; `this._server = snapshot(toEl)`; compute `this._changed` as the set of `key` + name whose server value differs from `this._baseline`, treating presence and absence as values.
- `updated()`:
  - `const current = snapshot(this.el)`. For each `[key, client]` in `this._client`, look up `current.get(key)` and skip when the element no longer exists. Never assume the node object is the same one captured before the patch.
  - For each attribute name in the union of baseline, client, and server for that key: if the server changed it, keep the server value; otherwise apply the client value, including removal when the client lacks the attribute. This restores attributes the client removed as well as ones the server dropped.
  - Restore form properties the same way: `value`, `checked`, `selectedIndex`.
  - Overlay sync runs for every root `<dialog>` in the scope (`.dialog`, `.alert-dialog`, `.drawer`, `.sheet`, `.command-dialog`). If the server changed `open`, call `showModal()` when the server opens and `close()` when it closes. Guard with `this.el.open` and `this.el.matches(":modal")` so an open dialog is not opened twice and a closed one is not closed twice. A server `false -> true` transition therefore opens modally, not with a bare attribute.
  - Call `window.basecoat?.refresh?.(this.el)` once, unconditionally. Basecoat's registry dispatches on `dataset.basecoatComponent` and no-ops for components without a refresh function. The select and combobox refresh paths run with `triggerEvent = false`, so this never emits `change`. The unconditional call also restores the client-created `.combobox-chips` wrapper in a multiple combobox: `refreshCombobox` re-creates it through `ensureMultipleInputSurface` when the patch removed it.
  - `this._baseline = this._server`.
- Baseline limitation: a server render that equals the client's original value is indistinguishable from "unchanged", so it cannot pull a client-owned value back to its baseline. Escape hatch: change a nonce attribute on the root (for example `data-reset={@reset_counter}`) or re-render the subtree.
- Backdrop click: add `pointerdown` and `click` listeners to each root `<dialog>` that is not `.drawer` or `.sheet` (Basecoat's drawer controller already owns backdrop and cancel for those); close only when both events target the dialog element itself.

`BasecoatChart`:
- `mounted()` and `updated()` call `render()`.
- `render()` guards on `window.basecoat?.chart` and `window.Chart`; logs one clear error when either is missing. Calls `window.basecoat.chart(this.el, {})`; Basecoat reads `data-chart-*`.
- `updated()` returns early unless `data-chart-data`, `data-chart-series`, or `data-chart-type` changed since the last render, so unrelated patches do not rebuild the chart.

Window listener for toasts (no hook):
- `window.addEventListener("phx:basecoat_toast", (event) => document.getElementById("toaster")?.toast(event.detail))`. LiveView dispatches every `push_event` as `phx:<event>` on `window`, so this one listener serves nested LiveViews too.

Delegated `document` click handler:
- `[data-basecoat-dialog-open]`: `const el = document.getElementById(value); if (el && !el.open) el.showModal()`.
- `[data-basecoat-dialog-close]`: `const el = target.closest("dialog"); if (el?.open) el.close()`.
- `[data-basecoat-drawer-open]`: same as dialog open.
- `[data-basecoat-drawer-close]`: same as dialog close.
- `[data-basecoat-sidebar-toggle]`: `document.getElementById(value)?.toggle()`.
- `[data-basecoat-theme-toggle]`: `window.basecoat?.theme?.toggle()`.

Document custom events for `JS.dispatch/2`:
- `basecoat:open-dialog`, `basecoat:close-dialog`, `basecoat:open-drawer`, `basecoat:close-drawer` use `event.detail.id`.
- `basecoat:toast` calls `document.getElementById("toaster")?.toast(event.detail)`.

Delegated `document` change handler:
- If `event.target` matches `.select` or `.combobox` (the root itself, not a child), find its `input[type="hidden"]` and dispatch `new Event("change", {bubbles: true})` on it. The hidden input event must not match the root check, so it cannot loop.

Lifecycle:
- On `phx:page-loading-stop`, call `window.basecoat?.initAll?.()`.
- All handlers guard on `window.basecoat`.

- [ ] **Step 4: Run the test to verify it passes**

Run: `mix test test/basecoat_phoenix/live_js_test.exs`
Expected: 3 tests, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add priv/basecoat/basecoat_live.js test/basecoat_phoenix/live_js_test.exs
git commit -m "feat: add LiveView hooks and Basecoat event glue"
```

---

### Task 5: Installer Task and Tests

**Files:**
- Create: `lib/basecoat_phoenix/installer.ex`
- Create: `lib/basecoat_phoenix/installer/css.ex`
- Create: `lib/mix/tasks/basecoat.install.ex`
- Test: `test/basecoat_phoenix/installer_test.exs`
- Test: `test/basecoat_phoenix/installer/css_test.exs`

**Interfaces:**
- Consumes: Task 2 assets; Task 4 `basecoat_live.js`; `:code.priv_dir(:basecoat_phoenix)`.
- Produces: `BasecoatPhoenix.Installer.install(opts) :: {:ok, [String.t()]} | {:error, String.t()}`; `BasecoatPhoenix.Installer.CSS.remove_plugin_block(css, plugin_name) :: String.t()` (matches the full quoted `@plugin "<name>"`, scans braces); `BasecoatPhoenix.Installer.CSS.insert_after(css, line_prefix, line) :: String.t()` (inserts after the first line whose trimmed text starts with `line_prefix`, once); `mix basecoat.install` CLI.

- [ ] **Step 1: Write the failing pure-CSS tests**

`BasecoatPhoenix.Installer.CSS` holds the only fiddly string surgery, so it is tested on its own, with no filesystem:

```elixir
test "remove_plugin_block removes the block and its brace body" do
  css = ~S"""
  @import "tailwindcss";
  @plugin "daisyui/packages/bundle/daisyui" {
    themes: false;
  }
  @custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));
  """

  out = BasecoatPhoenix.Installer.CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui")
  refute out =~ "daisyui"
  assert out =~ ~s(@import "tailwindcss";)
  assert out =~ "@custom-variant dark"
end

test "remove_plugin_block leaves other content untouched" do
  css = ~s(@plugin "daisyui/packages/bundle/daisyui" { themes: false; }\n@theme { --x: 1; })
  out = BasecoatPhoenix.Installer.CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui")
  assert out == "@theme { --x: 1; }"
end

test "remove_plugin_block matches the quoted plugin name, not a prefix" do
  css = ~s(@plugin "daisyui/packages/bundle/daisyui-theme" { name: "dark"; }\n@theme { --x: 1; })
  out = BasecoatPhoenix.Installer.CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui")
  assert out == css
end

test "remove_plugin_block is idempotent" do
  css = ~s(@import "tailwindcss";\n)
  assert BasecoatPhoenix.Installer.CSS.remove_plugin_block(css, "daisyui/packages/bundle/daisyui") == css
end

test "insert_after matches a line prefix and is idempotent" do
  css = ~s(@import "tailwindcss" source(none);\n@source "../js";\n)
  line = ~s(@import "../vendor/basecoat/basecoat.css";)
  once = BasecoatPhoenix.Installer.CSS.insert_after(css, ~s(@import "tailwindcss"), line)
  assert once == ~s(@import "tailwindcss" source(none);\n#{line}\n@source "../js";\n)
  assert BasecoatPhoenix.Installer.CSS.insert_after(once, ~s(@import "tailwindcss"), line) == once
end

test "insert_after returns the input unchanged when the anchor is missing" do
  assert BasecoatPhoenix.Installer.CSS.insert_after("a\n", "zzz", "b") == "a\n"
end
```

- [ ] **Step 2: Write the failing installer tests**

Use a temp dir with a Phoenix 1.8-like `assets/css/app.css` and `assets/js/app.js`:

```elixir
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
```

Tests:
- `install` copies `basecoat.css`, `basecoat.js` (from `all.min.js`), and `basecoat_live.js`; CSS imports Basecoat after Tailwind; all three daisyUI blocks (base, dark theme, light theme) and `[data-theme=dark]` are gone; `app.css.bak` exists.
- Dark-mode contract: the copied `basecoat.css` contains an `html.dark` selector and the patched `app.css` contains no `[data-theme=dark]`.
- Running twice produces identical CSS/JS.
- Without `replace_ui: true`, returns `{:error, msg}` and copies nothing.
- Missing `@import "tailwindcss"` returns `{:error, msg}`.
- JS hook merge becomes `hooks: {...colocatedHooks, ...BasecoatHooks}`.
- Missing `const csrfToken` returns `{:ok, [warning]}` and leaves JS untouched.
- `dry_run: true` returns `{:ok, changes}` and writes nothing: no `vendor/` dir, no `app.css.bak`, `app.css` and `app.js` byte-identical.

- [ ] **Step 3: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/installer/css_test.exs test/basecoat_phoenix/installer_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 4: Implement the installer**

`install/1` options: `:assets_path` (default `"assets"`), `:css` (default `"assets/css/app.css"`), `:js` (default `"assets/js/app.js"`), `:source_path` (default `"../../deps/basecoat_phoenix/lib"`), `:style` (default `"vega"`), `:typeset`, `:chart`, `:replace_ui`, `:dry_run`.

Preflight before copying:
- CSS must contain a line that starts with `@import "tailwindcss"` (the generated Phoenix 1.8 line is `@import "tailwindcss" source(none);`).
- If CSS contains daisyUI `@plugin "daisyui/...` or `@custom-variant dark (&:where([data-theme=dark]` and `replace_ui` is false, return `{:error, msg}` with the exact lines to remove.

With `replace_ui: true`:
- Copy `app.css` to `app.css.bak` only if a destructive change will happen.
- Remove every daisyUI plugin block with `CSS.remove_plugin_block/2`, which scans brace depth instead of using a regex. Remove each name to a fixpoint: `daisyui/packages/bundle/daisyui` and `daisyui/packages/bundle/daisyui-theme` (the theme plugin appears once per theme, so the second pass is required). Match the full quoted plugin name, never a prefix, so `daisyui` does not delete `daisyui-theme`.
- Remove the `[data-theme=dark]` dark variant line.

Copy:
- `priv/basecoat/basecoat-<style>.bundle.css` -> `<assets_path>/vendor/basecoat/basecoat.css`.
- `priv/basecoat/all.min.js` -> `<assets_path>/vendor/basecoat/basecoat.js`.
- `priv/basecoat/basecoat_live.js` -> `<assets_path>/vendor/basecoat/basecoat_live.js`.
- `:typeset` also copies `typeset.css`.
- `:chart` also copies `chart.min.js` -> `chart.js`.

Patch CSS:
- Insert `@import "<relative path to vendor/basecoat/basecoat.css>";` immediately after the first line that starts with `@import "tailwindcss"` (this covers `@import "tailwindcss" source(none);`).
- Append `@source "<source_path>";` once.
- With `:typeset`, insert `@import "<relative path to typeset.css>";` after the Basecoat import.

Patch JS:
- Insert `import "<relative path to basecoat.js>";` and, with `:chart`, `import "<relative path to chart.js>";`, plus `import {BasecoatHooks} from "<relative path to basecoat_live.js>";` before `const csrfToken`.
- Replace `hooks: {...colocatedHooks}` with `hooks: {...colocatedHooks, ...BasecoatHooks}`.
- If `const csrfToken` is missing, leave JS untouched and return a warning snippet.
- If the hooks pattern is missing, leave JS untouched and return a warning snippet.

`mix basecoat.install` parses options with `OptionParser` (including `--dry-run`), calls `install/1`, prints warnings and the changed paths, and `Mix.raise/1` on error.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/installer/css_test.exs test/basecoat_phoenix/installer_test.exs`
Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/basecoat_phoenix/installer.ex lib/basecoat_phoenix/installer/css.ex lib/mix/tasks/basecoat.install.ex test/basecoat_phoenix/installer_test.exs test/basecoat_phoenix/installer/css_test.exs
git commit -m "feat: add Basecoat installer"
```

---

### Task 6: Vertical Slice — Button, Card, Dialog, Select

**Files:**
- Create: `lib/basecoat_phoenix/components/button.ex`
- Create: `lib/basecoat_phoenix/components/card.ex`
- Create: `lib/basecoat_phoenix/components/semantic.ex`
- Create: `lib/basecoat_phoenix/components/dialog.ex`
- Create: `lib/basecoat_phoenix/components/select.ex`
- Create: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/button_test.exs`
- Test: `test/basecoat_phoenix/components/card_test.exs`
- Test: `test/basecoat_phoenix/components/conventions_test.exs`
- Test: `test/basecoat_phoenix/components/dialog_test.exs`
- Test: `test/basecoat_phoenix/components/select_test.exs`

**Interfaces:**
- Consumes: `BasecoatPhoenix.Field.resolve/2`, `BasecoatPhoenix.Forms.encode_selection/2`.
- Produces: `use BasecoatPhoenix.Components` imports the four modules. Component functions: `bc_button/1`, `bc_card/1`, `bc_card_header/1`, `bc_card_title/1`, `bc_card_description/1`, `bc_card_action/1`, `bc_card_content/1`, `bc_card_footer/1`, `bc_dialog/1`, `bc_dialog_trigger/1`, `bc_select/1`.

- [ ] **Step 1: Write the failing tests**

Every component test file starts with the same header, then imports the module under test:

```elixir
defmodule BasecoatPhoenix.Components.ButtonTest do
  use BasecoatPhoenix.ComponentCase
  import BasecoatPhoenix.Components.Button
end
```

Button:

```elixir
test "bc_button renders a link with variant and size" do
  html = render(&Button.bc_button/1, %{variant: "outline", size: "sm", href: "/save", inner_block: [%{inner_block: fn _, _ -> "Save" end}]})
  link = one(html, "a.btn")
  assert attr(link, "href") == "/save"
  assert attr(link, "data-variant") == "outline"
  assert attr(link, "data-size") == "sm"
  assert text(link) == "Save"
end

test "bc_button omits default variant and size" do
  html = render(&Button.bc_button/1, %{inner_block: [%{inner_block: fn _, _ -> "Save" end}]})
  button = one(html, "button.btn")
  refute attr(button, "data-variant")
  refute attr(button, "data-size")
  assert attr(button, "type") == "button"
end
```

Card:
- `div.card` root.
- `header > h2`, `header > p`, `div.card-action`, `section`, `footer`.
- Title is a fixed `<h2>`, matching the upstream example. The heading level is not configurable; no `tag` attribute exists.
- Class merge and rest passthrough, asserted once in the shared `conventions_test.exs`.

Dialog:
- `dialog.dialog` with `id`, `aria-labelledby="#{id}-title"`, `aria-describedby="#{id}-description"`.
- `open` renders the native `open` attribute.
- `header > h2#id-title`, `header > p#id-description`, `section`, `footer` slot.
- Close button `button.btn[data-variant=ghost][data-size=icon-sm][aria-label="Close dialog"][data-basecoat-dialog-close]`.
- `phx-hook="BasecoatState"`.
- `bc_dialog_trigger` renders `button.btn[data-variant=outline][data-basecoat-dialog-open=id]`.

Select:
- Root `div.select[data-placeholder]` with `id`, `phx-hook="BasecoatState"`.
- Trigger `button#id-trigger[aria-haspopup=listbox][aria-expanded=false][aria-controls=id-listbox]`, span label, chevron SVG.
- Popover `div#id-popover[data-popover][aria-hidden=true]`, listbox `div#id-listbox[role=listbox]`.
- Group `div[role=group][aria-labelledby]` + `span[role=heading]`.
- Option `div[role=option][data-value]`; disabled renders `aria-disabled="true"`.
- Hidden `input[type=hidden][name]` value: single string, multiple JSON, object format JSON.
- `field={@form[:fruit]}` derives name/id/value.
- Class merge and rest passthrough.

Write the fidelity tests with `assert_markup/3`, copying the upstream doc example and adding only the documented extras. Composition is easiest to express as a fixture component, because a slot entry must be a slot map, not a bare function:

```elixir
defmodule BasecoatPhoenix.Components.CardFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Card

  def card(assigns) do
    ~H"""
    <.bc_card>
      <.bc_card_header>
        <.bc_card_title>Title</.bc_card_title>
        <.bc_card_description>Description.</.bc_card_description>
      </.bc_card_header>
      <.bc_card_content>Body</.bc_card_content>
      <.bc_card_footer>Footer</.bc_card_footer>
    </.bc_card>
    """
  end
end

test "bc_card matches the upstream card markup" do
  assert_markup(&BasecoatPhoenix.Components.CardFixture.card/1, %{}, ~S"""
  <div class="card">
    <header><h2>Title</h2><p>Description.</p></header>
    <section>Body</section>
    <footer>Footer</footer>
  </div>
  """)
end
```

Keep the plain assertions (like the button ones above) for the parts a tree comparison cannot express: default-attribute omission, `href` switching the tag, and the select's encoded hidden-input value. Put class merge and `{@rest}` passthrough in `test/basecoat_phoenix/components/conventions_test.exs`, written once against `bc_button` and `bc_card` and reused as the convention for every later task.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components/button_test.exs test/basecoat_phoenix/components/card_test.exs test/basecoat_phoenix/components/conventions_test.exs test/basecoat_phoenix/components/dialog_test.exs test/basecoat_phoenix/components/select_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the four modules, the umbrella, and the `defsemantic` macro**

Use the exact markup in the spec inventory rows for Button, Card, Dialog, and Select. Preserve the order and tags.

Create `lib/basecoat_phoenix/components/semantic.ex` with the one macro that carries the ~30 trivial subcomponents:

```elixir
defmodule BasecoatPhoenix.Components.Semantic do
  @moduledoc false

  @doc """
  Declares a subcomponent that renders one upstream tag with an optional class.
  """
  defmacro defsemantic(name, tag, opts \\ []) do
    class = opts[:class]

    quote do
      attr :class, :string, default: nil
      attr :rest, :global
      slot :inner_block, required: true

      # Phoenix only accepts attr/slot next to a bodyless head.
      def unquote(name)(assigns)

      def unquote(name)(assigns) do
        BasecoatPhoenix.Components.Semantic.render(unquote(tag), unquote(class), assigns)
      end
    end
  end

  @doc false
  def render(tag, base_class, assigns) do
    classes = [base_class, assigns.class] |> List.flatten() |> Enum.reject(&is_nil/1)

    rest =
      if classes == [],
        do: assigns.rest,
        else: Map.put(assigns.rest, :class, Enum.join(classes, " "))

    Phoenix.Component.dynamic_tag(%{
      __changed__: Map.get(assigns, :__changed__, %{}),
      tag_name: to_string(tag),
      rest: rest,
      inner_block: assigns.inner_block
    })
  end
end
```

Three constraints drive this shape, verified against the installed LiveView declarative engine (1.1.24 locally; the same code path ships in 1.2) and phoenix_html 4:

- `~H` cannot live inside the macro: its `assigns` variable is macro-hygienic, so `sigil_H` raises "requires a variable named assigns".
- Phoenix rejects `attr`/`slot` next to a macro-generated component body ("Components cannot be dynamically defined"). It accepts them next to a bodyless head, so the macro emits `def name(assigns)` first, then the body.
- `Phoenix.Component.dynamic_tag/1` is a function, not a sigil, so it sidesteps both problems. It needs the component's `__changed__` in its assigns map.

`class` goes into the rest map only when the merged list is non-empty, so no empty `class=""` is invented. Without `attr :rest, :global`, HEEx drops undeclared attributes; the declarations are required, not cosmetic. `defsemantic` must be used in a module that calls `use Phoenix.Component`.

`Semantic.classes/1` flattens a class list and joins it without a stray trailing space, which `class={["card", @class]}` produces when `@class` is nil in LiveView 1.2. Every component that merges a caller class uses it, so markup fidelity tests see `class="card"`, not `class="card "`.

Card then becomes:

```elixir
defmodule BasecoatPhoenix.Components.Card do
  use Phoenix.Component
  import BasecoatPhoenix.Components.Semantic

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def bc_card(assigns) do
    ~H"""
    <div class={["card", @class]} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  defsemantic :bc_card_header, :header
  defsemantic :bc_card_title, :h2
  defsemantic :bc_card_description, :p
  defsemantic :bc_card_action, :div, class: "card-action"
  defsemantic :bc_card_content, :section
  defsemantic :bc_card_footer, :footer
end
```

`lib/basecoat_phoenix/components.ex`:

```elixir
defmodule BasecoatPhoenix.Components do
  defmacro __using__(_opts) do
    quote do
      import BasecoatPhoenix.Components.Button
      import BasecoatPhoenix.Components.Card
      import BasecoatPhoenix.Components.Dialog
      import BasecoatPhoenix.Components.Select
    end
  end
end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components`
Expected: all test files pass.

- [ ] **Step 5: Start the browser verification app**

Create a throwaway Phoenix 1.8 app outside the repo (for example `/private/var/folders/.../opencode/bc_demo`), add `{:basecoat_phoenix, path: "/Users/yadi/Workspaces/elixir/basecoat_phoenix"}`, run `mix basecoat.install --replace-ui`, and render the four slice components in one LiveView. Confirm in a browser: dialog opens from its trigger, closes on backdrop and close button, stays open across an unrelated assign update; select opens, selects, writes its hidden input, and submits.

Create `docs/manual-verification.md` now with the sections for the four slice components plus a "To be added" list of the remaining controllers. Later tasks append to it as each component lands. Toast verification waits for Task 13, which adds `bc_toaster`.

- [ ] **Step 6: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components docs/manual-verification.md
git commit -m "feat: add button, card, dialog, and select components"
```

---

### Task 7: Buttons and Display Primitives

**Files:**
- Create: `lib/basecoat_phoenix/components/button_group.ex`
- Create: `lib/basecoat_phoenix/components/badge.ex`
- Create: `lib/basecoat_phoenix/components/avatar.ex`
- Create: `lib/basecoat_phoenix/components/kbd.ex`
- Create: `lib/basecoat_phoenix/components/separator.ex`
- Create: `lib/basecoat_phoenix/components/skeleton.ex`
- Create: `lib/basecoat_phoenix/components/spinner.ex`
- Create: `lib/basecoat_phoenix/components/progress.ex`
- Modify: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/{button_group,badge,avatar,kbd,separator,skeleton,spinner,progress}_test.exs`

**Interfaces:**
- Consumes: Task 6 umbrella pattern.
- Produces: `bc_button_group/1`, `bc_badge/1`, `bc_avatar/1`, `bc_avatar_image/1`, `bc_avatar_fallback/1`, `bc_avatar_badge/1`, `bc_avatar_group/1`, `bc_kbd/1`, `bc_separator/1`, `bc_skeleton/1`, `bc_spinner/1`, `bc_progress/1`.

- [ ] **Step 1: Write the failing tests**

Use `assert_markup/3` for each component's upstream example. Use `defsemantic` in the implementation wherever the subcomponent is one tag plus an optional class.

| Module | Assertions |
| --- | --- |
| Button Group | `div.button-group[role=group]`; children slot. |
| Badge | `span.badge`; variants primary(omit), secondary, destructive, outline, ghost. |
| Avatar | `span.avatar`; `img`; fallback `span`; `span.avatar-badge`; `div.avatar-group`; `data-size` passthrough. |
| Kbd | `kbd.kbd`; slot text. |
| Separator | `hr[role=separator]`; `decorative` renders `hr[role=none]`; no class. |
| Skeleton | `div.skeleton`; class merge adds sizing utilities. |
| Spinner | `svg[role=status][aria-label="Loading"]` with `animate-spin` and `lucide-loader-circle`. Upstream documents that Basecoat has no Spinner component; this helper renders the upstream loader SVG markup as-is. |
| Progress | `div.progress[role=progressbar][aria-valuenow][aria-valuemin=0][aria-valuemax]`; inner `span[style="width: N%"]`. |

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components`
Expected: new test files fail.

- [ ] **Step 3: Implement the eight modules**

Follow the spec inventory rows. `bc_badge` variant values: `primary`, `secondary`, `destructive`, `outline`, `ghost`; omit `data-variant` for `primary`. `bc_progress` computes `width` as `value / max * 100`, clamped to `0..100`, rendered with one decimal only when needed. `bc_spinner` renders the upstream `loader-circle` SVG.

Add all eight modules to `BasecoatPhoenix.Components`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components`
Expected: all pass.

Then append the display-primitive rows to `docs/manual-verification.md`. These are CSS-only, so the check is visual markup.

- [ ] **Step 5: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components docs/manual-verification.md
git commit -m "feat: add buttons and display primitives"
```

---

### Task 8: Form Controls

**Files:**
- Create: `lib/basecoat_phoenix/components/input.ex`
- Create: `lib/basecoat_phoenix/components/textarea.ex`
- Create: `lib/basecoat_phoenix/components/native_select.ex`
- Create: `lib/basecoat_phoenix/components/label.ex`
- Create: `lib/basecoat_phoenix/components/field.ex`
- Create: `lib/basecoat_phoenix/components/checkbox.ex`
- Create: `lib/basecoat_phoenix/components/radio_group.ex`
- Create: `lib/basecoat_phoenix/components/switch.ex`
- Create: `lib/basecoat_phoenix/components/toggle.ex`
- Create: `lib/basecoat_phoenix/components/toggle_group.ex`
- Create: `lib/basecoat_phoenix/components/input_group.ex`
- Create: `lib/basecoat_phoenix/components/input_otp.ex`
- Create: `lib/basecoat_phoenix/components/slider.ex`
- Create: `lib/basecoat_phoenix/components/combobox.ex`
- Modify: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/form_controls_test.exs`

**Interfaces:**
- Consumes: `BasecoatPhoenix.Field.resolve/2`.
- Produces: `bc_input/1`, `bc_textarea/1`, `bc_native_select/1`, `bc_label/1`, `bc_fieldset/1`, `bc_field/1`, `bc_field_label/1`, `bc_field_description/1`, `bc_field_error/1`, `bc_checkbox/1`, `bc_radio_group/1`, `bc_radio_group_item/1`, `bc_switch/1`, `bc_toggle/1`, `bc_toggle_group/1`, `bc_toggle_group_item/1`, `bc_input_group/1`, `bc_input_group_addon/1`, `bc_input_group_button/1`, `bc_input_otp/1`, `bc_slider/1`, `bc_combobox/1`.

- [ ] **Step 1: Write the failing tests**

Use `assert_markup/3` for each component's upstream example. Cover these assertions in addition to the markup comparison:

- `bc_input`/`bc_textarea` render `input.input`/`textarea.textarea`, pass `name`, `value`, `type`, `placeholder`, `aria-invalid`, `aria-describedby`, and merge `class`.
- `bc_native_select` renders `select.select` and `option` children; supports `field`.
- `bc_label` renders `label.label`.
- `bc_fieldset` renders `fieldset.fieldset` with `legend`; `bc_field` renders `div.field[role=group]`; `bc_field_label` renders `label`; `bc_field_description` renders `p#id-description`; `bc_field_error` renders `p#id-error[role=alert]`.
- `bc_checkbox` renders `div.fieldset[role=group] > div.field[role=group][data-orientation=horizontal] > input.input[type=checkbox] + label`.
- `bc_radio_group` renders `div[role=radiogroup][data-slot=radio-group]`; items render `div.flex.items-center.gap-3 > input.input[type=radio] + label`.
- `bc_switch` renders `div.field[role=group][data-orientation=horizontal] > input.input[type=checkbox][role=switch] + label`.
- `bc_toggle` renders `label.btn` with variant/size and a native input; `bc_toggle_group` renders `fieldset > legend.sr-only > div.flex.gap-2` with label items. `single` renders radio inputs; the default renders checkbox inputs and supports multiple selected values.
- `bc_input_group` renders `div.input-group`; addon `span[data-align]`; button `button` or `div[role=group]`.
- `bc_input_otp` renders `div.input-otp > input.input[aria-label] + div[aria-hidden=true] > div > span` slots, one span per `length` character (slot count must equal `maxlength` or Basecoat returns early). It has `id`, `phx-update="ignore"`, and no `phx-hook`. `length` renders `maxlength`; `filter` renders `data-filter`; `pattern` renders `pattern`; `value` passes through.
- `bc_slider` renders `input[type=range].input`, has `phx-hook="BasecoatState"`, and requires `id`. `min`, `max`, and `step` render as native attributes. It also renders `style={"--slider-value: #{pct}%"}`, computed from `value`/`min`/`max` the same way Basecoat computes it. The Basecoat range controller listens to `input` only and has no registry refresh, so the server-rendered style is what repaints the fill after a server-side value change; the hook preserves the client-written style otherwise.
- `bc_combobox` renders `div.combobox[id][phx-hook=BasecoatState]`; text input `input[role=combobox][aria-autocomplete=list][aria-expanded=false][aria-controls]`; trigger icon svg; `div[data-popover][aria-hidden=true] > div[role=listbox][data-empty][id]`; options `div[role=option][data-value]`; hidden `input[type=hidden][name]`; `clear` renders the upstream clear control; multiple/object values encode as JSON; `field={@form[:x]}` derives `name`/`id`/`value`.
- `field={@form[:name]}` on input, textarea, native select, checkbox, switch, and toggle derives name/id/value/errors and `aria-describedby`.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components/form_controls_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the form modules**

Follow the spec inventory rows exactly. Use `Field.resolve/2` in every control that accepts `field`. Native controls keep normal LiveView form semantics. Do not add `BasecoatState` to native controls; `bc_slider`, `bc_select`, and `bc_combobox` are the exceptions and carry it.

Add all fourteen modules to `BasecoatPhoenix.Components`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components/form_controls_test.exs`
Expected: all pass.

Then append the form-control rows to `docs/manual-verification.md` (combobox, input OTP, range) and verify them in the Task 6 browser app.

- [ ] **Step 5: Verify in the browser**

Confirm in the Task 6 app: combobox filters, selects, writes its hidden input, and survives an unrelated assign update; input OTP accepts typing and submits; slider repaints its fill after a server value change.

- [ ] **Step 6: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components/form_controls_test.exs docs/manual-verification.md
git commit -m "feat: add form control components"
```

---

### Task 9: Layout and Structure

**Files:**
- Create: `lib/basecoat_phoenix/components/item.ex`
- Create: `lib/basecoat_phoenix/components/empty.ex`
- Create: `lib/basecoat_phoenix/components/collapsible.ex`
- Create: `lib/basecoat_phoenix/components/accordion.ex`
- Create: `lib/basecoat_phoenix/components/sidebar.ex`
- Modify: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/layout_test.exs`

**Interfaces:**
- Consumes: Task 6 umbrella pattern.
- Produces: `bc_item/1`, `bc_item_group/1`, `bc_item_media/1`, `bc_item_content/1`, `bc_item_title/1`, `bc_item_description/1`, `bc_item_actions/1`, `bc_item_header/1`, `bc_item_footer/1`, `bc_empty/1`, `bc_empty_header/1`, `bc_empty_media/1`, `bc_empty_title/1`, `bc_empty_description/1`, `bc_empty_content/1`, `bc_empty_footer/1`, `bc_collapsible/1`, `bc_collapsible_trigger/1`, `bc_collapsible_content/1`, `bc_accordion/1`, `bc_accordion_item/1`, `bc_accordion_trigger/1`, `bc_accordion_content/1`, `bc_sidebar/1`, `bc_sidebar_nav/1`, `bc_sidebar_header/1`, `bc_sidebar_content/1`, `bc_sidebar_group/1`, `bc_sidebar_group_label/1`, `bc_sidebar_menu/1`, `bc_sidebar_menu_item/1`, `bc_sidebar_menu_button/1`, `bc_sidebar_menu_sub/1`, `bc_sidebar_footer/1`, `bc_sidebar_trigger/1`.

- [ ] **Step 1: Write the failing tests**

Use `assert_markup/3` for each component's upstream example.

| Module | Assertions |
| --- | --- |
| Item | `article.item`; `a.item` when `href`; `figure`, `section > h3`, `p`, `aside`, `header`, `footer`; `div.item-group[role=list]`; no `item-content`. |
| Empty | `section.empty > header > figure/h3/p`; `section` or `footer` actions; no `empty-content` class. |
| Collapsible | Native `details > summary`; content slot; no invented classes. |
| Accordion | `section.accordion > details > summary > section`; item/trigger/content subcomponents; no invented classes. |
| Sidebar | `aside.sidebar[data-side]`; `data-initial-open`, `data-initial-mobile-open`, `data-breakpoint` pass through; `nav`, `header`, `section`, `footer`; `div[role=group][aria-labelledby]`; `ul/li/a|button`; `details/summary` submenu; trigger `data-basecoat-sidebar-toggle`; `phx-hook="BasecoatState"`. |

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components/layout_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the five modules**

Follow the spec inventory rows. Use `defsemantic` for the tag-only subcomponents. `bc_item` accepts `href`; without it, render `<article>`, with it `<a>`. `bc_sidebar` requires `id` and validates `side` to `left|right`. Do not implement inset/floating variants.

Add all five modules to `BasecoatPhoenix.Components`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components/layout_test.exs`
Expected: all pass.

Then append the accordion and sidebar rows to `docs/manual-verification.md` and verify them in the Task 6 browser app.

- [ ] **Step 5: Verify in the browser**

Confirm in the Task 6 app: accordion expands and collapses, and stays expanded across an unrelated assign update; sidebar toggles from its trigger and keeps its state across a patch.

- [ ] **Step 6: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components/layout_test.exs docs/manual-verification.md
git commit -m "feat: add layout and structure components"
```

---

### Task 10: Messaging and Display

**Files:**
- Create: `lib/basecoat_phoenix/components/alert.ex`
- Create: `lib/basecoat_phoenix/components/bubble.ex`
- Create: `lib/basecoat_phoenix/components/message.ex`
- Create: `lib/basecoat_phoenix/components/marker.ex`
- Create: `lib/basecoat_phoenix/components/attachment.ex`
- Create: `lib/basecoat_phoenix/components/trace.ex`
- Modify: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/messaging_test.exs`

**Interfaces:**
- Consumes: Task 6 umbrella pattern.
- Produces: `bc_alert/1`, `bc_alert_title/1`, `bc_alert_description/1`, `bc_alert_actions/1`, `bc_bubble/1`, `bc_bubble_group/1`, `bc_message/1`, `bc_message_group/1`, `bc_marker/1`, `bc_attachment/1`, `bc_attachment_media/1`, `bc_attachment_content/1`, `bc_attachment_title/1`, `bc_attachment_description/1`, `bc_attachment_actions/1`, `bc_trace/1`, `bc_trace_item/1`, `bc_trace_line/1`, `bc_trace_detail/1`.

- [ ] **Step 1: Write the failing tests**

Use `assert_markup/3` for each component's upstream example.

| Module | Assertions |
| --- | --- |
| Alert | `div.alert`; direct `:icon` SVG; `h2`, `section`, `footer`; `variant="destructive"`; no `alert-title` class. |
| Bubble | `div.bubble` with first child content and `:reactions` direct `div[role=img]`; `div.bubble-group`; no `bubble-content`. |
| Message | `li.message[data-align]` inside a group, `div.message` standalone; plain `div` body; `span.sr-only`; nested `div.bubble`; `ol[role=list]` group; no `message-content`. |
| Marker | `div.marker[role=status]`; `data-variant=separator|border`; optional decorative SVG before text span; shimmer span. |
| Attachment | `li.attachment[data-orientation]` inside a list, `div.attachment` standalone; `figure`, `section > p + p`, final `div`; full-card `a`/`button` when supplied; no `attachment-content` class. |
| Trace | `ol.trace[role=list] > li > details > summary.trace-line`; nested `div.code-block`; no invented classes. |

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components/messaging_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the six modules**

Follow the spec inventory rows. `bc_bubble` renders the default slot as the first child and `:reactions` as a direct second child. `bc_message` renders the default slot inside a plain `<div>`; the caller composes avatar, sender, and bubble subcomponents. `bc_alert` renders `:icon` as a direct child SVG. No invented `*-content`/`*-media` classes.

Add all six modules to `BasecoatPhoenix.Components`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components/messaging_test.exs`
Expected: all pass.

Then append the messaging rows to `docs/manual-verification.md`. These components are CSS-only, so the check is visual markup, not controller behavior.

- [ ] **Step 5: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components/messaging_test.exs docs/manual-verification.md
git commit -m "feat: add messaging and display components"
```

---

### Task 11: Data Display — Table, Code Block, Chart

**Files:**
- Create: `lib/basecoat_phoenix/components/table.ex`
- Create: `lib/basecoat_phoenix/components/code_block.ex`
- Create: `lib/basecoat_phoenix/components/chart.ex`
- Modify: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/data_display_test.exs`

**Interfaces:**
- Consumes: Task 4 `BasecoatChart` hook; `Jason`.
- Produces: `bc_table_container/1`, `bc_table/1`, `bc_table_caption/1`, `bc_table_header/1`, `bc_table_body/1`, `bc_table_footer/1`, `bc_table_row/1`, `bc_table_head/1`, `bc_table_cell/1`, `bc_code_block/1`, `bc_code_block_header/1`, `bc_code_block_title/1`, `bc_code_block_actions/1`, `bc_code_block_copy/1`, `bc_chart/1`.

- [ ] **Step 1: Write the failing tests**

Use `assert_markup/3` for each component's upstream example.

| Module | Assertions |
| --- | --- |
| Table | `div.table-container > table.table`; `caption`, `thead`, `tbody`, `tfoot`, `tr`, `th`, `td`. |
| Code Block | `div.code-block`; `header > span`; actions `div`; `button.btn[data-variant=ghost][data-size=xs][data-copy]`; `pre.scrollbar[tabindex=0] > code`; `data-line-numbers` on `pre`; `data-size` on root. |
| Chart | Bare `canvas` with `id`, `aria-label`, no class; `data-chart-type`, `data-chart-label-key`, `data-chart-legend`, `data-chart-tooltip`, `data-chart-data`, `data-chart-series`; `phx-hook="BasecoatChart"` instead of `BasecoatState`; JSON attributes are JSON-encoded. |

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components/data_display_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the three modules**

Follow the spec inventory rows. `bc_chart` accepts `id`, `type`, `label_key`, `legend`, `tooltip`, `data`, `series`, `class`, `rest`; encode `data`/`series` with `Jason.encode!/1` into `data-chart-data`/`data-chart-series`; render the native `style`/`aria` attrs. `bc_code_block` renders the copy button only when `copy` is true.

Add all three modules to `BasecoatPhoenix.Components`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components/data_display_test.exs`
Expected: all pass.

Then append the chart and code-block rows to `docs/manual-verification.md` and verify them in the Task 6 browser app.

- [ ] **Step 5: Verify in the browser**

Confirm in the Task 6 app: the chart renders with Chart.js loaded, re-renders when `data-chart-data` changes, and logs one clear error when Chart.js is absent; the code-block copy button copies and shows its copied state.

- [ ] **Step 6: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components/data_display_test.exs docs/manual-verification.md
git commit -m "feat: add table, code block, and chart components"
```

---

### Task 12: Navigation

**Files:**
- Create: `lib/basecoat_phoenix/components/breadcrumb.ex`
- Create: `lib/basecoat_phoenix/components/pagination.ex`
- Create: `lib/basecoat_phoenix/components/tabs.ex`
- Create: `lib/basecoat_phoenix/components/dropdown_menu.ex`
- Create: `lib/basecoat_phoenix/components/command.ex`
- Create: `lib/basecoat_phoenix/components/theme_switcher.ex`
- Modify: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/navigation_test.exs`

**Interfaces:**
- Consumes: Task 6 umbrella pattern.
- Produces: `bc_breadcrumb/1`, `bc_breadcrumb_list/1`, `bc_breadcrumb_item/1`, `bc_breadcrumb_link/1`, `bc_breadcrumb_page/1`, `bc_breadcrumb_separator/1`, `bc_breadcrumb_ellipsis/1`, `bc_pagination/1`, `bc_pagination_list/1`, `bc_pagination_item/1`, `bc_pagination_link/1`, `bc_pagination_previous/1`, `bc_pagination_next/1`, `bc_pagination_ellipsis/1`, `bc_tabs/1`, `bc_tab_list/1`, `bc_tab/1`, `bc_tab_panel/1`, `bc_dropdown_menu/1`, `bc_dropdown_menu_trigger/1`, `bc_dropdown_menu_content/1`, `bc_dropdown_menu_group/1`, `bc_dropdown_menu_label/1`, `bc_dropdown_menu_item/1`, `bc_dropdown_menu_checkbox_item/1`, `bc_dropdown_menu_radio_item/1`, `bc_dropdown_menu_separator/1`, `bc_dropdown_menu_shortcut/1`, `bc_command/1`, `bc_command_dialog/1`, `bc_command_input/1`, `bc_command_list/1`, `bc_command_group/1`, `bc_command_item/1`, `bc_command_separator/1`, `bc_command_shortcut/1`, `bc_theme_switcher/1`.

- [ ] **Step 1: Write the failing tests**

Use `assert_markup/3` for each component's upstream example.

| Module | Assertions |
| --- | --- |
| Breadcrumb | `nav.breadcrumb[aria-label=Breadcrumb] > ol > li`; link; `aria-current=page`; separator `li[aria-hidden=true]` + chevron SVG `data-rtl-flip`; ellipsis `li > span[aria-hidden=true]`. |
| Pagination | Exact nav/ul/li classes; `a.btn[data-variant=ghost|outline]`; previous/next chevrons; ellipsis `div.size-9.flex.items-center.justify-center`; no `.pagination` class. |
| Tabs | `div.tabs > nav[role=tablist] > button[role=tab]`; caller-supplied ids on `bc_tab`/`bc_tab_panel`; `aria-selected`, `tabindex`, `hidden`; `data-variant=line`, `aria-orientation`; `phx-hook="BasecoatState"` on `bc_tabs`. No slot API: the caller composes `bc_tab_list`/`bc_tab`/`bc_tab_panel`. |
| Dropdown Menu | `.dropdown-menu`; trigger `aria-haspopup=menu` and ids `#{id}-trigger`/`#{id}-menu`; popover; group/heading; `menuitem`, `menuitemcheckbox`, `menuitemradio`; separator `hr[role=separator]`; shortcut `kbd`; `phx-hook="BasecoatState"`. |
| Command | `div.command`; `dialog.command-dialog`; input `role=combobox`; list `role=menu[data-empty]`; group; item `data-filter`/`data-keywords`/`data-force`/`data-keep-command-open`; shortcut `span[data-shortcut]`; `data-filter=manual`. |
| Theme Switcher | `button.btn.size-8` with `aria-label`, `data-tooltip`, `data-side`, `data-variant=outline`, `data-size=icon`, `data-basecoat-theme-toggle`; `span.hidden.dark:block` and `span.block.dark:hidden`. |

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components/navigation_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the six modules**

Follow the spec inventory rows. `bc_tabs` is a plain `<div class="tabs">` wrapper with no slot API: the caller composes `bc_tab_list`, one `bc_tab` per tab, and one `bc_tab_panel` per panel. `bc_tab` takes `id`, `panel`, and `selected`; `bc_tab_panel` takes `id`, `labelledby`, and `hidden`. The first tab renders `aria-selected="true"` and `tabindex="0"` only when the caller marks it `selected`; the library does not guess. `bc_dropdown_menu` and `bc_command` require `id`. `bc_pagination_link` accepts `current` and renders `data-variant="outline"` when true, otherwise `ghost`.

Add all six modules to `BasecoatPhoenix.Components`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components/navigation_test.exs`
Expected: all pass.

Then append the tabs, dropdown menu, command, and theme-switcher rows to `docs/manual-verification.md` and verify them in the Task 6 browser app.

- [ ] **Step 5: Verify in the browser**

Confirm in the Task 6 app: tabs switch and the active tab survives an unrelated assign update; dropdown opens, closes on outside click, and survives an update; command filters and runs items; the theme switcher toggles `html.dark`.

- [ ] **Step 6: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components/navigation_test.exs docs/manual-verification.md
git commit -m "feat: add navigation components"
```

---

### Task 13: Overlays and Feedback

**Files:**
- Create: `lib/basecoat_phoenix/components/alert_dialog.ex`
- Create: `lib/basecoat_phoenix/components/drawer.ex`
- Create: `lib/basecoat_phoenix/components/sheet.ex`
- Create: `lib/basecoat_phoenix/components/popover.ex`
- Create: `lib/basecoat_phoenix/components/toast.ex`
- Create: `lib/basecoat_phoenix/components/carousel.ex`
- Modify: `lib/basecoat_phoenix/components.ex`
- Test: `test/basecoat_phoenix/components/overlays_test.exs`

**Interfaces:**
- Consumes: `BasecoatPhoenix.Toast.payload/1`; Task 4 hooks.
- Produces: `bc_alert_dialog/1`, `bc_alert_dialog_trigger/1`, `bc_drawer/1`, `bc_drawer_trigger/1`, `bc_sheet/1`, `bc_sheet_trigger/1`, `bc_popover/1`, `bc_popover_trigger/1`, `bc_popover_content/1`, `bc_toaster/1`, `bc_toast/1`, `bc_carousel/1`, `bc_carousel_content/1`, `bc_carousel_item/1`, `bc_carousel_previous/1`, `bc_carousel_next/1`.

- [ ] **Step 1: Write the failing tests**

Use `assert_markup/3` for each component's upstream example.

| Module | Assertions |
| --- | --- |
| Alert Dialog | `dialog.alert-dialog > div > header(h2,p) + footer`; ids; native `open`; `phx-hook="BasecoatState"`; trigger `data-basecoat-dialog-open`. |
| Drawer | `dialog.drawer[data-side]`; sides `top|right|bottom|left`; `article > header + section + footer`; `phx-hook="BasecoatState"`; trigger. |
| Sheet | `dialog.sheet[data-side=right]` default; article structure; `phx-hook="BasecoatState"`; trigger. |
| Popover | `div.popover`; trigger `aria-expanded=false`, `aria-controls`; content `div[aria-hidden=true][data-popover][data-align]`; `phx-hook="BasecoatState"`. |
| Toast | `ol#toaster.toaster[role=list][aria-label=Notifications][phx-update=ignore]`; no hook (the window listener in `basecoat_live.js` delivers pushed toasts); `bc_toast` `li.toast[data-category][data-duration] > div.toast-content[role=status|alert][aria-atomic=true] > section + footer`; error role alert. |
| Carousel | `div.carousel[role=region][aria-roledescription=carousel][aria-label]`; `ul.scrollbar[role=list][tabindex=0]`; `li` slides; direct previous/next buttons `button.btn[hidden]`; `phx-hook="BasecoatState"`. |

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/basecoat_phoenix/components/overlays_test.exs`
Expected: FAIL because the modules do not exist.

- [ ] **Step 3: Implement the six modules**

Follow the spec inventory rows. `bc_dialog`/`bc_alert_dialog`/`bc_drawer`/`bc_sheet` accept `open` and render the native `open` attribute. `bc_toaster` is fixed to `id="toaster"` and `phx-update="ignore"`. `bc_toast` renders the close button when `close_button` is true. `bc_carousel_previous`/`next` render `hidden` until Basecoat initializes.

Add all six modules to `BasecoatPhoenix.Components`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/basecoat_phoenix/components/overlays_test.exs`
Expected: all pass.

Then append the drawer, popover, toast, and carousel rows to `docs/manual-verification.md` and verify them in the Task 6 browser app.

- [ ] **Step 5: Verify in the browser**

Confirm in the Task 6 app: drawer and sheet open from their triggers and close on backdrop; popover toggles; a pushed toast appears in `#toaster` and survives an update; carousel previous/next appear after init and scroll.

- [ ] **Step 6: Commit**

```bash
git add lib/basecoat_phoenix/components.ex lib/basecoat_phoenix/components test/basecoat_phoenix/components/overlays_test.exs docs/manual-verification.md
git commit -m "feat: add overlay and feedback components"
```

---

### Task 14: Docs, Pattern Tests, and Final Verification

**Files:**
- Create: `README.md`
- Create: `docs/manual-verification.md`
- Create: `test/basecoat_phoenix/patterns_test.exs`
- Modify: `mix.exs` (docs config if needed)
- Test: `test/basecoat_phoenix/patterns_test.exs`

**Interfaces:**
- Consumes: all previous tasks.
- Produces: install/usage docs, manual browser checklist, pattern absence tests, clean format/compile/test.

- [ ] **Step 1: Write the failing pattern test and manual checklist**

`test/basecoat_phoenix/patterns_test.exs`:

```elixir
test "pattern pages do not ship components" do
  for module <- ~w(Direction AspectRatio ScrollArea DataTable Tooltip) do
    refute Code.ensure_loaded?(Module.concat(BasecoatPhoenix.Components, module))
  end
end
```

`docs/manual-verification.md` already exists from Task 6. Append to it:
- All 15 Basecoat controllers: accordion, carousel, chart, code block, combobox, command, drawer, dropdown menu, input OTP, popover, range, select, sidebar, tabs, toast.
- Patch-preservation cases: open dropdown + unrelated assign, switched tab + update, selected value + update, open dialog + update, toast + update, OTP + update.
- Nested LiveView toast reaches root `#toaster`.
- Server changes select/combobox options and value.
- Malformed/empty JSON multi-value submission does not crash.

`README.md` must include:
- `mix basecoat.install` usage and `--replace-ui` warning.
- `use BasecoatPhoenix.Components` in `html_helpers`.
- One component example.
- The taxonomy: 51 upstream components, 1 convenience helper (`bc_spinner`), 5 pattern pages.
- CSP note (no inline handlers).
- Chart.js external dependency.
- Patch-preservation escape hatch: a server value equal to the client's baseline is not applied; change a nonce attribute or re-render the subtree to force it.
- Supported versions.

- [ ] **Step 2: Run the pattern guard test**

Run: `mix test test/basecoat_phoenix/patterns_test.exs`
Expected: PASS. This is a guard test: it fails only if a pattern module (`Direction`, `AspectRatio`, `ScrollArea`, `DataTable`, `Tooltip`) is added later.

- [ ] **Step 3: Run the full verification**

```bash
mix format
mix format --check-formatted
mix compile --warnings-as-errors
mix test
```

Expected: format clean, compile clean, all tests pass.

- [ ] **Step 4: Walk the manual checklist to completion**

Reuse the browser app started in Task 6. Render every component from the test suite in it, then walk `docs/manual-verification.md` end to end, including a second installer run. Fix any mismatch in the library, not in the sample app.

- [ ] **Step 5: Commit**

```bash
git add README.md docs/manual-verification.md test/basecoat_phoenix/patterns_test.exs
git commit -m "docs: add usage, patterns, and manual verification"
```