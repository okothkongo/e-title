defmodule ETitle.Lands do
  @moduledoc """
  The Lands context.
  """

  import Ecto.Query, warn: false
  alias ETitle.Repo

  alias ETitle.Lands.Schemas.Land
  alias ETitle.Accounts.Schemas.Scope

  @doc """
  Subscribes to scoped notifications about any land changes.

  The broadcasted messages match the pattern:

    * {:created, %Land{}}
    * {:updated, %Land{}}
    * {:deleted, %Land{}}

  """
  def subscribe_lands(%Scope{} = scope) do
    if ETitle.Accounts.account_has_role?(scope.account, "admin") do
      Phoenix.PubSub.subscribe(ETitle.PubSub, "admin:lands")
    else
      key = scope.account.id
      Phoenix.PubSub.subscribe(ETitle.PubSub, "account:#{key}:lands")
    end
  end

  defp broadcast_land(%Scope{} = scope, message) do
    key = scope.account.id

    Phoenix.PubSub.broadcast(ETitle.PubSub, "account:#{key}:lands", message)
    Phoenix.PubSub.broadcast(ETitle.PubSub, "admin:lands", message)
  end

  @doc """
  Returns the list of lands.

  ## Examples

      iex> list_lands(scope)
      [%Land{}, ...]

  """
  def list_lands(%Scope{} = scope) do
    if ETitle.Accounts.account_has_role?(scope.account, "admin") do
      query = from(l in Land, preload: [:registry, account: :user])
      Repo.all(query)
    else
      Repo.all_by(Land, account_id: scope.account.id)
    end
  end

  @doc """
  Gets a single land.

  Raises `Ecto.NoResultsError` if the Land does not exist.

  ## Examples

      iex> get_land!(scope, 123)
      %Land{}

      iex> get_land!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_land!(%Scope{} = scope, id) do
    if ETitle.Accounts.account_has_role?(scope.account, "admin") do
      query = from(l in Land, preload: [:registry, account: :user])
      Repo.get!(query, id)
    else
      Repo.get_by!(Land, id: id, account_id: scope.account.id)
    end
  end

  @doc """
  Creates a land.

  ## Examples

      iex> create_land(scope, %{field: value})
      {:ok, %Land{}}

      iex> create_land(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_land(%Scope{} = scope, attrs) do
    with {:ok, land = %Land{}} <-
           %Land{}
           |> Land.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_land(scope, {:created, land})
      {:ok, land}
    end
  end

  @doc """
  Updates a land.

  ## Examples

      iex> update_land(scope, land, %{field: new_value})
      {:ok, %Land{}}

      iex> update_land(scope, land, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_land(%Scope{} = scope, %Land{} = land, attrs) do
    unless ETitle.Accounts.account_has_role?(scope.account, "admin") do
      true = land.account_id == scope.account.id
    end

    with {:ok, land = %Land{}} <-
           land
           |> Land.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_land(scope, {:updated, land})
      {:ok, land}
    end
  end

  @doc """
  Deletes a land.

  ## Examples

      iex> delete_land(scope, land)
      {:ok, %Land{}}

      iex> delete_land(scope, land)
      {:error, %Ecto.Changeset{}}

  """
  def delete_land(%Scope{} = scope, %Land{} = land) do
    unless ETitle.Accounts.account_has_role?(scope.account, "admin") do
      true = land.account_id == scope.account.id
    end

    with {:ok, land = %Land{}} <-
           Repo.delete(land) do
      broadcast_land(scope, {:deleted, land})
      {:ok, land}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking land changes.

  ## Examples

      iex> change_land(scope, land)
      %Ecto.Changeset{data: %Land{}}

  """
  def change_land(%Scope{} = scope, %Land{} = land, attrs \\ %{}) do
    Land.changeset(land, attrs, scope)
  end

  @doc """
  Searches for a land by title number.


  ## Examples

      iex> search_land_by_title_number("T123456")
      {:ok, %Land{}}

      iex> search_land_by_title_number("INVALID")
      {:error, :not_found}

  """
  def search_land_by_title_number(title_number) when is_binary(title_number) do
    trimmed_title = String.trim(title_number)
    search_land_by_title_number_trimmed(trimmed_title)
  end

  def search_land_by_title_number(_), do: {:error, :invalid_input}

  defp search_land_by_title_number_trimmed("") do
    {:error, :invalid_input}
  end

  defp search_land_by_title_number_trimmed(title_number) do
    query =
      from(l in Land,
        preload: [:registry, account: :user],
        where: l.title_number == ^title_number
      )

    case Repo.one(query) do
      nil -> {:error, :not_found}
      land -> {:ok, land}
    end
  end
end
