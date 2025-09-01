defmodule ETitleWeb.PageController do
  use ETitleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
