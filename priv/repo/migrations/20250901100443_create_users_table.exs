defmodule ETitle.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string, null: false
      add :middle_name, :string
      add :surname, :string, null: false
      add :identity_doc_no, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:identity_doc_no])

    alter table(:accounts) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end

    create index(:accounts, [:user_id])
  end
end
