defmodule ServerWeb.DirectoryCheckPlug do
  @moduledoc """
  This plug checks to see if the current request is
  for a file or for a direcotry. If it is for a file,
  the the file is served and the conn is halted. If
  the request is for a directory, then the conn is
  moved along and the catch all LiveView module
  handles it.
  """

  require Logger

  import Phoenix.Controller, only: [redirect: 2]
  import Plug.Conn, only: [halt: 1, send_file: 3]

  alias Plug.Conn

  @behaviour Plug

  @impl true
  def init(_opts) do
    []
  end

  @impl true
  def call(%Conn{params: %{"path" => desired_path}} = conn, _opts) do
    requested_filesystem_object =
      File.cwd!()
      |> Path.join(desired_path)

    cond do
      File.dir?(requested_filesystem_object) ->
        Logger.info("Requested directory: #{inspect(requested_filesystem_object)}")
        conn

      File.exists?(requested_filesystem_object) ->
        Logger.info("Requested file: #{inspect(requested_filesystem_object)}")

        conn
        |> send_file(200, requested_filesystem_object)
        |> halt()

      true ->
        Logger.warning("Invalid file system request: #{inspect(requested_filesystem_object)}")
        redirect_to_cwd(conn)
    end
  end

  def call(conn, _opts) do
    redirect_to_cwd(conn)
  end

  defp redirect_to_cwd(conn) do
    conn
    |> redirect(to: "/")
    |> halt()
  end
end
