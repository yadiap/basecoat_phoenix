defmodule BasecoatPhoenix.CoreComponentsFixture do
  @moduledoc false
  # Renders the stock Phoenix 1.8 `CoreComponents` call shapes through real HEEx
  # call sites, which is how an app reaches the drop-in.
  use BasecoatPhoenix.CoreComponents

  def buttons(assigns) do
    ~H"""
    <.button>Save</.button>
    <.button variant="primary" class="w-full">Save</.button>
    <.button navigate="/">Home</.button>
    <.button phx-click="go" disabled>Off</.button>
    """
  end

  def texts(assigns) do
    ~H"""
    <.input id="email" name="email" label="Email" value="a@b.c" />
    <.input id="hidden" name="hidden" type="hidden" value="1" />
    <.input id="bio" name="bio" type="textarea" label="Bio" value="hi" />
    """
  end

  def select(assigns) do
    ~H"""
    <.input
      id="fruit"
      name="fruit"
      label="Fruit"
      type="select"
      prompt="Pick one"
      options={[{"Apple", "apple"}, {"Banana", "banana"}]}
      value="banana"
    />
    """
  end

  def checkbox(assigns) do
    ~H"""
    <.input id="terms" name="terms" type="checkbox" label="Accept" />
    """
  end

  def field(assigns) do
    ~H"""
    <.input field={@form[:email]} type="email" />
    """
  end

  def table_demo(assigns) do
    ~H"""
    <.table id="users" rows={@rows} row_id={&"user-#{&1.id}"} row_click={&"pick-#{&1.id}"}>
      <:col :let={user} label="ID">{user.id}</:col>
      <:col :let={user} label="Name">{user.name}</:col>
      <:action :let={user}>edit-{user.id}</:action>
    </.table>
    """
  end

  def list_demo(assigns) do
    ~H"""
    <.list>
      <:item title="Title">Post</:item>
      <:item title="Views">42</:item>
    </.list>
    """
  end

  def header_demo(assigns) do
    ~H"""
    <.header>
      Users
      <:subtitle>All of them</:subtitle>
      <:actions><.button>New</.button></:actions>
    </.header>
    """
  end

  def flash_demo(assigns) do
    ~H"""
    <.flash kind={:info} flash={@flash} />
    <.flash kind={:error} flash={@flash} title="Heads up" />
    """
  end

  def icons(assigns) do
    ~H"""
    <.icon name="hero-x-mark" />
    <.icon name="hero-arrow-path" class="ml-1 size-3" />
    """
  end
end

