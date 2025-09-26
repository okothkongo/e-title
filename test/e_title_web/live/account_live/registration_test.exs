defmodule ETitleWeb.AccountLive.RegistrationTest do
  use ETitleWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import ETitle.Factory
  alias ETitle.Accounts.Schemas.User

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/accounts/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      account = insert(:account)

      result =
        conn
        |> log_in_account(account)
        |> live(~p"/accounts/register")

      assert {:error, {:redirect, %{to: "/dashboard", flash: %{}}}} == result
      # assert redirected to dashboard

      {:ok, _lv, html} =
        conn
        # still logged in
        |> log_in_account(account)
        |> live(~p"/dashboard")

      assert html =~ "Dashboard"
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          account: %{
            first_name: "",
            middle_name: "",
            surname: "",
            identity_doc_no: "",
            accounts: %{0 => %{email: "", phone_number: ""}}
          }
        )

      assert result =~ "Register"
      assert ETitle.Repo.all(User) == []
    end
  end

  describe "register account" do
    @user_valid_attrs %{
      first_name: "John",
      middle_name: "Doe",
      surname: "Doe",
      identity_doc_no: "1234567890",
      accounts: %{0 => %{email: "john@example.com", phone_number: "254712345678"}}
    }
    test "creates account but does not log in", %{conn: conn} do
      insert(:role)
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      form =
        form(lv, "#registration_form", account: @user_valid_attrs)

      {:ok, _lv, html} =
        form
        |> render_submit()
        |> follow_redirect(conn, ~p"/accounts/log-in")

      assert html =~
               ~r/An email was sent to .*, please access it to confirm your account/

      assert [user] = ETitle.Repo.all(User)
      assert user.first_name == "John"
      assert user.middle_name == "Doe"
      assert user.surname == "Doe"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      insert(:account, email: "john@example.com")

      result =
        lv
        |> form("#registration_form",
          account: @user_valid_attrs
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      {:ok, _login_live, login_html} =
        lv
        |> element("main a", "Log in")
        |> render_click()
        |> follow_redirect(conn, ~p"/accounts/log-in")

      assert login_html =~ "Log in"
    end
  end
end
