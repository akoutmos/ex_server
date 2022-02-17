defmodule Mix.Tasks.Server do
  @moduledoc """
  This Mix task is used to start an HTTP server from the current working
  directory. If the directory contains an `index.html` or `index.htm` file
  then that file will be served. Else a file explorer will be presented.

  The valid CLI arguments include:

  ```
  --port   The port that the server should run on (default is 4040)
  ```
  """

  use Mix.Task

  @shortdoc "Start an HTTP server from the current working directory"

  @version Mix.Project.config()[:version]
  @server_deps Mix.Project.config()[:deps]

  @switches [
    port: :integer
  ]

  @impl true
  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("""
    HTTP Server v#{@version}

    If you use some my open source libraries and projects
    and  want to ensure their continued development,
    be sure to sponsor my work so that I can allocate
    more time to open source development.

    https://github.com/sponsors/akoutmos
    """)
  end

  def run(args) do
    # Parse the cli args
    port = parse_port(args)

    # Set the Mix env
    Mix.env(:prod)

    # Supporting lib and runtime configuration
    Application.put_env(:phoenix, :json_library, Jason)
    Application.put_env(:logger, :console, level: :info)

    # Configure logger
    Logger.configure_backend(:console,
      format: "$time $metadata[$level] $message\n",
      metadata: [:request_id],
      level: :info
    )

    # Configure the endpoint server
    Application.put_env(:ex_server, ExServerWeb.Endpoint,
      http: [ip: {127, 0, 0, 1}, port: port],
      server: true,
      secret_key_base: String.duplicate("a", 64),
      cache_static_manifest: "priv/static/cache_manifest.json",
      live_view: [signing_salt: "FtRh_twgiYg7vABG"]
    )

    # Install production dependencies
    @server_deps
    |> Enum.filter(fn
      {package, version} when is_atom(package) and is_binary(version) -> true
      _ -> false
    end)
    |> Mix.install()

    # Start the Phoenix server
    {:ok, _} = Supervisor.start_link([ExServerWeb.Endpoint], strategy: :one_for_one)
    Process.sleep(:infinity)
  end

  defp parse_port(args) do
    args
    |> OptionParser.parse(strict: @switches)
    |> case do
      {[port: port], [], []} ->
        port

      {[], [], []} ->
        4040

      _ ->
        raise "Invalid CLI arguments provided. Run `mix help server` for the help menu"
    end
  end
end
