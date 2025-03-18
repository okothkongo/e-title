defmodule ETitle.AccountsTest do
  use ETitle.DataCase

  alias ETitle.Accounts
  alias ETitle.Factory
  alias ETitle.Accounts.Schemas.Identity

  @valid_attrs %{
    first_name: "some first_name",
    other_names: "some other_names",
    surname: "some surname",
    birth_date: ~D[2025-03-16],
    id_doc: "some id_doc",
    nationality: "some nationality",
    kra_pin: "some kra_pin",
    passport_photo: "some passport_photo"
  }

  @required_fields Identity.required_fields()

  describe "create_identity/1" do
    test "with valid data creates a identity" do
      assert {:ok, %Identity{} = identity} = Accounts.create_identity(@valid_attrs)
      assert identity.first_name == "some first_name"
      assert identity.birth_date == ~D[2025-03-16]
      assert identity.id_doc == "some id_doc"
      assert is_binary(identity.slug)
    end

    for field <- @required_fields do
      test "required field #{field} is validated" do
        field = unquote(field)
        attrs = Map.delete(@valid_attrs, field)
        assert {:error, changeset} = Accounts.create_identity(attrs)
        assert "can't be blank" in errors_on(changeset)[field]
      end
    end

    test "unique kra_pin is validated" do
      assert {:ok, %Identity{}} = Accounts.create_identity(@valid_attrs)
      assert {:error, changeset} = Accounts.create_identity(@valid_attrs)
      assert "has already been taken" in errors_on(changeset).kra_pin
    end

    test "unique id_doc and nationality is validated" do
      assert {:ok, %Identity{}} = Accounts.create_identity(@valid_attrs)

      assert {:error, changeset} =
               Accounts.create_identity(%{@valid_attrs | kra_pin: "some kra_pin 2"})

      assert "has already been taken" in errors_on(changeset).id_doc
    end
  end

  setup do
    identity = Factory.insert!(:identity)
    %{identity: identity}
  end

  describe "update_identity/2" do
    test "with valid data updates the identity", %{identity: identity} do
      assert {:ok, %Identity{} = identity} =
               Accounts.update_identity(identity, %{first_name: "New Name"})

      assert identity.first_name == "New Name"
    end

    test "with invalid data returns error changeset", %{identity: identity} do
      assert {:error, changeset} = Accounts.update_identity(identity, %{first_name: nil})
      assert "can't be blank" in errors_on(changeset).first_name
      assert identity == Accounts.get_identity!(identity.id)
    end
  end

  test "list_identities/0 returns all identities", %{identity: identity} do
    assert Accounts.list_identities() == [identity]
  end

  test "get_identity!/1 returns the identity with given id", %{identity: identity} do
    assert Accounts.get_identity!(identity.id) == identity
  end

  test "change_identity/1 returns a identity changeset", %{identity: identity} do
    assert %Ecto.Changeset{} = Accounts.change_identity(identity)
  end

  test "delete_identity/1 deletes the identity", %{identity: identity} do
    assert {:ok, %Identity{}} = Accounts.delete_identity(identity)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_identity!(identity.id) end
  end
end
