defmodule ETitle.LocationsTest do
  use ETitle.DataCase
  import ETitle.Factory

  alias ETitle.Locations
  alias ETitle.Locations.Schemas.Registry

  describe "create_registry/2 " do
    @invalid_attrs %{name: nil, phone_number: nil, email: nil}

    test "with valid data creates a registry" do
      county = insert(:county)
      sub_county = insert(:sub_county, county: county)

      valid_attrs = %{
        name: "some name",
        phone_number: "some phone_number",
        email: "some email",
        county_id: county.id,
        sub_county_id: sub_county.id
      }

      assert {:ok, %Registry{} = registry} = Locations.create_registry(valid_attrs)
      assert registry.name == "some name"
      assert registry.phone_number == "some phone_number"
      assert registry.email == "some email"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_registry(@invalid_attrs)
    end

    test "change_registry/2 returns a registry changeset" do
      registry = insert(:registry)
      assert %Ecto.Changeset{} = Locations.change_registry(registry)
    end
  end

  test "list_counties/0 returns all counties" do
    county = insert(:county)
    assert Locations.list_counties() == [county]
  end

  test "list_sub_counties_by_county_id/1 returns all sub counties for a county" do
    county = insert(:county)

    sub_county1 = insert(:sub_county, county: county)
    sub_county2 = insert(:sub_county, county: county)
    _sub_county3 = insert(:sub_county)

    assert county.id |> Locations.list_sub_counties_by_county_id() |> Repo.preload(:county) == [
             sub_county1,
             sub_county2
           ]
  end
end
