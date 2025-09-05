defmodule ETitle.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias ETitle.Repo

  alias ETitle.Locations.Registry

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
    Repo.all(ETitle.Locations.County)
  end

  def list_sub_counties_by_county_id(county_id) do
    Repo.all(from s in ETitle.Locations.SubCounty, where: s.county_id == ^county_id)
  end
end
