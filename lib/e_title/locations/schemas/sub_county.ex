defmodule ETitle.Locations.Schemas.SubCounty do
  @moduledoc """
    Handles sub-county data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ETitle.Locations.Schemas.County
  alias ETitle.Locations.Schemas.Registry

  schema "sub_counties" do
    field :name, :string
    belongs_to :county, County
    has_many :registries, Registry

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sub_county, attrs) do
    sub_county
    |> cast(attrs, [:name, :county_id])
    |> validate_required([:name])
    |> unique_constraint([:county_id, :name])
  end
end
