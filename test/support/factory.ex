defmodule ETitle.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: ETitle.Repo

  alias ETitle.Accounts.Account

  def unconfirmed_account_factory do
    %Account{
      type: :citizen,
      email: sequence(:email, &"email-#{&1}@example.com"),
      phone_number: sequence(:phone_number, &"123-456-789#{&1}")
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
end
