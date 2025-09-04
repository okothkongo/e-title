defmodule ETitle.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias ETitle.Repo

  alias ETitle.Locations.Registry

  @doc """
  Returns the list of registries.

  ## Examples

      iex> list_registries(scope)
      [%Registry{}, ...]

  """
  def list_registries do
    Repo.all(Registry)
  end

  @doc """
  Gets a single registry.

  Raises `Ecto.NoResultsError` if the Registry does not exist.

  ## Examples

      iex> get_registry!(scope, 123)
      %Registry{}

      iex> get_registry!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_registry!(id) do
    Repo.get!(Registry, id)
  end

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
  Updates a registry.

  ## Examples

      iex> update_registry(scope, registry, %{field: new_value})
      {:ok, %Registry{}}

      iex> update_registry(scope, registry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registry(%Registry{} = registry, attrs) do
    registry
    |> Registry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a registry.

  ## Examples

      iex> delete_registry(scope, registry)
      {:ok, %Registry{}}

      iex> delete_registry(scope, registry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registry(%Registry{} = registry) do
    Repo.delete(registry)
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
end
