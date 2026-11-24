defmodule BasecoatPhoenix.AssetsTest do
  use ExUnit.Case, async: true

  @hashes %{
    "all.min.js" => "41f572dede3365378781fae9f0d1218f2ae2783f1a5496ace26bb67fda2e6b6b",
    "basecoat-luma.bundle.css" =>
      "ab1de0317df65cc619e4210cc90a3c1b4e6d116b1be6c6522b4dff13c45193c3",
    "basecoat-lyra.bundle.css" =>
      "a284b003d543ce0b59c3415c87f1181e2ff7a7976c70b6f4537e15202f5c34bc",
    "basecoat-maia.bundle.css" =>
      "dc4e701d03e9d60963255b0dfdc5ee86192613ed26317a6096db890bbd238e18",
    "basecoat-mira.bundle.css" =>
      "4c479549e5e8cf7585973937c9530cf40ba5c4f03d5cffd81ee00ee5a9320129",
    "basecoat-nova.bundle.css" =>
      "97af5d3b44fc4bf5c42c0bf7d2a129b0d93e60dfe5d4fb042698075915c9682f",
    "basecoat-rhea.bundle.css" =>
      "fc14205c20f060aa7736271010ff1012f7aea2ce93d5278ae59e7c60b5fce3c2",
    "basecoat-sera.bundle.css" =>
      "cf796e7ff1e9106565ac9b7a8297db353363bceba59437bc1a5b63355f0c6f50",
    "basecoat-vega.bundle.css" =>
      "2d03cf002af5a9e191613a76bb871f5b35c87a45f878203bd8cdf114c500b031",
    "chart.min.js" => "4e82a2bc45d8ae9f5fc74341d38e71b6bfd4d691075f0cd08fd8ed6b01feff5c",
    "chart.umd.min.js" => "87364cc2b2a76a6684929e7d6b80b18a897794db38400caff1fcf1791c6925d2",
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

  test "version file is 1.3.0" do
    dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])
    assert File.read!(Path.join(dir, "VERSION")) |> String.trim() == "1.3.0"
  end

  # 1.3.0 moved the badge icon padding, tooltip focus, and active-item colors
  # into every style pack. A partial copy would leave some packs behind.
  test "every style bundle carries the 1.3.0 rules" do
    dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])

    for style <- ~w(luma lyra maia mira nova rhea sera vega) do
      css = File.read!(Path.join(dir, "basecoat-#{style}.bundle.css"))

      # Sera draws badges as borderless uppercase labels with no padding, so it
      # has no icon padding to adjust.
      if style != "sera" do
        assert css =~ "has-[[data-icon='inline-start']]:ps-1.5",
               "#{style}: badge icon start padding missing"

        assert css =~ "has-[[data-icon='inline-end']]:pe-1.5",
               "#{style}: badge icon end padding missing"
      end

      assert css =~ "&:focus-visible:before",
             "#{style}: tooltip keyboard focus missing"

      assert css =~ "focus-visible:bg-accent focus-visible:text-accent-foreground",
             "#{style}: dropdown active item still uses the muted color"

      assert css =~
               ".select:not(select) [role='option'].active,\n  .select:not(select) [role='option']:focus-visible {\n    @apply bg-accent",
             "#{style}: select active option still uses the muted color"
    end
  end

  # LiveView's join patch drops Basecoat's init markers. A plain initAll on
  # phx:page-loading-stop then adds a second click listener, and clicks toggle
  # the component twice (open then close).
  # shortcut: this guards the source string, not the browser behavior; move to
  # a browser or jsdom test if the project gains a JS test harness.
  test "the state hook re-inits once with force" do
    dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])
    js = File.read!(Path.join(dir, "basecoat_live.js"))

    assert js =~ "initAll?.({ force: true })"
    refute js =~ ~s("phx:page-loading-stop")
  end

  @skins ~w(clean-slate modern-minimal sunset-horizon supabase t3-chat vercel)

  test "skins.css ships every palette in light and dark" do
    dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])
    css = File.read!(Path.join(dir, "skins.css"))

    for skin <- @skins do
      assert css =~ ~s|html[data-skin="#{skin}"] {|
      assert css =~ ~s|html[data-skin="#{skin}"].dark {|
    end

    refute css =~ ~s|html[data-skin="default"]|

    for token <- ~w(--background --foreground --card --card-foreground --popover
                   --popover-foreground --primary --primary-foreground --secondary
                   --secondary-foreground --muted --muted-foreground --accent
                   --accent-foreground --destructive --border --input --ring
                   --chart-1 --chart-5 --sidebar --sidebar-ring --radius
                   --font-sans --font-mono) do
      assert css =~ token
    end
  end

  # The light selector (0,1,1) outranks Basecoat's .dark (0,1,0), so a token
  # missing from a palette's dark block would silently keep its light value.
  test "every palette defines the same tokens in its dark block" do
    dir = Path.join([:code.priv_dir(:basecoat_phoenix), "basecoat"])
    css = File.read!(Path.join(dir, "skins.css"))

    for skin <- @skins do
      assert tokens(css, ~s|html[data-skin="#{skin}"]|) ==
               tokens(css, ~s|html[data-skin="#{skin}"].dark|)
    end
  end

  defp tokens(css, selector) do
    [_, body] = Regex.run(~r/#{Regex.escape(selector)}\s*\{([^}]*)\}/, css)

    ~r/--([a-z0-9-]+):/
    |> Regex.scan(body, capture: :all_but_first)
    |> List.flatten()
    |> Enum.sort()
  end
end
