defmodule ETitle.Accounts.User do
  @moduledoc """
    Handles user data.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ETitle.Accounts.Account

  schema "users" do
    field :first_name, :string
    field :middle_name, :string
    field :surname, :string
    field :identity_doc_no, :string
    has_many :accounts, Account

    timestamps(type: :utc_datetime)
  end

  @doc false

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :middle_name, :surname, :identity_doc_no])
    |> cast_assoc(:accounts, with: &ETitle.Accounts.Account.email_changeset/2, required: true)
    |> validate_required([:first_name, :surname, :identity_doc_no])
    |> unique_constraint(:identity_doc_no)
  end
end
