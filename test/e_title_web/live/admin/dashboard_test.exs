defmodule ETitleWeb.Admin.DashboardTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.Factory

  test "admin dashboard access", %{conn: conn} do
    admin = insert(:account, type: :staff)
    _ = insert(:account_role, account: admin, role: insert(:role, name: "admin", type: :staff))
    user = admin.user
    conn = log_in_account(conn, admin)
    {:ok, _index_live, html} = live(conn, ~p"/admin/dashboard")
    assert html =~ "#{user.first_name} #{user.surname}"
  end

  test "non-admin dashboard access", %{conn: conn} do
    user = insert(:account, type: :citizen)
    conn = log_in_account(conn, user)
    assert {:error, {:redirect, %{to: to}}} = live(conn, ~p"/admin/dashboard")
    assert to == ~p"/"
  end
end
