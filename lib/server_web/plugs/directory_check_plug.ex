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

  import Phoenix.Controller, only: [redirect: 2, protect_from_forgery: 1]
  import Plug.Conn, only: [halt: 1, send_file: 3, put_resp_content_type: 2]

  alias Plug.Conn

  @behaviour Plug

  @impl true
  def init(_opts) do
    []
  end

  @impl true
  def call(%Conn{params: %{"path" => desired_path}} = conn, _opts) do
    desired_path =
      case desired_path do
        [] -> "/"
        path -> Path.join(path)
      end

    requested_filesystem_object =
      File.cwd!()
      |> Path.join(desired_path)

    index_file_path = contains_index_file(requested_filesystem_object)

    cond do
      File.dir?(requested_filesystem_object) and !is_nil(index_file_path) ->
        Logger.info("Requested index file: #{inspect(index_file_path)}")
        content_type = MIME.from_path(index_file_path)

        conn
        |> put_resp_content_type(content_type)
        |> send_file(200, index_file_path)
        |> halt()

      File.dir?(requested_filesystem_object) ->
        Logger.info("Requested directory: #{inspect(requested_filesystem_object)}")
        protect_from_forgery(conn)

      File.exists?(requested_filesystem_object) ->
        Logger.info("Requested file: #{inspect(requested_filesystem_object)}")
        content_type = MIME.from_path(requested_filesystem_object)

        conn
        |> put_resp_content_type(content_type)
        |> send_file(200, requested_filesystem_object)
        |> halt()

      true ->
        Logger.warning("Invalid file system request: #{inspect(requested_filesystem_object)}")

        conn
        |> protect_from_forgery()
        |> redirect_to_cwd()
    end
  end

  def call(conn, _opts) do
    redirect_to_cwd(conn)
  end

  defp contains_index_file(requested_filesystem_object) do
    cond do
      requested_filesystem_object |> Path.join("index.htm") |> File.exists?() ->
        Path.join(requested_filesystem_object, "index.htm")

      requested_filesystem_object |> Path.join("index.html") |> File.exists?() ->
        Path.join(requested_filesystem_object, "index.html")

      true ->
        nil
    end
  end

  defp redirect_to_cwd(conn) do
    conn
    |> redirect(to: "/")
    |> halt()
  end
end
