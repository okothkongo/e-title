defmodule ETitle.Repo.Migrations.AddStatusToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :status, :string, default: "active", null: false
    end
  end
end
