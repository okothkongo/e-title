defmodule ETitle.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:name])

    create table(:account_roles) do
      add :account_id, references(:accounts, on_delete: :nothing), null: false
      add :role_id, references(:roles, on_delete: :nothing), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:account_roles, [:role_id])
    create unique_index(:account_roles, [:account_id])
  end
end
