defmodule ETitle.Repo.Migrations.CreateSubCounties do
  use Ecto.Migration

  def change do
    create table(:sub_counties) do
      add :name, :string
      add :county_id, references(:counties, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sub_counties, [:county_id])

    create unique_index(:sub_counties, [:county_id, :name])
  end
end
