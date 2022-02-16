defmodule Mix.Tasks.Server do
  @moduledoc """
  This Mix task is used to start an HTTP server from the
  current working directory
  """

  use Mix.Task

  @version Mix.Project.config()[:version]
  @server_deps Mix.Project.config()[:deps]

  @shortdoc "Start an HTTP server from the current working directory"

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

  def run(_args) do
    # Supporting lib and runtime configuration
    Application.put_env(:phoenix, :json_library, Jason)
    Application.put_env(:esbuild, :version, "0.14.0")
    Application.put_env(:logger, :console, level: :info)

    # Configure logger
    Logger.configure_backend(:console,
      format: "$time $metadata[$level] $message\n",
      metadata: [:request_id],
      level: :info
    )

    # Configure the endpoint server
    Application.put_env(:server, ServerWeb.Endpoint,
      http: [ip: {127, 0, 0, 1}, port: 4444],
      server: true,
      secret_key_base: String.duplicate("a", 64),
      cache_static_manifest: "priv/static/cache_manifest.json",
      live_view: [signing_salt: "FtRh_twgiYg7vABG"]
    )

    Mix.install(@server_deps)

    {:ok, _} = Supervisor.start_link([ServerWeb.Endpoint], strategy: :one_for_one)
    Process.sleep(:infinity)
  end
end
