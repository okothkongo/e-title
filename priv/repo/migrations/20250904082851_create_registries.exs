defmodule ETitle.Repo.Migrations.CreateRegistries do
  use Ecto.Migration

  def change do
    create table(:registries) do
      add :name, :string
      add :phone_number, :string
      add :email, :string
      add :county_id, references(:counties, on_delete: :delete_all), null: false
      add :sub_county_id, references(:sub_counties, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:registries, [:email])
    create unique_index(:registries, [:phone_number])

    create unique_index(:registries, [:name, :county_id, :sub_county_id],
             name: :unique_registry_in_subcounty
           )
  end
end
