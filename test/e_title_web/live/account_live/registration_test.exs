defmodule ETitleWeb.AccountLive.RegistrationTest do
  use ETitleWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import ETitle.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/accounts/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_account(account_fixture())
        |> live(~p"/accounts/register")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(account: %{"email" => "with spaces", "phone_number" => "invalid"})

      assert result =~ "Register"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "must be a valid Kenyan phone number starting with 254"
    end
  end

  describe "register account" do
    test "creates account but does not log in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      email = unique_account_email()

      form =
        form(lv, "#registration_form", account: %{email: email, phone_number: "254712345678"})

      {:ok, _lv, html} =
        render_submit(form)
        |> follow_redirect(conn, ~p"/accounts/log-in")

      assert html =~
               ~r/An email was sent to .*, please access it to confirm your account/
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      account = account_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          account: %{"email" => account.email}
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
