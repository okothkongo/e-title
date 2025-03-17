defmodule ETitle.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :first_name, :string, null: false
      add :other_names, :string
      add :surname, :string, null: false
      add :birth_date, :date, null: false
      add :id_doc, :string, null: false
      add :nationality, :string, null: false
      add :kra_pin, :string, null: false
      add :passport_photo, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:identities, [:kra_pin])
    create unique_index(:identities, [:id_doc, :nationality])
  end
end
