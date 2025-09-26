defmodule ETitle.LandsTest do
  use ETitle.DataCase
  import ETitle.Factory
  alias ETitle.Lands

  describe "lands" do
    alias ETitle.Lands.Schemas.Land

    @invalid_attrs %{size: nil, title_number: nil, gps_cordinates: nil}

    # test "list_lands/1 returns all scoped lands" do
    #   scope = account_scope_fixture()
    #   other_scope = account_scope_fixture()
    #   land = land_fixture(scope)
    #   other_land = land_fixture(other_scope)
    #   assert Lands.list_lands(scope) == [land]
    #   assert Lands.list_lands(other_scope) == [other_land]
    # end

    # test "get_land!/2 returns the land with given id" do
    #   scope = account_scope_fixture()
    #   land = land_fixture(scope)
    #   other_scope = account_scope_fixture()
    #   assert Lands.get_land!(scope, land.id) == land
    #   assert_raise Ecto.NoResultsError, fn -> Lands.get_land!(other_scope, land.id) end
    # end

    test "create_land/2 with valid data creates a land" do
      account = insert(:account)
      user_role = insert(:role, name: "user", type: :citizen)
      insert(:account_role, account: account, role: user_role)
      registry = insert(:registry)

      valid_attrs = %{
        size: "120.5",
        title_number: "some title_number",
        gps_cordinates: "some gps_cordinates",
        registry_id: registry.id
      }

      scope = build(:account_scope, account: account)

      assert {:ok, %Land{} = land} = Lands.create_land(scope, valid_attrs)
      assert land.size == Decimal.new("120.5")
      assert land.title_number == "some title_number"
      assert land.gps_cordinates == "some gps_cordinates"
      assert land.account_id == scope.account.id
      assert land.created_by_id == scope.account.id
    end

    test "create_land/2 with invalid data returns error changeset" do
      account = insert(:account)
      user_role = insert(:role, name: "user", type: :citizen)
      insert(:account_role, account: account, role: user_role)
      scope = build(:account_scope, account: account)
      assert {:error, %Ecto.Changeset{}} = Lands.create_land(scope, @invalid_attrs)
    end

    # test "update_land/3 with valid data updates the land" do
    #   scope = account_scope_fixture()
    #   land = land_fixture(scope)

    #   update_attrs = %{
    #     size: "456.7",
    #     title_number: "some updated title_number",
    #     gps_cordinates: "some updated gps_cordinates"
    #   }

    #   assert {:ok, %Land{} = land} = Lands.update_land(scope, land, update_attrs)
    #   assert land.size == Decimal.new("456.7")
    #   assert land.title_number == "some updated title_number"
    #   assert land.gps_cordinates == "some updated gps_cordinates"
    # end

    # test "update_land/3 with invalid scope raises" do
    #   scope = account_scope_fixture()
    #   other_scope = account_scope_fixture()
    #   land = land_fixture(scope)

    #   assert_raise MatchError, fn ->
    #     Lands.update_land(other_scope, land, %{})
    #   end
    # end

    # test "update_land/3 with invalid data returns error changeset" do
    #   scope = account_scope_fixture()
    #   land = land_fixture(scope)
    #   assert {:error, %Ecto.Changeset{}} = Lands.update_land(scope, land, @invalid_attrs)
    #   assert land == Lands.get_land!(scope, land.id)
    # end

    # test "delete_land/2 deletes the land" do
    #   scope = account_scope_fixture()
    #   land = land_fixture(scope)
    #   assert {:ok, %Land{}} = Lands.delete_land(scope, land)
    #   assert_raise Ecto.NoResultsError, fn -> Lands.get_land!(scope, land.id) end
    # end

    # test "delete_land/2 with invalid scope raises" do
    #   scope = account_scope_fixture()
    #   other_scope = account_scope_fixture()
    #   land = land_fixture(scope)
    #   assert_raise MatchError, fn -> Lands.delete_land(other_scope, land) end
    # end

    # test "change_land/2 returns a land changeset" do
    #   scope = account_scope_fixture()
    #   land = land_fixture(scope)
    #   assert %Ecto.Changeset{} = Lands.change_land(scope, land)
    # end
  end

  describe "search_land_by_title_number/1" do
    test "returns land when found with valid title number" do
      # Create a user and account
      user = insert(:user, first_name: "John", surname: "Doe", identity_doc_no: "12345678")
      account = insert(:account, user: user, type: :citizen)
      user_role = insert(:role, name: "user", type: :citizen)
      insert(:account_role, account: account, role: user_role)

      # Create a registry
      registry = insert(:registry, name: "Nairobi Registry")

      # Create a land
      land =
        insert(:land,
          title_number: "T123456",
          size: Decimal.new("100.5"),
          gps_cordinates: "1.2921,36.8219",
          account: account,
          registry: registry
        )

      # Search for the land
      assert {:ok, found_land} = Lands.search_land_by_title_number("T123456")

      # Verify the land details
      assert found_land.id == land.id
      assert found_land.title_number == "T123456"
      assert found_land.size == Decimal.new("100.5")
      assert found_land.gps_cordinates == "1.2921,36.8219"

      # Verify preloaded associations
      assert found_land.account.id == account.id
      assert found_land.account.user.first_name == "John"
      assert found_land.account.user.surname == "Doe"
      assert found_land.account.user.identity_doc_no == "12345678"
      assert found_land.registry.name == "Nairobi Registry"
    end

    test "returns error when land not found" do
      assert {:error, :not_found} = Lands.search_land_by_title_number("NONEXISTENT")
    end

    test "returns error for invalid input" do
      assert {:error, :invalid_input} = Lands.search_land_by_title_number(nil)
      assert {:error, :invalid_input} = Lands.search_land_by_title_number(123)
      assert {:error, :invalid_input} = Lands.search_land_by_title_number("")
    end

    test "is case sensitive" do
      # Create a land with specific case
      user = insert(:user)
      account = insert(:account, user: user, type: :citizen)
      user_role = insert(:role, name: "user", type: :citizen)
      insert(:account_role, account: account, role: user_role)
      registry = insert(:registry)

      _land = insert(:land, title_number: "T123456", account: account, registry: registry)

      # Search with different case should not find it
      assert {:error, :not_found} = Lands.search_land_by_title_number("t123456")
      assert {:error, :not_found} = Lands.search_land_by_title_number("T12345")
    end
  end
end
