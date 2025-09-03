defmodule ETitle.Accounts.AccountRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "account_roles" do
    belongs_to :account, ETitle.Accounts.Account
    belongs_to :role, ETitle.Accounts.Role
    timestamps(type: :utc_datetime)
  end

  def changeset(account_role, attrs) do
    account_role
    |> cast(attrs, [:account_id, :role_id])
    |> validate_required([:account_id, :role_id])
    |> unique_constraint([:account_id])
  end
end
