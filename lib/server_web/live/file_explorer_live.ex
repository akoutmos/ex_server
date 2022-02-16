defmodule ServerWeb.FileExplorerLive do
  @moduledoc """
  This LiveView module is used to
  """

  use ServerWeb, :live_view

  def render(assigns) do
    ~H"""
    Current temperature: <%= @temperature %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :temperature, 10)}
  end
end
