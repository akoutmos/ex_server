defmodule ExServer.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ex_server,
      version: @version,
      elixir: "~> 1.12",
      name: "Mix Server",
      source_url: "https://github.com/akoutmos/ex_server",
      homepage_url: "https://hex.pm/packages/ex_server",
      description: "This mix task allows you to start a server anywhere on the file system and serve files.",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExServer.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: "ex_server",
      files: ~w(archives lib priv mix.exs README.md LICENSE),
      licenses: ["MIT"],
      maintainers: ["Alex Koutmos"],
      links: %{
        "GitHub" => "https://github.com/akoutmos/ex_server",
        "Sponsor" => "https://github.com/sponsors/akoutmos"
      }
    ]
  end

  # Specifies your project dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.6.6"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.3", only: :dev, runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1", only: :dev, runtime: Mix.env() == :dev},
      {:heex_formatter, github: "feliperenan/heex_formatter", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.3"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["esbuild default --minify", "tailwind default --minify", "phx.digest"],
      build: [&build_release/1]
    ]
  end

  defp build_release(_) do
    # Build the static assets using dev deps
    Mix.env(:dev)
    Mix.Task.run("assets.deploy", [])

    # Archive the library for production deploy
    Mix.env(:prod)
    Mix.Task.run("archive.build", ["-o", "archives/ex_server-#{@version}.ez"])
  end
end
