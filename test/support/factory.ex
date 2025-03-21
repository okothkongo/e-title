defmodule ETitle.Factory do
  @moduledoc """
  Factory for creating test data
  """
  alias ETitle.Accounts.Schemas.Identity
  alias ETitle.Accounts.Account
  alias ETitle.Repo

  def build(:identity) do
    %Identity{
      first_name: "John",
      other_names: "Doe",
      surname: "Doe",
      birth_date: ~D[2000-03-16],
      id_doc: "#{System.unique_integer([:positive])}",
      nationality: :Kenya,
      kra_pin: "some kra_pin#{System.unique_integer([:positive])}",
      passport_photo: "some passport_photo"
    }
  end

  def build(:account) do
    %Account{
      email: "account#{System.unique_integer()}@example.com",
      hashed_password: Bcrypt.hash_pwd_salt("hello world!"),
      role: :user,
      identity: build(:identity)
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end

  def extract_account_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
