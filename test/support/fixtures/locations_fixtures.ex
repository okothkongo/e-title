defmodule ETitle.LocationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ETitle.Locations` context.
  """

  @doc """
  Generate a unique registry email.
  """
  def unique_registry_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique registry phone_number.
  """
  def unique_registry_phone_number, do: "some phone_number#{System.unique_integer([:positive])}"

  @doc """
  Generate a registry.
  """
  def registry_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: unique_registry_email(),
        name: "some name",
        phone_number: unique_registry_phone_number()
      })

    {:ok, registry} = ETitle.Locations.create_registry(scope, attrs)
    registry
  end
end
