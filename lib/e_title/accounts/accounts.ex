defmodule ETitle.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias ETitle.Repo
  alias ETitle.Accounts.Services.AccountNotifier
  alias ETitle.Accounts.Schemas.Account
  alias ETitle.Accounts.Schemas.AccountRole
  alias ETitle.Accounts.Schemas.AccountToken
  alias ETitle.Accounts.Schemas.Role
  alias ETitle.Accounts.Schemas.User
  ## Database getters

  @doc """
  Gets a account by email.

  ## Examples

      iex> get_account_by_email("foo@example.com")
      %Account{}

      iex> get_account_by_email("unknown@example.com")
      nil

  """
  def get_account_by_email(email) when is_binary(email) do
    Repo.get_by(Account, email: email)
  end

  @doc """
  Gets a account by email and password.

  ## Examples

      iex> get_account_by_email_and_password("foo@example.com", "correct_password")
      %Account{}

      iex> get_account_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_account_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    account = Repo.get_by(Account, email: email)
    if Account.valid_password?(account, password), do: account
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account(123)
      %Account{}

      iex> get_account(456)
      nil

  """
  def get_account(id), do: Repo.get(Account, id)

  ## Account registration

  @doc """
  Registers a account.

  ## Examples

      iex> register_account(%{field: value})
      {:ok, %Account{}}

      iex> register_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_account(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_user_and_account(attrs \\ %{}) do
    User.registration_changeset(%User{accounts: [%Account{}]}, attrs)
  end

  def create_account_role(attrs) do
    %AccountRole{}
    |> AccountRole.changeset(attrs)
    |> Repo.insert()
  end

  def get_role_by_name(name) do
    Repo.get_by(Role, name: name)
  end

  def get_role(id) do
    Repo.get(Role, id)
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_by_identity_document(identity_document) do
    Repo.get_by(User, identity_doc_no: identity_document)
  end

  ## Settings

  @doc """
  Checks whether the account is in sudo mode.

  The account is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(account, minutes \\ -20)

  def sudo_mode?(%Account{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_account, _minutes), do: false

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account email.

  See `Title.Accounts.Schemas.Account.email_changeset/3` for a list of supported options.

  ## Examples

      iex> change_account_email(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_email(account, attrs \\ %{}, opts \\ []) do
    Account.email_changeset(account, attrs, opts)
  end

  def create_account(attrs) do
    %Account{}
    |> Account.email_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates the account email using the given token.

  If the token matches, the account email is updated and the token is deleted.
  """
  def update_account_email(account, token) do
    context = "change:#{account.email}"

    Repo.transact(fn ->
      with {:ok, query} <- AccountToken.verify_change_email_token_query(token, context),
           %AccountToken{sent_to: email} <- Repo.one(query),
           {:ok, account} <- Repo.update(Account.email_changeset(account, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(
               from(AccountToken, where: [account_id: ^account.id, context: ^context])
             ) do
        {:ok, account}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account password.

  See `Title.Accounts.Schemas.Account.password_changeset/3` for a list of supported options.

  ## Examples

      iex> change_account_password(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_password(account, attrs \\ %{}, opts \\ []) do
    Account.password_changeset(account, attrs, opts)
  end

  @doc """
  Updates the account password.

  Returns a tuple with the updated account, as well as a list of expired tokens.

  ## Examples

      iex> update_account_password(account, %{password: ...})
      {:ok, {%Account{}, [...]}}

      iex> update_account_password(account, %{password: "too short"})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_password(account, attrs) do
    account
    |> Account.password_changeset(attrs)
    |> update_account_and_delete_all_tokens()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_account_session_token(account) do
    {token, account_token} = AccountToken.build_session_token(account)
    Repo.insert!(account_token)
    token
  end

  @doc """
  Gets the account with the given signed token.

  If the token is valid `{account, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_account_by_session_token(token) do
    {:ok, query} = AccountToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets the account with the given magic link token.
  """
  def get_account_by_magic_link_token(token) do
    with {:ok, query} <- AccountToken.verify_magic_link_token_query(token),
         {account, _token} <- Repo.one(query) do
      account
    else
      _ -> nil
    end
  end

  @doc """
  Logs the account in by magic link.

  There are three cases to consider:

  1. The account has already confirmed their email. They are logged in
     and the magic link is expired.

  2. The account has not confirmed their email and no password is set.
     In this case, the account gets confirmed, logged in, and all tokens -
     including session ones - are expired. In theory, no other tokens
     exist but we delete all of them for best security practices.

  3. The account has not confirmed their email but a password is set.
     This cannot happen in the default implementation but may be the
     source of security pitfalls. See the "Mixing magic link and password registration" section of
     `mix help phx.gen.auth`.
  """
  def login_account_by_magic_link(token) do
    {:ok, query} = AccountToken.verify_magic_link_token_query(token)

    case Repo.one(query) do
      # Prevent session fixation attacks by disallowing magic links for unconfirmed users with password
      {%Account{confirmed_at: nil, hashed_password: hash}, _token} when not is_nil(hash) ->
        raise """
        magic link log in is not allowed for unconfirmed users with a password set!

        This cannot happen with the default implementation, which indicates that you
        might have adapted the code to a different use case. Please make sure to read the
        "Mixing magic link and password registration" section of `mix help phx.gen.auth`.
        """

      {%Account{confirmed_at: nil} = account, _token} ->
        account
        |> Account.confirm_changeset()
        |> update_account_and_delete_all_tokens()

      {account, token} ->
        Repo.delete!(token)
        {:ok, {account, []}}

      nil ->
        {:error, :not_found}
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given account.

  ## Examples

      iex> deliver_account_update_email_instructions(account, current_email, &url(~p"/accounts/settings/confirm-email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_account_update_email_instructions(
        %Account{} = account,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, account_token} =
      AccountToken.build_email_token(account, "change:#{current_email}")

    Repo.insert!(account_token)

    AccountNotifier.deliver_update_email_instructions(
      account,
      update_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Delivers the magic link login instructions to the given account.
  """
  def deliver_login_instructions(%Account{} = account, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, account_token} = AccountToken.build_email_token(account, "login")
    Repo.insert!(account_token)
    AccountNotifier.deliver_login_instructions(account, magic_link_url_fun.(encoded_token))
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_account_session_token(token) do
    Repo.delete_all(from(AccountToken, where: [token: ^token, context: "session"]))
    :ok
  end

  ## Token helper

  defp update_account_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, account} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all_by(AccountToken, account_id: account.id)

        Repo.delete_all(
          from(t in AccountToken, where: t.id in ^Enum.map(tokens_to_expire, & &1.id))
        )

        {:ok, {account, tokens_to_expire}}
      end
    end)
  end

  def account_has_role?(%Account{id: id}, role_name) do
    query =
      from role in Role,
        join: account_role in AccountRole,
        on: account_role.role_id == role.id,
        join: account in Account,
        on: account.id == account_role.account_id,
        where:
          account_role.account_id == ^id and role.name == ^role_name and account.type == role.type and
            account.status == :active and role.status == :active

    Repo.exists?(query)
  end

  def account_has_role?(_, _role_name), do: false

  def list_users do
    Repo.all(User)
  end

  def list_accounts_with_user_and_role do
    query =
      from a in Account,
        join: u in User,
        on: a.user_id == u.id,
        join: ar in AccountRole,
        on: a.id == ar.account_id,
        join: r in Role,
        on: ar.role_id == r.id,
        preload: [user: u, account_role: {ar, role: r}],
        order_by: [asc: a.type, asc: r.name]

    Repo.all(query)
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.update_changeset(attrs)
    |> Repo.update()
  end

  def get_active_roles_by_type(type) do
    query = from r in Role, where: r.type == ^type and r.status == :active, order_by: r.name
    Repo.all(query)
  end

  def get_citizen_account_by_identity_doc_no(identity_doc_no) when is_binary(identity_doc_no) do
    query =
      from a in Account,
        join: u in User,
        on: a.user_id == u.id,
        join: ar in AccountRole,
        on: a.id == ar.account_id,
        join: r in Role,
        on: ar.role_id == r.id,
        where:
          a.type == :citizen and a.status == :active and r.name == "user" and
            u.identity_doc_no == ^identity_doc_no,
        limit: 1,
        select: a

    Repo.one(query)
  end
end
