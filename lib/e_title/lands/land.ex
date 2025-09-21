defmodule ETitle.Lands.Land do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lands" do
    field :title_number, :string
    field :size, :decimal
    field :gps_cordinates, :string
    field :account_id, :id
    field :registry_id, :id


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(land, attrs, account_scope) do
    land
    |> cast(attrs, [:title_number, :size, :gps_cordinates])
    |> validate_required([:title_number, :size, :gps_cordinates])
    |> unique_constraint(:gps_cordinates)
    |> put_change(:account_id, account_scope.account.id)
  end
end
