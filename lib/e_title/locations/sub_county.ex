defmodule ETitle.Locations.SubCounty do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sub_counties" do
    field :name, :string
    belongs_to :county, ETitle.Locations.County
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sub_county, attrs) do
    sub_county
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:county_id, :name])
  end
end
