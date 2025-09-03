defmodule ETitle.Locations.County do
  @moduledoc """
    Handles county data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "counties" do
    field :name, :string
    field :code, :string
    has_many :sub_counties, ETitle.Locations.SubCounty

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(county, attrs) do
    county
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
    |> unique_constraint(:name)
    |> cast_assoc(:sub_counties, with: &ETitle.Locations.SubCounty.changeset/2, required: true)
  end
end
