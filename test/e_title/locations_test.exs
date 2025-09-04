defmodule ETitle.LocationsTest do
  use ETitle.DataCase

  alias ETitle.Locations

  describe "registries" do
    alias ETitle.Locations.Registry

    import ETitle.AccountsFixtures, only: [account_scope_fixture: 0]
    import ETitle.LocationsFixtures

    @invalid_attrs %{name: nil, phone_number: nil, email: nil}

    test "list_registries/1 returns all scoped registries" do
      scope = account_scope_fixture()
      other_scope = account_scope_fixture()
      registry = registry_fixture(scope)
      other_registry = registry_fixture(other_scope)
      assert Locations.list_registries(scope) == [registry]
      assert Locations.list_registries(other_scope) == [other_registry]
    end

    test "get_registry!/2 returns the registry with given id" do
      scope = account_scope_fixture()
      registry = registry_fixture(scope)
      other_scope = account_scope_fixture()
      assert Locations.get_registry!(scope, registry.id) == registry

      assert_raise Ecto.NoResultsError, fn ->
        Locations.get_registry!(other_scope, registry.id)
      end
    end

    test "create_registry/2 with valid data creates a registry" do
      valid_attrs = %{name: "some name", phone_number: "some phone_number", email: "some email"}
      scope = account_scope_fixture()

      assert {:ok, %Registry{} = registry} = Locations.create_registry(scope, valid_attrs)
      assert registry.name == "some name"
      assert registry.phone_number == "some phone_number"
      assert registry.email == "some email"
      assert registry.account_id == scope.account.id
    end

    test "create_registry/2 with invalid data returns error changeset" do
      scope = account_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.create_registry(scope, @invalid_attrs)
    end

    test "update_registry/3 with valid data updates the registry" do
      scope = account_scope_fixture()
      registry = registry_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        phone_number: "some updated phone_number",
        email: "some updated email"
      }

      assert {:ok, %Registry{} = registry} =
               Locations.update_registry(scope, registry, update_attrs)

      assert registry.name == "some updated name"
      assert registry.phone_number == "some updated phone_number"
      assert registry.email == "some updated email"
    end

    test "update_registry/3 with invalid scope raises" do
      scope = account_scope_fixture()
      other_scope = account_scope_fixture()
      registry = registry_fixture(scope)

      assert_raise MatchError, fn ->
        Locations.update_registry(other_scope, registry, %{})
      end
    end

    test "update_registry/3 with invalid data returns error changeset" do
      scope = account_scope_fixture()
      registry = registry_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Locations.update_registry(scope, registry, @invalid_attrs)

      assert registry == Locations.get_registry!(scope, registry.id)
    end

    test "delete_registry/2 deletes the registry" do
      scope = account_scope_fixture()
      registry = registry_fixture(scope)
      assert {:ok, %Registry{}} = Locations.delete_registry(scope, registry)
      assert_raise Ecto.NoResultsError, fn -> Locations.get_registry!(scope, registry.id) end
    end

    test "delete_registry/2 with invalid scope raises" do
      scope = account_scope_fixture()
      other_scope = account_scope_fixture()
      registry = registry_fixture(scope)
      assert_raise MatchError, fn -> Locations.delete_registry(other_scope, registry) end
    end

    test "change_registry/2 returns a registry changeset" do
      scope = account_scope_fixture()
      registry = registry_fixture(scope)
      assert %Ecto.Changeset{} = Locations.change_registry(scope, registry)
    end
  end
end
