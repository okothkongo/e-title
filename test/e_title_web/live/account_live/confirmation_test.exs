defmodule ETitleWeb.AccountLive.ConfirmationTest do
  use ETitleWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import ETitle.AccountsFixtures
  import ETitle.Factory

  alias ETitle.Accounts

  setup do
    %{unconfirmed_account: insert(:unconfirmed_account), confirmed_account: insert(:account)}
  end

  describe "Confirm account" do
    test "renders confirmation page for unconfirmed account", %{
      conn: conn,
      unconfirmed_account: account
    } do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_login_instructions(account, url)
        end)

      {:ok, _lv, html} = live(conn, ~p"/accounts/log-in/#{token}")
      assert html =~ "Confirm and stay logged in"
    end

    test "renders login page for confirmed account", %{conn: conn, confirmed_account: account} do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_login_instructions(account, url)
        end)

      {:ok, _lv, html} = live(conn, ~p"/accounts/log-in/#{token}")
      refute html =~ "Confirm my account"
      assert html =~ "Log in"
    end

    test "confirms the given token once", %{conn: conn, unconfirmed_account: account} do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_login_instructions(account, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/accounts/log-in/#{token}")

      form = form(lv, "#confirmation_form", %{"account" => %{"token" => token}})
      render_submit(form)

      conn = follow_trigger_action(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Account confirmed successfully"

      assert Accounts.get_account!(account.id).confirmed_at
      # we are logged in now
      assert get_session(conn, :account_token)
      assert redirected_to(conn) == ~p"/"

      # log out, new conn
      conn = build_conn()

      {:ok, _lv, html} =
        conn
        |> live(~p"/accounts/log-in/#{token}")
        |> follow_redirect(conn, ~p"/accounts/log-in")

      assert html =~ "Magic link is invalid or it has expired"
    end

    test "logs confirmed account in without changing confirmed_at", %{
      conn: conn,
      confirmed_account: account
    } do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_login_instructions(account, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/accounts/log-in/#{token}")

      form = form(lv, "#login_form", %{"account" => %{"token" => token}})
      render_submit(form)

      conn = follow_trigger_action(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Welcome back!"

      assert Accounts.get_account!(account.id).confirmed_at == account.confirmed_at

      # log out, new conn
      conn = build_conn()

      {:ok, _lv, html} =
        conn
        |> live(~p"/accounts/log-in/#{token}")
        |> follow_redirect(conn, ~p"/accounts/log-in")

      assert html =~ "Magic link is invalid or it has expired"
    end

    test "raises error for invalid token", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> live(~p"/accounts/log-in/invalid-token")
        |> follow_redirect(conn, ~p"/accounts/log-in")

      assert html =~ "Magic link is invalid or it has expired"
    end
  end
end
