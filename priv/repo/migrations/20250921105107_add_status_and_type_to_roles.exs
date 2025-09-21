defmodule ETitle.Repo.Migrations.AddStatusAndTypeToRoles do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      add :description, :string
      add :status, :string, null: false
      add :type, :string, null: false
    end

    drop unique_index(:roles, [:name])
    create unique_index(:roles, [:name, :type], name: :unique_role_name_per_type)
  end
end
