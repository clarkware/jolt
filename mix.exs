defmodule Jolt.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jolt,
      name: "Jolt",
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/clarkware/jolt",
      description: description()
    ]
  end

  def application do
    [applications: [:logger, :poison, :cowboy, :plug]]
  end

  defp deps do
    [
      { :poison, "~> 1.5" },
      { :cowboy, "~> 1.0" },
      { :plug, "~> 1.1" }
    ]
  end

  defp description do
    """
    A full REST JSON API with zero coding, powered by Elixir.

    It is intended to be used as a command-line tool 
    (just run mix escript.build first).
    """
  end

  defp package do
    [
      maintainers: [ "Mike Clark"],
      files:       [ "lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md" ],
      licenses:    ["MIT"],
      links:       %{github: "https://github.com/clarkware/jolt"},
    ]
  end

  defp escript_config do
    [main_module: Jolt.CLI]
  end

end
