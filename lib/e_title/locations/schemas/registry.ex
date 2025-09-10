defmodule ETitle.Locations.Schemas.Registry do
  @moduledoc """
  The Registry schema.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ETitle.Locations.Schemas.County
  alias ETitle.Locations.Schemas.SubCounty

  schema "registries" do
    field :name, :string
    field :phone_number, :string
    field :email, :string
    belongs_to :county, County
    belongs_to :sub_county, SubCounty
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(registry, attrs) do
    registry
    |> cast(attrs, [:name, :phone_number, :email, :county_id, :sub_county_id])
    |> validate_required([:name, :phone_number, :email, :county_id, :sub_county_id])
    |> unique_constraint(:email)
    |> unique_constraint(:phone_number)
    |> unique_constraint([:name, :county_id, :sub_county_id], name: :unique_registry_in_subcounty)
  end
end
