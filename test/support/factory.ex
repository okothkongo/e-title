defmodule ETitle.Factory do
  @moduledoc """
    Handles factory data.
  """
  alias ETitle.Accounts.AccountRole
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

  def account_role_factory do
    %AccountRole{
      account: build(:account),
      role: build(:role)
    }
  end

  def county_factory do
    %ETitle.Locations.County{
      name: sequence("county_name", &"County #{&1}"),
      code: "#{System.unique_integer([:positive])}"
    }
  end

  def sub_county_factory do
    %ETitle.Locations.SubCounty{
      name: sequence("sub_county_name", &"Sub County #{&1}"),
      county: build(:county)
    }
  end

  def registry_factory do
    %ETitle.Locations.Registry{
      name: sequence("registry_name", &"Registry #{&1}"),
      phone_number:
        sequence("registry_phone_number", &"2547#{String.pad_leading(to_string(&1), 8, "0")}"),
      email: sequence("registry_email", &"registry_#{&1}@example.com"),
      county: build(:county),
      sub_county: build(:sub_county)
    }
  end
end
