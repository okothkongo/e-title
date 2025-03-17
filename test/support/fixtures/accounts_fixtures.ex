defmodule ETitle.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ETitle.Accounts` context.
  """

  @doc """
  Generate a unique identity kra_pin.
  """
  def unique_identity_kra_pin, do: "some kra_pin#{System.unique_integer([:positive])}"

  @doc """
  Generate a identity.
  """
  def identity_fixture(attrs \\ %{}) do
    {:ok, identity} =
      attrs
      |> Enum.into(%{
        birth_date: ~D[2025-03-16],
        first_name: "some first_name",
        id_doc: "some id_doc",
        kra_pin: unique_identity_kra_pin(),
        nationality: "some nationality",
        other_names: "some other_names",
        passport_photo: "some passport_photo",
        surname: "some surname"
      })
      |> ETitle.Accounts.create_identity()

    identity
  end
end
