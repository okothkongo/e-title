defmodule ETitle.Lands.Schemas.LandEncumbrance do
  @moduledoc """
  Land Encumbrance Schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ETitle.Accounts.Schemas.Account
  alias ETitle.Lands.Schemas.Land

  @statuses ~w(active inactive dismissed pending)a
  @reasons ~w(loan bond)a

  schema "land_encumbrances" do
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :reason, Ecto.Enum, values: @reasons
    field :identity_doc_no, :string, virtual: true
    field :approved_at, :utc_datetime
    field :dismissed_at, :utc_datetime
    field :deactivated_at, :utc_datetime

    belongs_to :land, Land
    belongs_to :created_by, Account, foreign_key: :created_by_id
    belongs_to :created_for, Account, foreign_key: :created_for_id
    belongs_to :approved_by, Account, foreign_key: :approved_by_id
    belongs_to :dismissed_by, Account, foreign_key: :dismissed_by_id
    belongs_to :deactivated_by, Account, foreign_key: :deactivated_by_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(land_encumbrance, attrs, account_scope) do
    land_encumbrance
    |> cast(attrs, [
      :land_id,
      :reason,
      :created_for_id,
      :identity_doc_no
    ])
    |> validate_required([:land_id, :reason])
    |> put_change(:created_by_id, account_scope.account.id)
    |> validate_created_by_role(account_scope)
    |> validate_created_for_assignment()
  end

  def approval_changeset(land_encumbrance, attrs, account_scope) do
    land_encumbrance
    |> cast(attrs, [:status])
    |> validate_required([:status])
    |> put_change(:approved_by_id, account_scope.account.id)
    |> put_change(:approved_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> validate_approver_role(account_scope)
    |> validate_status_transition(land_encumbrance.status)
  end

  def dismissal_changeset(land_encumbrance, attrs, account_scope) do
    land_encumbrance
    |> cast(attrs, [:status])
    |> validate_required([:status])
    |> put_change(:dismissed_by_id, account_scope.account.id)
    |> put_change(:dismissed_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> validate_dismisser_role(account_scope)
    |> validate_status_transition(land_encumbrance.status)
  end

  def deactivation_changeset(land_encumbrance, attrs, account_scope) do
    land_encumbrance
    |> cast(attrs, [:status])
    |> validate_required([:status])
    |> put_change(:deactivated_by_id, account_scope.account.id)
    |> put_change(:deactivated_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> validate_deactivator_role(account_scope)
    |> validate_status_transition(land_encumbrance.status)
  end

  defp validate_created_by_role(changeset, account_scope) do
    if ETitle.Accounts.account_has_role?(account_scope.account, "surveyor") or
         ETitle.Accounts.account_has_role?(account_scope.account, "lawyer") do
      changeset
    else
      add_error(
        changeset,
        :created_by_id,
        "Only surveyors or lawyers can create land encumbrances"
      )
    end
  end

  defp validate_approver_role(changeset, account_scope) do
    if ETitle.Accounts.account_has_role?(account_scope.account, "land_registrar") do
      changeset
    else
      add_error(changeset, :approved_by_id, "Only land registrars can approve land encumbrances")
    end
  end

  defp validate_dismisser_role(changeset, account_scope) do
    if ETitle.Accounts.account_has_role?(account_scope.account, "land_registrar") do
      changeset
    else
      add_error(changeset, :dismissed_by_id, "Only land registrars can dismiss land encumbrances")
    end
  end

  defp validate_deactivator_role(changeset, account_scope) do
    if ETitle.Accounts.account_has_role?(account_scope.account, "land_registrar") do
      changeset
    else
      add_error(
        changeset,
        :deactivated_by_id,
        "Only land registrars can deactivate land encumbrances"
      )
    end
  end

  defp validate_created_for_assignment(changeset) do
    identity_doc_no = get_field(changeset, :identity_doc_no)

    if is_nil(identity_doc_no) or identity_doc_no == "" do
      add_error(changeset, :identity_doc_no, "Identity document number is required")
    else
      assign_citizen_account(changeset, identity_doc_no)
    end
  end

  defp assign_citizen_account(changeset, identity_doc_no) do
    case ETitle.Accounts.get_citizen_account_by_identity_doc_no(identity_doc_no) do
      nil -> add_error(changeset, :identity_doc_no, "Citizen not found")
      account -> put_change(changeset, :created_for_id, account.id)
    end
  end

  defp validate_status_transition(changeset, current_status) do
    new_status = get_change(changeset, :status)

    case {current_status, new_status} do
      {:pending, new_status} when new_status in [:active, :dismissed] ->
        changeset

      {:pending, _new_status} ->
        add_error(changeset, :status, "Cannot deactivate pending encumbrances")

      {:dismissed, _} ->
        add_error(changeset, :status, "encumbrance already dismissed")

      {:active, :inactive} ->
        changeset

      {:active, _} ->
        add_error(changeset, :status, "Can only deactivate active encumbrances")

      {:inactive, _} ->
        add_error(changeset, :status, "encumbrance already inactive")
    end
  end
end
