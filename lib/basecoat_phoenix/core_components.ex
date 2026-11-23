defmodule BasecoatPhoenix.CoreComponents do
  @moduledoc """
  Drop-in replacement for the `CoreComponents` module that `mix phx.new`
  generates for Phoenix 1.8.

  Existing templates keep working: the same function names, attributes, slots,
  and return contracts, rendered with Basecoat markup instead of daisyUI.

      # lib/my_app_web/components/core_components.ex
      defmodule MyAppWeb.CoreComponents do
        @moduledoc "Basecoat-backed core components."

        use BasecoatPhoenix.CoreComponents,
          gettext_backend: MyAppWeb.Gettext
      end

  That is the whole migration. `MyAppWeb` keeps
  `import MyAppWeb.CoreComponents`, and every `<.button>`, `<.input>`,
  `<.table>`, `<.list>`, `<.header>`, `<.flash>`, and `<.icon>` call site is
  untouched.

  `mix basecoat.install --replace-ui` writes this file for you: it keeps your
  module name and Gettext backend and saves the generated module as
  `core_components.ex.bak`.

  Delete the rest of the generated module. Keep your own additions by putting
  them after the `use`.

  ## Options

    * `:gettext_backend` - the Gettext backend used by `translate_error/1` and
      `translate_errors/2`. Omit it to interpolate messages without Gettext.

  ## What changes visually

  `button/1` renders Basecoat's `btn`. `input/1` renders Basecoat `fieldset`,
  `field`, `label`, `input`, `select`, and `textarea` markup. `table/1`
  renders a Basecoat table inside a scroll container. `flash/1` renders a
  Basecoat alert pinned to the inline end of the viewport.

  ## Deliberate differences from the generated module

    * A caller `class` is appended to the Basecoat classes instead of replacing
      them. The generated module lets `class="w-full"` silently drop `btn`;
      appending keeps the component styled during the migration.
    * `:error_class` is accepted and ignored. Basecoat styles invalid inputs
      through `aria-invalid`, so there is no error class to override.
    * `icon/1` is unchanged. It still takes `hero-*` names and emits the class
      for the Heroicons Tailwind plugin that `phx.new` configures. Basecoat's
      own components use Lucide icons; both can coexist until you drop the
      plugin.
    * The flash close label and the table action header are plain strings, not
      Gettext calls, because they render inside this module rather than the
      caller's.
  """

  use Phoenix.Component

  use BasecoatPhoenix.Components
  import BasecoatPhoenix.Components.Semantic, only: [classes: 1]

  alias Phoenix.LiveView.JS

  @doc false
  # Gettext-less fallback: replace `%{key}` placeholders with the values.
  def interpolate(message, opts) do
    Enum.reduce(opts, to_string(message), fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  @doc """
  Renders flash notices as a Basecoat alert in the corner of the viewport.
  """
  attr(:id, :string, doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed top-4 end-4 z-50 w-80 max-w-80 text-wrap sm:w-96 sm:max-w-96"
      {@rest}
    >
      <.bc_alert variant={if(@kind == :error, do: "destructive")} class="w-full">
        <:icon>
          <.icon
            name={(@kind == :error && "hero-exclamation-circle") || "hero-information-circle"}
            class="size-5 shrink-0"
          />
        </:icon>
        <.bc_alert_title :if={@title}>{@title}</.bc_alert_title>
        <.bc_alert_description>{msg}</.bc_alert_description>
        <.bc_alert_actions>
          <button type="button" class="cursor-pointer" aria-label="close">
            <.icon name="hero-x-mark" class="size-5 opacity-40 hover:opacity-70" />
          </button>
        </.bc_alert_actions>
      </.bc_alert>
    </div>
    """
  end

  @doc """
  Renders a button with navigation support, using Basecoat's `btn` class.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"}>Home</.button>
  """
  attr(:rest, :global, include: ~w(href navigate patch method download name value disabled))
  attr(:class, :any)
  attr(:variant, :string, values: ~w(primary))
  slot(:inner_block, required: true)

  def button(%{rest: rest} = assigns) do
    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link
        class={classes(["btn", assigns[:class]])}
        data-variant={assigns[:variant] || "primary"}
        {@rest}
      >
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button
        class={classes(["btn", assigns[:class]])}
        data-variant={assigns[:variant] || "primary"}
        {@rest}
      >
        {render_slot(@inner_block)}
      </button>
      """
    end
  end

  @doc """
  Renders an input with label and error messages.

  Accepts a `Phoenix.HTML.FormField`, a `type="select"` with `options`, a
  `type="textarea"`, a `type="checkbox"`, and every native input type.
  `:error_class` is accepted for compatibility and ignored: Basecoat styles
  invalid inputs through `aria-invalid`.
  """
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:label, :string, default: nil)
  attr(:value, :any)

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:errors, :list, default: [])
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")
  attr(:class, :any, default: nil, doc: "the input class to use over defaults")
  attr(:error_class, :any, default: nil, doc: "accepted for compatibility and ignored")

  attr(:rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)
  )

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={assigns[:value]} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="fieldset mb-2">
      <input
        type="hidden"
        name={@name}
        value="false"
        disabled={@rest[:disabled]}
        form={@rest[:form]}
      />
      <.bc_checkbox
        id={@id}
        name={@name}
        value="true"
        checked={@checked}
        class={@class}
        disabled={@rest[:disabled]}
        {@rest}
      >
        {@label}
      </.bc_checkbox>
      <.bc_field_error :for={msg <- @errors} id={@id}>{msg}</.bc_field_error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="fieldset mb-2">
      <.bc_field_label :if={@label} for={@id}>{@label}</.bc_field_label>
      <.bc_native_select
        id={@id}
        name={@name}
        multiple={@multiple}
        class={@class}
        aria-invalid={if(@errors != [], do: "true")}
        aria-describedby={if(@errors != [], do: "#{@id}-error")}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, assigns[:value])}
      </.bc_native_select>
      <.bc_field_error :for={msg <- @errors} id={@id}>{msg}</.bc_field_error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="fieldset mb-2">
      <.bc_field_label :if={@label} for={@id}>{@label}</.bc_field_label>
      <.bc_textarea
        id={@id}
        name={@name}
        value={Phoenix.HTML.Form.normalize_value("textarea", assigns[:value])}
        errors={@errors}
        class={@class}
        {@rest}
      />
      <.bc_field_error :for={msg <- @errors} id={@id}>{msg}</.bc_field_error>
    </div>
    """
  end

  # All other inputs: text, email, password, number, date, ...
  def input(assigns) do
    ~H"""
    <div class="fieldset mb-2">
      <.bc_field_label :if={@label} for={@id}>{@label}</.bc_field_label>
      <.bc_input
        type={@type}
        id={@id}
        name={@name}
        value={Phoenix.HTML.Form.normalize_value(@type, assigns[:value])}
        errors={@errors}
        class={@class}
        {@rest}
      />
      <.bc_field_error :for={msg <- @errors} id={@id}>{msg}</.bc_field_error>
    </div>
    """
  end

  @doc """
  Renders a header with title.
  """
  slot(:inner_block, required: true)
  slot(:subtitle)
  slot(:actions)

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", "pb-4"]}>
      <div>
        <h1 class="text-lg font-semibold leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-sm text-muted-foreground">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders a table with Basecoat styling and generic row handling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)
  attr(:row_id, :any, default: nil, doc: "the function for generating the row id")
  attr(:row_click, :any, default: nil, doc: "the function for handling phx-click on each row")

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"
  )

  slot :col, required: true do
    attr(:label, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column")

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <.bc_table_container>
      <.bc_table>
        <.bc_table_header>
          <.bc_table_row>
            <.bc_table_head :for={col <- @col} scope="col">{col[:label]}</.bc_table_head>
            <.bc_table_head :if={@action != []}>
              <span class="sr-only">Actions</span>
            </.bc_table_head>
          </.bc_table_row>
        </.bc_table_header>
        <.bc_table_body
          id={@id}
          phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
        >
          <.bc_table_row :for={row <- @rows} id={@row_id && @row_id.(row)}>
            <.bc_table_cell
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={@row_click && "cursor-pointer"}
            >
              {render_slot(col, @row_item.(row))}
            </.bc_table_cell>
            <.bc_table_cell :if={@action != []} class="w-0">
              <div class="flex gap-4">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </.bc_table_cell>
          </.bc_table_row>
        </.bc_table_body>
      </.bc_table>
    </.bc_table_container>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <ul role="list" class="divide-y divide-border">
      <li :for={item <- @item} class="flex flex-col gap-1 py-3">
        <div class="font-medium">{item.title}</div>
        <div class="text-sm text-muted-foreground">{render_slot(item)}</div>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Kept from the generated module: Basecoat's own components use Lucide icons,
  but existing `hero-*` call sites resolve through the Heroicons Tailwind
  plugin that `phx.new` already configures.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr(:name, :string, required: true)
  attr(:class, :any, default: "size-4")

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """
  Translates an error message without Gettext, interpolating the options.
  """
  def translate_error({msg, opts}) do
    interpolate(msg, opts)
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  @doc false
  # Re-emits this module's declarative metadata and delegates to it, so the
  # caller's module owns the same `attr`/`slot` contract. HEEx reads the
  # metadata of the module named at the call site, so a bare `defdelegate`
  # would lose every default and every compile-time validation.
  defmacro __using__(opts \\ []) do
    backend = Keyword.get(opts, :gettext_backend)

    components = BasecoatPhoenix.CoreComponents.__components__()
    names = components |> Map.keys() |> Enum.sort()
    overridable = Enum.map(names, &{&1, 1})

    declarations =
      for {name, meta} <- Enum.sort_by(components, fn {name, _} -> name end) do
        attrs = Enum.map(meta.attrs, &declare_attr/1)
        slots = Enum.map(meta.slots, &declare_slot/1)

        quote do
          unquote_splicing(attrs)
          unquote_splicing(slots)

          def unquote(name)(assigns) do
            BasecoatPhoenix.CoreComponents.unquote(name)(assigns)
          end
        end
      end

    quote do
      use Phoenix.Component

      use BasecoatPhoenix.Components

      alias Phoenix.LiveView.JS

      unquote_splicing(declarations)

      defoverridable unquote(Macro.escape(overridable))

      def show(js \\ %JS{}, selector),
        do: BasecoatPhoenix.CoreComponents.show(js, selector)

      def hide(js \\ %JS{}, selector),
        do: BasecoatPhoenix.CoreComponents.hide(js, selector)

      defoverridable show: 1, show: 2, hide: 1, hide: 2

      @doc """
      Translates an error message, using Gettext when a backend is configured.
      """
      def translate_error({msg, opts}) do
        case unquote(backend) do
          nil ->
            BasecoatPhoenix.CoreComponents.interpolate(msg, opts)

          backend ->
            if count = opts[:count] do
              apply(Gettext, :dngettext, [backend, "errors", msg, msg, count, opts])
            else
              apply(Gettext, :dgettext, [backend, "errors", msg, opts])
            end
        end
      end

      @doc """
      Translates the errors for a field from a keyword list of errors.
      """
      def translate_errors(errors, field) when is_list(errors) do
        for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
      end

      defoverridable translate_error: 1, translate_errors: 2
    end
  end

  @doc false
  def declare_attr(attr) do
    opts =
      attr.opts
      |> maybe_put(:doc, attr.doc)
      |> maybe_put(:required, attr.required || nil)

    # Metadata stores struct types as `{:struct, Mod}`; `attr/3` wants the module.
    type = with {:struct, mod} <- attr.type, do: mod

    quote do
      attr(unquote(attr.name), unquote(type), unquote(Macro.escape(opts)))
    end
  end

  @doc false
  def declare_slot(slot) do
    opts =
      slot.opts
      |> maybe_put(:doc, slot.doc)
      |> maybe_put(:required, slot.required || nil)

    block = Enum.map(slot.attrs, &declare_attr/1)

    quote do
      slot(unquote(slot.name), unquote(Macro.escape(opts)), do: unquote(block))
    end
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)
end
