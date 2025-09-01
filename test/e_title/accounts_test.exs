defmodule ETitle.AccountsTest do
  use ETitle.DataCase

  alias ETitle.Accounts

  import ETitle.AccountsFixtures
  alias ETitle.Accounts.{Account, AccountToken}
  import ETitle.Factory

  @user_valid_attrs %{
    first_name: "John",
    middle_name: "Doe",
    surname: "Doe",
    identity_doc_no: "1234567890",
    accounts: [%{email: "john@example.com", phone_number: "254712345678", type: :citizen}]
  }

  describe "get_account_by_email/1" do
    test "does not return the account if the email does not exist" do
      refute Accounts.get_account_by_email("unknown@example.com")
    end

    test "returns the account if the email exists" do
      %{id: id} = account = insert(:account)
      assert %Account{id: ^id} = Accounts.get_account_by_email(account.email)
    end
  end

  describe "get_account_by_email_and_password/2" do
    test "does not return the account if the email does not exist" do
      refute Accounts.get_account_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the account if the password is not valid" do
      account = insert(:account)
      refute Accounts.get_account_by_email_and_password(account.email, "invalid")
    end

    test "returns the account if the email and password are valid" do
      %{id: id} = account = insert(:account)

      assert %Account{id: ^id} =
               Accounts.get_account_by_email_and_password(account.email, "hello World!1234")
    end
  end

  describe "get_account!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_account!(-1)
      end
    end

    test "returns the account with the given id" do
      %{id: id} = account = insert(:account)
      assert %Account{id: ^id} = Accounts.get_account!(account.id)
    end
  end

  describe "register_account/1" do
    test "registers accounts without password" do
      {:ok, user} = Accounts.register_account(@user_valid_attrs)
      [account] = user.accounts
      [accounts_attrs] = @user_valid_attrs.accounts

      assert user.first_name == @user_valid_attrs.first_name
      assert user.middle_name == @user_valid_attrs.middle_name
      assert user.surname == @user_valid_attrs.surname
      assert user.identity_doc_no == @user_valid_attrs.identity_doc_no
      assert account.email == accounts_attrs.email
      assert account.phone_number == accounts_attrs.phone_number

      assert is_nil(account.hashed_password)
      assert is_nil(account.confirmed_at)
      assert is_nil(account.password)
    end

    test "requires email to be set" do
      user_attrs_with_no_email =
        update_in(@user_valid_attrs.accounts, fn accounts ->
          Enum.map(accounts, &Map.drop(&1, [:email]))
        end)

      assert {:error, changeset} = Accounts.register_account(user_attrs_with_no_email)
      assert %{accounts: [%{email: ["can't be blank"]}]} == errors_on(changeset)
    end

    test "requires phone_number to be set" do
      user_attrs_with_no_phone_number =
        update_in(@user_valid_attrs.accounts, fn accounts ->
          Enum.map(accounts, &Map.drop(&1, [:phone_number]))
        end)

      assert {:error, changeset} = Accounts.register_account(user_attrs_with_no_phone_number)
      assert %{accounts: [%{phone_number: ["can't be blank"]}]} == errors_on(changeset)
    end

    test "require first name to be set" do
      user_attrs_with_no_first_name = Map.put(@user_valid_attrs, :first_name, nil)
      assert {:error, changeset} = Accounts.register_account(user_attrs_with_no_first_name)
      assert %{first_name: ["can't be blank"]} == errors_on(changeset)
    end

    test "require surname to be set" do
      user_attrs_with_no_surname = Map.put(@user_valid_attrs, :surname, nil)
      assert {:error, changeset} = Accounts.register_account(user_attrs_with_no_surname)
      assert %{surname: ["can't be blank"]} == errors_on(changeset)
    end

    test "require identity doc no to be set" do
      user_attrs_with_no_identity_doc_no = Map.put(@user_valid_attrs, :identity_doc_no, nil)
      assert {:error, changeset} = Accounts.register_account(user_attrs_with_no_identity_doc_no)
      assert %{identity_doc_no: ["can't be blank"]} == errors_on(changeset)
    end

    test "validates email when given" do
      {:error, changeset} =
        @user_valid_attrs
        |> Map.put(:accounts, [%{email: "not valid"}])
        |> Accounts.register_account()

      assert %{accounts: [%{email: ["must have the @ sign and no spaces"]}]} =
               errors_on(changeset)
    end

    test "validates maximum values for email for security" do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        @user_valid_attrs
        |> update_in([:accounts, Access.at(0), :email], fn _ -> too_long end)
        |> Accounts.register_account()

      assert %{
               accounts: [
                 %{
                   email: [
                     "should be at most 160 character(s)",
                     "must have the @ sign and no spaces"
                   ]
                 }
               ]
             } ==
               errors_on(changeset)
    end

    test "validates email uniqueness" do
      %{email: email} = insert(:account)

      {:error, changeset} =
        @user_valid_attrs
        |> update_in([:accounts, Access.at(0), :email], fn _ -> email end)
        |> Accounts.register_account()

      assert %{accounts: [%{email: ["has already been taken"]}]} == errors_on(changeset)

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} =
        @user_valid_attrs
        |> update_in([:accounts, Access.at(0), :email], fn _ -> String.upcase(email) end)
        |> Accounts.register_account()

      assert %{accounts: [%{email: ["has already been taken"]}]} == errors_on(changeset)
    end
  end

  describe "sudo_mode?/2" do
    test "validates the authenticated_at time" do
      now = DateTime.utc_now()

      assert Accounts.sudo_mode?(%Account{authenticated_at: DateTime.utc_now()})
      assert Accounts.sudo_mode?(%Account{authenticated_at: DateTime.add(now, -19, :minute)})
      refute Accounts.sudo_mode?(%Account{authenticated_at: DateTime.add(now, -21, :minute)})

      # minute override
      refute Accounts.sudo_mode?(
               %Account{authenticated_at: DateTime.add(now, -11, :minute)},
               -10
             )

      # not authenticated
      refute Accounts.sudo_mode?(%Account{})
    end
  end

  describe "change_account_email/3" do
    test "returns a account changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_account_email(%Account{})
      assert changeset.required == [:type, :phone_number, :email]
    end
  end

  describe "deliver_account_update_email_instructions/3" do
    setup do
      %{account: insert(:account)}
    end

    test "sends token through notification", %{account: account} do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_account_update_email_instructions(account, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert account_token = Repo.get_by(AccountToken, token: :crypto.hash(:sha256, token))
      assert account_token.account_id == account.id
      assert account_token.sent_to == account.email
      assert account_token.context == "change:current@example.com"
    end
  end

  describe "update_account_email/2" do
    setup do
      account = insert(:unconfirmed_account)
      email = "john@example.com"

      token =
        extract_account_token(fn url ->
          Accounts.deliver_account_update_email_instructions(
            %{account | email: email},
            account.email,
            url
          )
        end)

      %{account: account, token: token, email: email}
    end

    test "updates the email with a valid token", %{account: account, token: token, email: email} do
      assert {:ok, %{email: ^email}} = Accounts.update_account_email(account, token)
      changed_account = Repo.get!(Account, account.id)
      assert changed_account.email != account.email
      assert changed_account.email == email
      refute Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not update email with invalid token", %{account: account} do
      assert Accounts.update_account_email(account, "oops") ==
               {:error, :transaction_aborted}

      assert Repo.get!(Account, account.id).email == account.email
      assert Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not update email if account email changed", %{account: account, token: token} do
      assert Accounts.update_account_email(%{account | email: "current@example.com"}, token) ==
               {:error, :transaction_aborted}

      assert Repo.get!(Account, account.id).email == account.email
      assert Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not update email if token expired", %{account: account, token: token} do
      {1, nil} = Repo.update_all(AccountToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      assert Accounts.update_account_email(account, token) ==
               {:error, :transaction_aborted}

      assert Repo.get!(Account, account.id).email == account.email
      assert Repo.get_by(AccountToken, account_id: account.id)
    end
  end

  describe "change_account_password/3" do
    test "returns a account changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_account_password(%Account{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_account_password(
          %Account{},
          %{
            "password" => "new valid password"
          },
          hash_password: false
        )

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_account_password/2" do
    setup do
      %{account: insert(:account)}
    end

    test "validates password", %{account: account} do
      {:error, changeset} =
        Accounts.update_account_password(account, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{account: account} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_account_password(account, %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{account: account} do
      {:ok, {account, expired_tokens}} =
        Accounts.update_account_password(account, %{
          password: "new valid password"
        })

      assert expired_tokens == []
      assert is_nil(account.password)
      assert Accounts.get_account_by_email_and_password(account.email, "new valid password")
    end

    test "deletes all tokens for the given account", %{account: account} do
      _ = Accounts.generate_account_session_token(account)

      {:ok, {_, _}} =
        Accounts.update_account_password(account, %{
          password: "new valid password"
        })

      refute Repo.get_by(AccountToken, account_id: account.id)
    end
  end

  describe "generate_account_session_token/1" do
    setup do
      %{account: insert(:account)}
    end

    test "generates a token", %{account: account} do
      token = Accounts.generate_account_session_token(account)
      assert account_token = Repo.get_by(AccountToken, token: token)
      assert account_token.context == "session"
      assert account_token.authenticated_at != nil

      # Creating the same token for another account should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%AccountToken{
          token: account_token.token,
          account_id: insert(:account).id,
          context: "session"
        })
      end
    end

    test "duplicates the authenticated_at of given account in new token", %{account: account} do
      account = %{account | authenticated_at: DateTime.add(DateTime.utc_now(:second), -3600)}
      token = Accounts.generate_account_session_token(account)
      assert account_token = Repo.get_by(AccountToken, token: token)
      assert account_token.authenticated_at == account.authenticated_at
      assert DateTime.compare(account_token.inserted_at, account.authenticated_at) == :gt
    end
  end

  describe "get_account_by_session_token/1" do
    setup do
      account = insert(:account)
      token = Accounts.generate_account_session_token(account)
      %{account: account, token: token}
    end

    test "returns account by token", %{account: account, token: token} do
      assert {session_account, token_inserted_at} = Accounts.get_account_by_session_token(token)
      assert session_account.id == account.id
      assert session_account.authenticated_at != nil
      assert token_inserted_at != nil
    end

    test "does not return account for invalid token" do
      refute Accounts.get_account_by_session_token("oops")
    end

    test "does not return account for expired token", %{token: token} do
      dt = ~N[2020-01-01 00:00:00]
      {1, nil} = Repo.update_all(AccountToken, set: [inserted_at: dt, authenticated_at: dt])
      refute Accounts.get_account_by_session_token(token)
    end
  end

  describe "get_account_by_magic_link_token/1" do
    setup do
      account = insert(:account)
      {encoded_token, _hashed_token} = generate_account_magic_link_token(account)
      %{account: account, token: encoded_token}
    end

    test "returns account by token", %{account: account, token: token} do
      assert session_account = Accounts.get_account_by_magic_link_token(token)
      assert session_account.id == account.id
    end

    test "does not return account for invalid token" do
      refute Accounts.get_account_by_magic_link_token("oops")
    end

    test "does not return account for expired token", %{token: token} do
      {1, nil} = Repo.update_all(AccountToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_account_by_magic_link_token(token)
    end
  end

  describe "login_account_by_magic_link/1" do
    test "confirms account and expires tokens" do
      account = insert(:unconfirmed_account)
      refute account.confirmed_at
      {encoded_token, hashed_token} = generate_account_magic_link_token(account)

      assert {:ok, {account, [%{token: ^hashed_token}]}} =
               Accounts.login_account_by_magic_link(encoded_token)

      assert account.confirmed_at
    end

    test "returns account and (deleted) token for confirmed account" do
      account = insert(:account)
      assert account.confirmed_at
      {encoded_token, _hashed_token} = generate_account_magic_link_token(account)
      assert {:ok, {logged_in_account, []}} = Accounts.login_account_by_magic_link(encoded_token)
      assert logged_in_account.id == account.id

      # one time use only
      assert {:error, :not_found} = Accounts.login_account_by_magic_link(encoded_token)
    end

    test "raises when unconfirmed account has password set" do
      account = insert(:unconfirmed_account)
      {1, nil} = Repo.update_all(Account, set: [hashed_password: "hashed"])
      {encoded_token, _hashed_token} = generate_account_magic_link_token(account)

      assert_raise RuntimeError, ~r/magic link log in is not allowed/, fn ->
        Accounts.login_account_by_magic_link(encoded_token)
      end
    end
  end

  describe "delete_account_session_token/1" do
    test "deletes the token" do
      account = insert(:account)
      token = Accounts.generate_account_session_token(account)
      assert Accounts.delete_account_session_token(token) == :ok
      refute Accounts.get_account_by_session_token(token)
    end
  end

  describe "deliver_login_instructions/2" do
    setup do
      %{account: insert(:unconfirmed_account)}
    end

    test "sends token through notification", %{account: account} do
      token =
        extract_account_token(fn url ->
          Accounts.deliver_login_instructions(account, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert account_token = Repo.get_by(AccountToken, token: :crypto.hash(:sha256, token))
      assert account_token.account_id == account.id
      assert account_token.sent_to == account.email
      assert account_token.context == "login"
    end
  end

  describe "inspect/2 for the Account module" do
    test "does not include password" do
      refute inspect(%Account{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
