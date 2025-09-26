defmodule ETitleWeb.Admin.UserLive.IndexTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.Factory

  describe "index" do
    test "admin can see all users", %{conn: conn} do
      admin = insert(:account, type: :staff)
      user = insert(:user)
      _ = insert(:account_role, account: admin, role: insert(:role, name: "admin", type: :staff))

      {:ok, _view, html} =
        conn
        |> log_in_account(admin)
        |> live(~p"/admin/users")

      assert html =~ "#{user.first_name}"
      assert html =~ "#{user.surname}"
      assert html =~ "#{user.identity_doc_no}"
      assert html =~ "#{admin.user.first_name}"
    end

    test "non admin cannot access the page", %{conn: conn} do
      citizen = insert(:account)
      _ = insert(:account_role, account: citizen, role: insert(:role, name: "user"))

      {:error, {:redirect, %{to: "/"}}} =
        conn
        |> log_in_account(citizen)
        |> live(~p"/admin/users")
    end
  end
end
