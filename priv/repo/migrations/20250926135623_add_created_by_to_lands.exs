defmodule ETitle.Repo.Migrations.AddCreatedByToLands do
  use Ecto.Migration

  def change do
    alter table(:lands) do
      add :created_by_id, references(:accounts, on_delete: :nothing), null: false
    end

    create index(:lands, [:created_by_id])
  end
end
