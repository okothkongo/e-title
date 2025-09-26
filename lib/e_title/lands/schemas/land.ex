defmodule ETitle.Lands.Schemas.Land do
  @moduledoc """
   Land Schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ETitle.Locations.Schemas.Registry
  alias ETitle.Accounts.Schemas.Account

  schema "lands" do
    field :title_number, :string
    field :size, :decimal
    field :gps_cordinates, :string
    field :identity_doc_no, :string, virtual: true
    belongs_to :registry, Registry
    belongs_to :account, Account
    belongs_to :created_by, Account, foreign_key: :created_by_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(land, attrs, account_scope) do
    land
    |> cast(attrs, [
      :title_number,
      :size,
      :gps_cordinates,
      :registry_id,
      :account_id,
      :identity_doc_no
    ])
    |> validate_required([:title_number, :size, :gps_cordinates, :registry_id])
    |> unique_constraint(:gps_cordinates)
    |> put_change(:created_by_id, account_scope.account.id)
    |> validate_account_assignment(account_scope)
  end

  defp validate_account_assignment(changeset, account_scope) do
    cond do
      ETitle.Accounts.account_has_role?(account_scope.account, "user") ->
        put_change(changeset, :account_id, account_scope.account.id)

      ETitle.Accounts.account_has_role?(account_scope.account, "admin") ->
        case get_field(changeset, :identity_doc_no) do
          nil ->
            add_error(changeset, :identity_doc_no, "Identity document number is required")

          "" ->
            add_error(changeset, :identity_doc_no, "Identity document number is required")

          identity_doc_no ->
            case ETitle.Accounts.get_citizen_account_by_identity_doc_no(identity_doc_no) do
              nil -> add_error(changeset, :identity_doc_no, "Citizen not found")
              account -> put_change(changeset, :account_id, account.id)
            end
        end

      true ->
        add_error(changeset, :account_id, "Only citizens and admins can create land")
    end
  end
end
