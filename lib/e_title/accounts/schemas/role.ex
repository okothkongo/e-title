defmodule ETitle.Accounts.Schemas.Role do
  @moduledoc """
    Handles role data.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ETitle.Accounts.Schemas.AccountRole

  schema "roles" do
    field :name, :string
    field :description, :string
    field :status, Ecto.Enum, values: ~w(active inactive)a, default: :active
    field :type, Ecto.Enum, values: ~w(staff citizen professional)a
    timestamps(type: :utc_datetime)
    has_many :account_roles, AccountRole
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :description, :status, :type])
    |> validate_required([:name, :type, :status])
    |> unique_constraint(:name)
  end
end
