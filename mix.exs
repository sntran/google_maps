defmodule GoogleMaps.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.strip

  def project do
    [app: :google_maps,
     description: "A Google Maps API in Elixir",
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 3.0"},
      {:httpoison, "~> 0.10.0"}
    ]
  end

  defp package do
    [files: ~w(lib mix.exs README.md LICENSE.md VERSION),
     maintainers: ["Son Tran-Nguyen"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sntran/ex_maps"}]
  end
end
