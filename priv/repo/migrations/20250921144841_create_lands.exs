defmodule ETitle.Repo.Migrations.CreateLands do
  use Ecto.Migration

  def change do
    create table(:lands) do
      add :title_number, :string
      add :size, :decimal
      add :gps_cordinates, :string
      add :account_id, references(:accounts, on_delete: :nothing)
      add :registry_id, references(:registries, on_delete: :nothing)


      timestamps(type: :utc_datetime)
    end

    create index(:lands, [:account_id])

    create unique_index(:lands, [:gps_cordinates])

    create index(:lands, [:registry_id])
  end
end
