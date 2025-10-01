defmodule ETitle.Repo.Migrations.CreateLandEncumbrances do
  use Ecto.Migration

  def change do
    create table(:land_encumbrances) do
      add :land_id, references(:lands, on_delete: :nothing), null: false
      add :created_by_id, references(:accounts, on_delete: :delete_all), null: false
      add :created_for_id, references(:accounts, on_delete: :nothing), null: false
      add :approved_by_id, references(:accounts, on_delete: :nothing)
      add :dismissed_by_id, references(:accounts, on_delete: :nothing)
      add :deactivated_by_id, references(:accounts, on_delete: :nothing)
      add :status, :string, null: false, default: "pending"
      add :reason, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:land_encumbrances, [:land_id])
    create index(:land_encumbrances, [:created_by_id])
    create index(:land_encumbrances, [:created_for_id])
    create index(:land_encumbrances, [:approved_by_id])
    create index(:land_encumbrances, [:dismissed_by_id])
    create index(:land_encumbrances, [:deactivated_by_id])
  end
end
