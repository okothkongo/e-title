defmodule ETitle.Locations.Schemas.County do
  @moduledoc """
    Handles county data.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ETitle.Locations.Schemas.Registry
  alias ETitle.Locations.Schemas.SubCounty

  schema "counties" do
    field :name, :string
    field :code, :string
    has_many :sub_counties, SubCounty
    has_many :registries, Registry
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(county, attrs) do
    county
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
    |> unique_constraint(:name)
    |> cast_assoc(:sub_counties, with: &SubCounty.changeset/2, required: true)
  end
end
