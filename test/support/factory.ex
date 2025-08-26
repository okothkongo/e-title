defmodule ETitle.Factory do
  @moduledoc """
  This module defines factory functions for creating test data.
  """
  use ExMachina.Ecto, repo: ETitle.Repo

  alias ETitle.Accounts.Account

  def unconfirmed_account_factory do
    %Account{
      type: :citizen,
      email: sequence(:email, &"email-#{&1}@example.com"),
      phone_number: sequence(:phone_number, &"123-456-789#{&1}"),
      user: build(:user)
    }
  end

  def account_factory do
    struct!(
      unconfirmed_account_factory(),
      %{
        confirmed_at: DateTime.utc_now(),
        hashed_password: Bcrypt.hash_pwd_salt("hello World!1234")
      }
    )
  end

  def account_scope_factory do
    %ETitle.Accounts.Scope{
      account: build(:account)
    }
  end

  def user_factory do
    %ETitle.Accounts.User{
      first_name: "John",
      middle_name: "M",
      surname: "Doe",
      identity_document: sequence(:identity_document, &"ID#{&1}")
    }
  end
end
