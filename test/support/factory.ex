defmodule ETitle.Factory do
  @moduledoc """
  Factory for creating test data
  """
  alias ETitle.Accounts.Schemas.Identity
  alias ETitle.Repo

  def build(:identity) do
    %Identity{
      first_name: "John",
      other_names: "Doe",
      surname: "Doe",
      birth_date: ~D[2025-03-16],
      id_doc: "1234567890",
      nationality: "Kenya",
      kra_pin: "some kra_pin#{System.unique_integer([:positive])}",
      passport_photo: "some passport_photo"
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
