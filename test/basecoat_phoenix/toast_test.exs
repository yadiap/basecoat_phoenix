defmodule BasecoatPhoenix.ToastTest do
  use ExUnit.Case, async: true

  test "payload converts snake_case options to Basecoat keys" do
    payload =
      BasecoatPhoenix.Toast.payload(
        title: "Saved",
        close_button: false,
        category: :success,
        duration: 4000
      )

    assert payload == %{
             "title" => "Saved",
             "closeButton" => false,
             "category" => "success",
             "duration" => 4000
           }
  end

  test "payload keeps action labels and hrefs without onclick" do
    payload =
      BasecoatPhoenix.Toast.payload(
        title: "Saved",
        action: %{label: "Undo", href: "/undo", onclick: "x"},
        cancel: %{label: "Dismiss"}
      )

    assert payload["action"] == %{"label" => "Undo", "href" => "/undo"}
    assert payload["cancel"] == %{"label" => "Dismiss"}
  end
end
