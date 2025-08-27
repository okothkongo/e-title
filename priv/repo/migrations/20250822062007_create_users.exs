defmodule ETitle.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string, null: false
      add :middle_name, :string, null: false
      add :surname, :string
      add :identity_document, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:identity_document])

    alter table(:accounts) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end

    create index(:accounts, [:user_id])
    create unique_index(:accounts, [:phone_number])
  end
end