defmodule BasecoatPhoenix.CoreComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component, only: [to_form: 2]
  import Phoenix.LiveViewTest

  alias BasecoatPhoenix.CoreComponents
  alias BasecoatPhoenix.CoreComponentsFixture, as: Fixture

  # daisyUI classes the generated Phoenix 1.8 components emit.
  @daisy ~w(btn-primary btn-soft alert-info alert-error input-bordered input-error
            textarea-bordered select-bordered select-error table-zebra checkbox-sm
            toast-top toast-end list-row text-base-content)

  defp shape(fun, assigns \\ %{}) do
    render_component(&apply(Fixture, fun, [&1]), assigns)
  end

  test "button renders Basecoat's btn and keeps a caller class" do
    html = shape(:buttons)

    assert html =~ ~s{class="btn"}
    assert html =~ ~s{class="btn w-full"}
    assert html =~ ~s{data-variant="primary"}
    assert html =~ ~s{href="/"}
    assert html =~ "disabled"
    assert count(html, "btn") == 4
  end

  test "input renders text, hidden, and textarea" do
    html = shape(:texts)

    assert html =~ ~s{class="input"}
    assert html =~ ~s{value="a@b.c"}
    assert html =~ ~s{type="hidden"}
    assert html =~ ~s{class="textarea"}
    assert html =~ "Bio"
  end

  test "input renders a select with the prompt and the selected value" do
    html = shape(:select)

    assert html =~ ~s{class="select"}
    assert html =~ "Pick one"
    assert html =~ ~s{selected value="banana"}
  end

  test "input renders a checkbox after the hidden false input" do
    html = shape(:checkbox)

    false_at = index_of(html, ~s{value="false"})
    true_at = index_of(html, ~s{value="true"})

    assert false_at && true_at
    assert false_at < true_at
    assert html =~ ~s{type="checkbox"}
    assert html =~ "Accept"
  end

  test "input reads a form field and shows its errors" do
    form = to_form(%{"email" => ""}, errors: [email: {"can't be blank", []}])
    html = shape(:field, %{form: form})

    assert html =~ ~s{name="email"}
    assert html =~ ~s{aria-invalid="true"}
    assert html =~ "can&#39;t be blank"
  end

  test "table renders columns, row ids, row click, and actions" do
    html = shape(:table_demo, %{rows: [%{id: 1, name: "Ada"}, %{id: 2, name: "Grace"}]})

    assert html =~ ~s{class="table-container"}
    assert html =~ ~s{class="table"}
    assert html =~ "<th"
    assert html =~ "ID"
    assert html =~ ~s{id="user-1"}
    assert html =~ "pick-1"
    assert html =~ "edit-2"
  end

  test "list and header" do
    assert shape(:list_demo) =~ "Post"
    assert shape(:list_demo) =~ "42"

    header = shape(:header_demo)
    assert header =~ "<header"
    assert header =~ "All of them"
    assert header =~ "New"
  end

  test "flash renders a Basecoat alert and nothing when empty" do
    html = shape(:flash_demo, %{flash: %{"info" => "Saved", "error" => "Boom"}})

    assert count(html, ~s{role="alert"}) == 2
    assert html =~ ~s{class="alert}
    assert html =~ "Saved"
    assert html =~ ~s{data-variant="destructive"}
    assert html =~ "Heads up"

    assert String.trim(shape(:flash_demo, %{flash: %{}})) == ""
  end

  test "icon still emits heroicons classes" do
    html = shape(:icons)
    assert html =~ ~s{class="hero-x-mark size-4"}
    assert html =~ ~s{class="hero-arrow-path ml-1 size-3"}
  end

  test "no daisyUI class survives" do
    html =
      [
        shape(:buttons),
        shape(:texts),
        shape(:select),
        shape(:checkbox),
        shape(:table_demo, %{rows: [%{id: 1, name: "Ada"}]}),
        shape(:list_demo),
        shape(:header_demo),
        shape(:flash_demo, %{flash: %{"info" => "Saved", "error" => "Boom"}})
      ]
      |> Enum.join()

    for class <- @daisy do
      refute html =~ class, "expected #{class} to be gone after the migration"
    end
  end

  test "show and hide are JS commands" do
    assert %Phoenix.LiveView.JS{} = CoreComponents.show("#flash")
    assert %Phoenix.LiveView.JS{} = CoreComponents.hide("#flash")
  end

  test "translate_error interpolates without a gettext backend" do
    assert CoreComponents.translate_error({"is invalid", []}) == "is invalid"

    assert CoreComponents.translate_error({"should be at least %{count} character(s)", count: 3}) ==
             "should be at least 3 character(s)"
  end

  test "translate_error ignores bindings the message does not use" do
    # Ecto's unsafe_validate_unique adds `fields: [:email]`, a list. Gettext
    # never stringifies it because the message has no placeholder for it.
    assert CoreComponents.translate_error({"has already been taken", fields: [:email]}) ==
             "has already been taken"
  end

  test "input keeps the stock attribute order" do
    form = to_form(%{"email" => "a@b.c"}, as: :user)
    html = shape(:field, %{form: form})

    assert html =~ ~s{<input type="email" name="user[email]" id="user_email" value="a@b.c"}
  end

  test "translate_errors filters by field" do
    errors = [email: {"can't be blank", []}, name: {"too short", []}]
    assert CoreComponents.translate_errors(errors, :email) == ["can't be blank"]
  end

  defp count(html, needle), do: html |> String.split(needle) |> length() |> Kernel.-(1)

  defp index_of(html, needle) do
    case :binary.match(html, needle) do
      {pos, _} -> pos
      :nomatch -> nil
    end
  end
end

defmodule BasecoatPhoenix.CoreComponentsOverrideFixture do
  @moduledoc false
  # A caller can replace any injected component after `use`; the attrs stay.
  use BasecoatPhoenix.CoreComponents

  def flash(assigns) do
    ~H"""
    <p class="custom-flash">{Phoenix.Flash.get(@flash, @kind)}</p>
    """
  end
end

defmodule BasecoatPhoenix.CoreComponentsOverrideTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "a caller can override an injected component" do
    html =
      render_component(&BasecoatPhoenix.CoreComponentsOverrideFixture.flash/1, %{
        kind: :info,
        flash: %{"info" => "Saved"}
      })

    assert html == ~s{<p class="custom-flash">Saved</p>}
  end
end
