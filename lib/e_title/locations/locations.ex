defmodule ETitle.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias ETitle.Repo

  alias ETitle.Locations.Schemas.County
  alias ETitle.Locations.Schemas.Registry
  alias ETitle.Locations.Schemas.SubCounty

  @doc """
  Creates a registry.

  ## Examples

      iex> create_registry(scope, %{field: value})
      {:ok, %Registry{}}

      iex> create_registry(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registry(attrs) do
    %Registry{}
    |> Registry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registry changes.

  ## Examples

      iex> change_registry(scope, registry)
      %Ecto.Changeset{data: %Registry{}}

  """
  def change_registry(%Registry{} = registry, attrs \\ %{}) do
    Registry.changeset(registry, attrs)
  end

  def list_counties do
    Repo.all(County)
  end

  def list_sub_counties_by_county_id(county_id) do
    Repo.all(from s in SubCounty, where: s.county_id == ^county_id)
  end

  def list_registry_with_county_and_sub_county do
    query =
      from registry in Registry,
        join: county in County,
        on: registry.county_id == county.id,
        join: sub_county in SubCounty,
        on: registry.sub_county_id == sub_county.id,
        preload: [county: county, sub_county: sub_county],
        order_by: [asc: county.name, asc: sub_county.name, asc: registry.name]

    Repo.all(query)
  end

  def list_registries_by_subcount_id(subcounty_id) do
    query =
      from registry in Registry,
        join: sub_county in SubCounty,
        on: registry.sub_county_id == sub_county.id,
        where: sub_county.id == ^subcounty_id

    Repo.all(query)
  end
end
