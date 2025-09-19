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

  describe "create account" do
    @invalid_attrs %{email: nil, phone_number: nil, type: nil}
    #

    test "save new account", %{conn: conn} do
      admin =
        insert(:account,
          type: :staff,
          account_role: insert(:account_role, role: insert(:role, name: "admin"))
        )

      user = insert(:user)
      conn = log_in_account(conn, admin)

      {:ok, index_live, _html} = live(conn, ~p"/admin/accounts")

      assert {:ok, form_live, _html} =
               index_live
               |> element("a", "Create Account")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/accounts/new")

      form_live
      |> form("#account-form", account: @invalid_attrs)
      |> render_change() =~ "can&#39;t be blank"

      form_live
      |> form("#account-form", %{"account" => %{"user_id_no" => user.identity_doc_no}})
      |> render_change() =~ user.first_name

      assert {:ok, index_live, _html} =
               form_live
               |> form("#account-form", %{
                 "account" => %{
                   email: "test@test.com",
                   phone_number: "254712345678",
                   user_id_no: user.identity_doc_no
                 }
               })
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/accounts")

      html = render(index_live)
      assert html =~ "#{user.first_name}"
      assert ETitle.Repo.get_by(ETitle.Accounts.Schemas.Account, email: "test@test.com")
    end
  end
end
