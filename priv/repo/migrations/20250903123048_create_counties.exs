defmodule ETitle.Repo.Migrations.CreateCounties do
  use Ecto.Migration

  def change do
    create table(:counties) do
      add :name, :string
      add :code, :string
      add :account_id, references(:accounts, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:counties, [:account_id])

    create unique_index(:counties, [:code])
    create unique_index(:counties, [:name])
  end
end
