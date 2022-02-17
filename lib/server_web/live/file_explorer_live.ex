defmodule ServerWeb.FileExplorerLive do
  @moduledoc """
  This LiveView module is used to
  """

  use ServerWeb, :live_view

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
end
