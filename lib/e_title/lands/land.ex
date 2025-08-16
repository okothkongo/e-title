defmodule ETitle.Lands.Land do
  @moduledoc """
  Represents a piece of land in the system.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "lands" do
    field :title_number, :string
    field :size, :decimal
    field :gps_coordinates, :string
    field :status, Ecto.Enum, values: [:active, :disputed, :pending_approval]
    field :blockchain_hash, :string
    belongs_to :user, ETitle.Accounts.User, foreign_key: :owner_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(land, attrs, user_scope) do
    land
    |> cast(attrs, [:title_number, :size, :gps_coordinates, :status, :blockchain_hash])
    |> validate_required([:title_number, :size, :gps_coordinates, :status, :blockchain_hash])
    |> unique_constraint(:title_number)
    |> put_change(:owner_id, user_scope.user.id)
  end
end
