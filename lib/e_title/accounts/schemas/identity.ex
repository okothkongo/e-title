defmodule ETitle.Accounts.Schemas.Identity do
  @moduledoc """
  Schema for identity
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias ETitle.Accounts.Account

  @project_path File.cwd!()
  @countries "#{@project_path}/priv/data/countries.txt"
             |> File.read!()
             |> Jason.decode!()
             |> Enum.map(&String.to_atom/1)

  schema "identities" do
    field :first_name, :string
    field :other_names, :string
    field :surname, :string
    field :birth_date, :date
    field :id_doc, :string
    field :nationality, Ecto.Enum, values: @countries
    field :kra_pin, :string
    field :passport_photo, :string
    field :slug, :string, default: Ecto.UUID.generate()
    has_many :accounts, Account
    timestamps(type: :utc_datetime)
  end

  @identity_required_fields [
    :first_name,
    :surname,
    :birth_date,
    :id_doc,
    :nationality,
    :kra_pin,
    :passport_photo
  ]
  @min_age 18
  @max_age 200

  @doc false
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, @identity_required_fields ++ [:other_names, :slug])
    |> validate_required(@identity_required_fields)
    |> unique_constraint(:kra_pin)
    |> unique_constraint([:id_doc, :nationality])
    |> validate_age()
    |> cast_assoc(:accounts, with: &Account.registration_changeset/2, required: true)
  end

  def update_changeset(identity, attrs) do
    identity
    |> cast(attrs, @identity_required_fields ++ [:other_names, :slug])
    |> validate_required(@identity_required_fields)
    |> unique_constraint(:kra_pin)
    |> unique_constraint([:id_doc, :nationality])
    |> validate_age()
  end

  def required_fields, do: @identity_required_fields

  defp validate_age(%{changes: %{birth_date: birth_date}} = changeset) do
    today = Date.utc_today()
    age_in_days = Date.diff(today, birth_date)
    min_age = @min_age * 365
    max_age = @max_age * 365

    if age_in_days <= min_age or age_in_days >= max_age do
      add_error(changeset, :birth_date, "must be between #{@min_age} and #{@max_age} years old")
    else
      changeset
    end
  end

  defp validate_age(changeset), do: changeset
end
