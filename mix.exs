defmodule SimpleFilters.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_filters,
      version: "1.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      description: description(),
      package: package(),
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.lcov": :test
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dummy, "~> 2.0", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "Simple filters for Ecto from query params."
  end

  defp package do
    [
      name: :simple_filters,
      files: ~w(mix.exs lib .formatter.exs README.md LICENSE),
      maintainers: ["nomorepanic"],
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => "https://github.com/strangemachines/simple_filters"}
    ]
  end
end
