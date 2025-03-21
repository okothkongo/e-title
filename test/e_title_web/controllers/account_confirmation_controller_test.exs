defmodule ETitleWeb.AccountConfirmationControllerTest do
  use ETitleWeb.ConnCase, async: true

  alias ETitle.Accounts
  alias ETitle.Repo
  alias ETitle.Factory

  setup do
    %{account: Factory.insert!(:account)}
  end

  describe "GET /accounts/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, ~p"/accounts/confirm")
      response = html_response(conn, 200)
      assert response =~ "Resend confirmation instructions"
    end
  end

  describe "POST /accounts/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/accounts/confirm", %{
          "account" => %{"email" => account.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Accounts.AccountToken, account_id: account.id).context == "confirm"
    end

    test "does not send confirmation token if Account is confirmed", %{
      conn: conn,
      account: account
    } do
      Repo.update!(Accounts.Account.confirm_changeset(account))

      conn =
        post(conn, ~p"/accounts/confirm", %{
          "account" => %{"email" => account.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Accounts.AccountToken, account_id: account.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/accounts/confirm", %{
          "account" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Accounts.AccountToken) == []
    end
  end

  describe "GET /accounts/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      token_path = ~p"/accounts/confirm/some-token"
      conn = get(conn, token_path)
      response = html_response(conn, 200)
      assert response =~ "Confirm account"

      assert response =~ "action=\"#{token_path}\""
    end
  end

  describe "POST /accounts/confirm/:token" do
    test "confirms the given token once", %{conn: conn, account: account} do
      token =
        ETitle.Factory.extract_account_token(fn url ->
          Accounts.deliver_account_confirmation_instructions(account, url)
        end)

      conn = post(conn, ~p"/accounts/confirm/#{token}")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Account confirmed successfully"

      assert Accounts.get_account!(account.id).confirmed_at
      refute get_session(conn, :account_token)
      assert Repo.all(Accounts.AccountToken) == []

      # When not logged in
      conn = post(conn, ~p"/accounts/confirm/#{token}")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Account confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_account(account)
        |> post(~p"/accounts/confirm/#{token}")

      assert redirected_to(conn) == ~p"/"
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, account: account} do
      conn = post(conn, ~p"/accounts/confirm/oops")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Account confirmation link is invalid or it has expired"

      refute Accounts.get_account!(account.id).confirmed_at
    end
  end
end
