defmodule BasecoatPhoenix.Components.AvatarFixture do
  @moduledoc false
  use Phoenix.Component
  import BasecoatPhoenix.Components.Avatar

  def avatar(assigns) do
    ~H"""
    <.bc_avatar size="lg">
      <.bc_avatar_image src="https://github.com/shadcn.png" alt="@shadcn" />
      <.bc_avatar_fallback>CN</.bc_avatar_fallback>
      <.bc_avatar_badge></.bc_avatar_badge>
    </.bc_avatar>
    """
  end

  def group(assigns) do
    ~H"""
    <.bc_avatar_group>
      <.bc_avatar>
        <.bc_avatar_fallback>CN</.bc_avatar_fallback>
      </.bc_avatar>
    </.bc_avatar_group>
    """
  end
end

defmodule BasecoatPhoenix.Components.AvatarTest do
  use BasecoatPhoenix.ComponentCase

  test "bc_avatar matches the upstream avatar markup" do
    assert_markup(&BasecoatPhoenix.Components.AvatarFixture.avatar/1, %{}, ~S"""
    <span class="avatar" data-size="lg">
      <img src="https://github.com/shadcn.png" alt="@shadcn" />
      <span>CN</span>
      <span class="avatar-badge"></span>
    </span>
    """)
  end

  test "bc_avatar_group matches the upstream group markup" do
    assert_markup(&BasecoatPhoenix.Components.AvatarFixture.group/1, %{}, ~S"""
    <div class="avatar-group">
      <span class="avatar"><span>CN</span></span>
    </div>
    """)
  end
end
