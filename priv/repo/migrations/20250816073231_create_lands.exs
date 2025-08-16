defmodule ETitle.Repo.Migrations.CreateLands do
  use Ecto.Migration

  def change do
    create table(:lands) do
      add :title_number, :string
      add :size, :decimal
      add :gps_coordinates, :string
      add :status, :string
      add :blockchain_hash, :string
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:lands, [:title_number])
    create index(:lands, [:owner_id])
  end
end
