defmodule ETitle.Accounts.User do
  @moduledoc """
  User schema and changeset functions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :middle_name, :string
    field :surname, :string
    field :identity_document, :string

    timestamps(type: :utc_datetime)
    has_many :accounts, ETitle.Accounts.Account
  end

  @doc false
  def changeset(user, attrs, _account_scope) do
    user
    |> cast(attrs, [:first_name, :middle_name, :surname, :identity_document])
    |> validate_required([:first_name, :middle_name, :surname, :identity_document])
    |> unique_constraint(:identity_document)
  end

  def user_and_account_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :middle_name, :surname, :identity_document])
    |> validate_required([:first_name, :middle_name, :surname, :identity_document])
    |> unique_constraint(:identity_document)
    |> cast_assoc(:accounts, with: &ETitle.Accounts.Account.email_changeset/2, required: true)
  end
end
