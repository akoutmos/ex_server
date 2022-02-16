defmodule ServerWeb.Router do
  use ServerWeb, :router

  alias ServerWeb.DirectoryCheckPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ServerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :file_explorer do
    plug DirectoryCheckPlug
  end

  scope "/", ServerWeb do
    pipe_through [:browser, :file_explorer]

    live "/*path", FileExplorerLive
  end
end
