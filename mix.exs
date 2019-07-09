defmodule GoogleMaps.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.trim()

  def project do
    [
      app: :google_maps,
      description: "A Google Maps API in Elixir",
      version: @version,
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "GoogleMaps",
      source_url: "https://github.com/sntran/ex_maps",
      homepage_url: "https://hex.pm/packages/google_maps/",
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :httpoison],
      env: [requester: HTTPoison]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

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
      {:httpoison, "~>1.5"},
      {:jason, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:bypass, "~> 1.0", only: :test}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE.md VERSION),
      maintainers: ["Son Tran-Nguyen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sntran/ex_maps"}
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "GoogleMaps",
      extras: ["README.md"]
    ]
  end
end
