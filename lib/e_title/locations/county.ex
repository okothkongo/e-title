defmodule ETitle.Locations.County do
  use Ecto.Schema
  import Ecto.Changeset

  schema "counties" do
    field :name, :string
    field :code, :string
    field :account_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(county, attrs) do
    county
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
    |> unique_constraint(:name)
  end
end
