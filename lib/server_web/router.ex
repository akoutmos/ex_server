defmodule ExServerWeb.Router do
  use ExServerWeb, :router

  alias ExServerWeb.DirectoryCheckPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExServerWeb.LayoutView, :root}
    plug :put_secure_browser_headers
  end

  pipeline :file_explorer do
    plug DirectoryCheckPlug
  end

  scope "/", ExServerWeb do
    pipe_through [:browser, :file_explorer]

    live "/*path", FileExplorerLive
  end
end
