defmodule ExServerWeb.FileExplorerLive do
  @moduledoc """
  This LiveView module is used to
  """

  use ExServerWeb, :live_view

  on_mount {__MODULE__, :contains_index_file}

  def mount(%{"path" => requested_path}, _session, socket) do
    assigns = [
      entries: get_files_from_path(requested_path),
      current_path: requested_path
    ]

    {:ok, assign(socket, assigns)}
  end

  defp get_files_from_path([]) do
    get_files_from_path("/")
  end

  defp get_files_from_path(requested_path) when is_list(requested_path) do
    requested_path
    |> Path.join()
    |> get_files_from_path()
  end

  defp get_files_from_path(requested_path) do
    cwd =
      File.cwd!()
      |> Path.join(requested_path)

    cwd
    |> File.ls!()
    |> Enum.sort(&(String.downcase(&1) <= String.downcase(&2)))
    |> Enum.map(fn entry ->
      file_stat =
        cwd
        |> Path.join(entry)
        |> File.stat!()

      {entry, file_stat}
    end)
  end

  @doc false
  def on_mount(:contains_index_file, %{"path" => requested_path}, _seesion, socket) do
    cond do
      requested_path |> Path.join("index.htm") |> File.exists?() ->
        redirect_path = Path.join(requested_path, "index.htm")
        {:halt, redirect(socket, to: "/#{redirect_path}")}

      requested_path |> Path.join("index.html") |> File.exists?() ->
        redirect_path = Path.join(requested_path, "index.html")
        {:halt, redirect(socket, to: "/#{redirect_path}")}

      true ->
        {:cont, socket}
    end
  end
end
