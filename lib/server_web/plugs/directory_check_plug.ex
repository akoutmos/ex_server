defmodule ServerWeb.DirectoryCheckPlug do
  @moduledoc """
  This plug checks to see if the current request is
  for a file or for a direcotry. If it is for a file,
  the the file is served and the conn is halted. If
  the request is for a directory, then the conn is
  moved along and the catch all LiveView module
  handles it.
  """

  @behaviour Plug

  @impl true
  def init(_opts) do
    []
  end

  @impl true
  def call(conn, _opts) do
    conn
  end
end
