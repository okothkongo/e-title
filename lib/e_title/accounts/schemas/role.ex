defmodule ETitle.Accounts.Schemas.Role do
  @moduledoc """
    Handles role data.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ETitle.Accounts.Schemas.AccountRole

  schema "roles" do
    field :name, :string
    timestamps(type: :utc_datetime)
    has_many :account_roles, AccountRole
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
