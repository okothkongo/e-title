defmodule ETitle.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ETitle.Accounts` context.
  """

  def valid_account_password, do: "hello world!"

  def valid_account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: "account#{System.unique_integer()}@example.com",
      password: valid_account_password()
    })
  end
end
