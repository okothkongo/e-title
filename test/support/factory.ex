defmodule ETitle.Factory do
  @moduledoc """
    Handles factory data.
  """
  use ExMachina.Ecto, repo: ETitle.Repo

  def user_factory do
    %ETitle.Accounts.User{
      first_name: "John",
      middle_name: "Doe",
      surname: "Doe",
      identity_doc_no: sequence("identity_doc_no", &"#{&1}")
    }
  end

  def unconfirmed_account_factory do
    %ETitle.Accounts.Account{
      email: sequence("email", &"#{&1}@example.com"),
      phone_number: sequence("phone_number", &"2547#{String.pad_leading(to_string(&1), 8, "0")}"),
      type: :citizen,
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

  def role_factory do
    %ETitle.Accounts.Role{
      name: "user"
    }
  end
end
