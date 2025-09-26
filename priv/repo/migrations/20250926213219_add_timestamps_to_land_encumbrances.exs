defmodule ETitle.Repo.Migrations.AddTimestampsToLandEncumbrances do
  use Ecto.Migration

  def change do
    alter table(:land_encumbrances) do
      add :approved_at, :utc_datetime
      add :dismissed_at, :utc_datetime
      add :deactivated_at, :utc_datetime
    end
  end
end
