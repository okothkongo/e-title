defmodule ETitle.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ETitle.Accounts` context.
  """

  import Ecto.Query

  alias ETitle.Accounts

  def extract_account_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @spec override_token_authenticated_at(binary(), any()) :: any()
  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    ETitle.Repo.update_all(
      from(t in Accounts.AccountToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def generate_account_magic_link_token(account) do
    {encoded_token, account_token} = Accounts.AccountToken.build_email_token(account, "login")
    ETitle.Repo.insert!(account_token)
    {encoded_token, account_token.token}
  end

  def offset_account_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    ETitle.Repo.update_all(
      from(ut in Accounts.AccountToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end

  @doc """
  Generate a unique user identity_document.
  """
  def unique_user_identity_document,
    do: "some identity_document#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        first_name: "some first_name",
        identity_document: unique_user_identity_document(),
        middle_name: "some middle_name",
        surname: "some surname"
      })

    {:ok, user} = ETitle.Accounts.create_user(scope, attrs)
    user
  end
end
