defmodule ETitle.LandsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ETitle.Lands` context.
  """

  @doc """
  Generate a unique land title_number.
  """
  def unique_land_title_number, do: "some title_number#{System.unique_integer([:positive])}"

  @doc """
  Generate a land.
  """
  def land_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        blockchain_hash: "some blockchain_hash",
        gps_coordinates: "some gps_coordinates",
        size: "120.5",
        status: :active,
        title_number: unique_land_title_number()
      })

    {:ok, land} = ETitle.Lands.create_land(scope, attrs)
    land
  end
end
