defmodule ETitleWeb.Admin.AccountLive.IndexTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.Factory

  describe "index" do
    test "renders index page", %{conn: conn} do
      admin =
        insert(:account,
          type: :staff,
          account_role: insert(:account_role, role: insert(:role, name: "admin"))
        )

      {:ok, _view, html} =
        conn
        |> log_in_account(admin)
        |> live(~p"/admin/accounts")

      assert html =~ admin.email
    end

    test "non admin cannot access the page", %{conn: conn} do
      citizen = insert(:account)
      conn = log_in_account(conn, citizen)
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/admin/accounts")
    end
  end

  # test "unauthenticated user is redirected to login", %{conn: conn} do
  #   assert {:error, {:redirect, %{to: login_path}}} = live(conn, ~p"/admin/accounts")

  #   assert login_path == ~p"/accounts/log_in"
  # end

  test "lists all accounts", %{conn: conn} do
    admin =
      insert(:account,
        type: :staff,
        account_role: insert(:account_role, role: insert(:role, name: "admin"))
      )

    {:ok, _view, html} =
      conn
      |> log_in_account(admin)
      |> live(~p"/admin/accounts")

    assert html =~ admin.email
  end
end
