defmodule BasecoatPhoenix.FormsTest do
  use ExUnit.Case, async: true

  test "encode_selection encodes multiple values as JSON" do
    assert BasecoatPhoenix.Forms.encode_selection(["apple", "banana"], "value") ==
             ~s(["apple","banana"])
  end

  test "encode_selection encodes object format" do
    assert BasecoatPhoenix.Forms.encode_selection([%{value: "a", label: "A"}], "object") ==
             ~s([{"label":"A","value":"a"}])
  end

  test "decode_multi handles empty, malformed, strings, and maps" do
    assert BasecoatPhoenix.Forms.decode_multi(nil) == []
    assert BasecoatPhoenix.Forms.decode_multi("") == []
    assert BasecoatPhoenix.Forms.decode_multi("not json") == []
    assert BasecoatPhoenix.Forms.decode_multi(~s(["a","b"])) == ["a", "b"]

    assert BasecoatPhoenix.Forms.decode_multi(~s([{"value":"a","label":"A"}])) ==
             [%{"label" => "A", "value" => "a"}]
  end
end
