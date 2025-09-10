defmodule ETitle.Accounts.Schemas.AccountRole do
  @moduledoc """
    Handles account role data.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ETitle.Accounts
  alias ETitle.Accounts.Schemas.Account
  alias ETitle.Accounts.Schemas.Role

  schema "account_roles" do
    belongs_to :account, Account
    belongs_to :role, Role
    timestamps(type: :utc_datetime)
  end

  @staff_roles ~w(land_registrar land_registry_clerk land_board_chair land_board_clerk admin)
  @professional_roles ~w(lawyer surveyor)
  def changeset(account_role, attrs) do
    account_role
    |> cast(attrs, [:account_id, :role_id])
    |> validate_required([:account_id, :role_id])
    |> unique_constraint([:account_id])
    |> validate_account_role_match()
  end

  defp validate_account_role_match(
         %Ecto.Changeset{changes: %{account_id: account_id, role_id: role_id}} = changeset
       ) do
    account = Accounts.get_account(account_id)
    role = Accounts.get_role(role_id)

    cond do
      is_nil(account) or is_nil(role) ->
        changeset

      check_account_type_and_role_match(account.type, role.name) == :ok ->
        changeset

      true ->
        add_error(
          changeset,
          :role_id,
          "Role #{role.name} is not valid for account type #{account.type}"
        )
    end
  end

  defp validate_account_role_match(changeset), do: changeset

  defp check_account_type_and_role_match(:citizen, "user"), do: :ok

  defp check_account_type_and_role_match(:professional, role_name)
       when role_name in @professional_roles,
       do: :ok

  defp check_account_type_and_role_match(:staff, role_name) when role_name in @staff_roles,
    do: :ok

  defp check_account_type_and_role_match(_, _), do: :error

  def get_staff_roles do
    @staff_roles
  end

  def get_professional_roles do
    @professional_roles
  end
end
