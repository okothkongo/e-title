defmodule ETitle.Lands.Schemas.Land do
  use Ecto.Schema
  import Ecto.Changeset

  alias ETitle.Locations.Schemas.Registry
  alias ETitle.Accounts.Schemas.Account

  schema "lands" do
    field :title_number, :string
    field :size, :decimal
    field :gps_cordinates, :string
    belongs_to :registry, Registry
    belongs_to :account, Account
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(land, attrs, account_scope) do
    land
    |> cast(attrs, [:title_number, :size, :gps_cordinates, :registry_id])
    |> validate_required([:title_number, :size, :gps_cordinates, :registry_id])
    |> unique_constraint(:gps_cordinates)
    |> put_change(:account_id, account_scope.account.id)
  end
end
