defmodule ETitle.Accounts.Schemas.Identity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "identities" do
    field :first_name, :string
    field :other_names, :string
    field :surname, :string
    field :birth_date, :date
    field :id_doc, :string
    field :nationality, :string
    field :kra_pin, :string
    field :passport_photo, :string

    timestamps(type: :utc_datetime)
  end

  @identity_required_fields [
    :first_name,
    :other_names,
    :surname,
    :birth_date,
    :id_doc,
    :nationality,
    :kra_pin,
    :passport_photo
  ]

  @doc false
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, @identity_required_fields ++ [:other_names])
    |> validate_required(@identity_required_fields)
    |> unique_constraint(:kra_pin)
    |> unique_constraint([:id_doc, :nationality])
  end
end
