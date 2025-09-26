defmodule ETitle.LandsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ETitle.Lands` context.
  """

  @doc """
  Generate a unique land gps_cordinates.
  """
  def unique_land_gps_cordinates, do: "some gps_cordinates#{System.unique_integer([:positive])}"

  @doc """
  Generate a land.
  """
  def land_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        gps_cordinates: unique_land_gps_cordinates(),
        size: "120.5",
        title_number: "some title_number"
      })

    {:ok, land} = ETitle.Lands.create_land(scope, attrs)
    land
  end
end
