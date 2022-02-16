defmodule Mix.Tasks.Server do
  @moduledoc """
  This Mix task is used to start an HTTP server from the
  current working directory
  """

  use Mix.Task

  @version Mix.Project.config()[:version]
  @shortdoc "Start an HTTP server from the current working directory"

  @switches [port: :string]

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
end
