defmodule ETitle.Locations.SubCounty do
  @moduledoc """
    Handles sub-county data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "sub_counties" do
    field :name, :string
    belongs_to :county, ETitle.Locations.County
    has_many :registries, ETitle.Locations.Registry

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sub_county, attrs) do
    sub_county
    |> cast(attrs, [:name, :sub_county_id])
    |> validate_required([:name, :sub_county_id])
    |> unique_constraint([:county_id, :name])
  end
end
