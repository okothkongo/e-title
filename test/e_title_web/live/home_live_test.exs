defmodule ETitleWeb.HomeLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Secure Land"
    assert html =~ "Registration"
    assert html =~ "E-Title"
    assert html =~ "Register Your Land"
  end
end
