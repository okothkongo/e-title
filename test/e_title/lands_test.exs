defmodule ETitle.LandsTest do
  use ETitle.DataCase

  alias ETitle.Lands

  describe "lands" do
    alias ETitle.Lands.Land

    import ETitle.AccountsFixtures, only: [user_scope_fixture: 0]
    import ETitle.LandsFixtures

    @invalid_attrs %{
      size: nil,
      status: nil,
      title_number: nil,
      gps_coordinates: nil,
      blockchain_hash: nil
    }

    test "list_lands/1 returns all scoped lands" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      land = land_fixture(scope)
      other_land = land_fixture(other_scope)
      assert Lands.list_lands(scope) == [land]
      assert Lands.list_lands(other_scope) == [other_land]
    end

    test "get_land!/2 returns the land with given id" do
      scope = user_scope_fixture()
      land = land_fixture(scope)
      other_scope = user_scope_fixture()
      assert Lands.get_land!(scope, land.id) == land
      assert_raise Ecto.NoResultsError, fn -> Lands.get_land!(other_scope, land.id) end
    end

    test "create_land/2 with valid data creates a land" do
      valid_attrs = %{
        size: "120.5",
        status: :active,
        title_number: "some title_number",
        gps_coordinates: "some gps_coordinates",
        blockchain_hash: "some blockchain_hash"
      }

      scope = user_scope_fixture()

      assert {:ok, %Land{} = land} = Lands.create_land(scope, valid_attrs)
      assert land.size == Decimal.new("120.5")
      assert land.status == :active
      assert land.title_number == "some title_number"
      assert land.gps_coordinates == "some gps_coordinates"
      assert land.blockchain_hash == "some blockchain_hash"
      assert land.owner_id == scope.user.id
    end

    test "create_land/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Lands.create_land(scope, @invalid_attrs)
    end

    test "update_land/3 with valid data updates the land" do
      scope = user_scope_fixture()
      land = land_fixture(scope)

      update_attrs = %{
        size: "456.7",
        status: :disputed,
        title_number: "some updated title_number",
        gps_coordinates: "some updated gps_coordinates",
        blockchain_hash: "some updated blockchain_hash"
      }

      assert {:ok, %Land{} = land} = Lands.update_land(scope, land, update_attrs)
      assert land.size == Decimal.new("456.7")
      assert land.status == :disputed
      assert land.title_number == "some updated title_number"
      assert land.gps_coordinates == "some updated gps_coordinates"
      assert land.blockchain_hash == "some updated blockchain_hash"
    end

    test "update_land/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      land = land_fixture(scope)

      assert_raise MatchError, fn ->
        Lands.update_land(other_scope, land, %{})
      end
    end

    test "update_land/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      land = land_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Lands.update_land(scope, land, @invalid_attrs)
      assert land == Lands.get_land!(scope, land.id)
    end

    test "delete_land/2 deletes the land" do
      scope = user_scope_fixture()
      land = land_fixture(scope)
      assert {:ok, %Land{}} = Lands.delete_land(scope, land)
      assert_raise Ecto.NoResultsError, fn -> Lands.get_land!(scope, land.id) end
    end

    test "delete_land/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      land = land_fixture(scope)
      assert_raise MatchError, fn -> Lands.delete_land(other_scope, land) end
    end

    test "change_land/2 returns a land changeset" do
      scope = user_scope_fixture()
      land = land_fixture(scope)
      assert %Ecto.Changeset{} = Lands.change_land(scope, land)
    end
  end
end
