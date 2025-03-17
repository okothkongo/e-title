defmodule ETitle.AccountsTest do
  use ETitle.DataCase

  alias ETitle.Accounts

  describe "identities" do
    alias ETitle.Accounts.Identity

    import ETitle.AccountsFixtures

    @invalid_attrs %{
      first_name: nil,
      other_names: nil,
      surname: nil,
      birth_date: nil,
      id_doc: nil,
      nationality: nil,
      kra_pin: nil,
      passport_photo: nil
    }

    test "list_identities/0 returns all identities" do
      identity = identity_fixture()
      assert Accounts.list_identities() == [identity]
    end

    test "get_identity!/1 returns the identity with given id" do
      identity = identity_fixture()
      assert Accounts.get_identity!(identity.id) == identity
    end

    test "create_identity/1 with valid data creates a identity" do
      valid_attrs = %{
        first_name: "some first_name",
        other_names: "some other_names",
        surname: "some surname",
        birth_date: ~D[2025-03-16],
        id_doc: "some id_doc",
        nationality: "some nationality",
        kra_pin: "some kra_pin",
        passport_photo: "some passport_photo"
      }

      assert {:ok, %Identity{} = identity} = Accounts.create_identity(valid_attrs)
      assert identity.first_name == "some first_name"
      assert identity.other_names == "some other_names"
      assert identity.surname == "some surname"
      assert identity.birth_date == ~D[2025-03-16]
      assert identity.id_doc == "some id_doc"
      assert identity.nationality == "some nationality"
      assert identity.kra_pin == "some kra_pin"
      assert identity.passport_photo == "some passport_photo"
    end

    test "create_identity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_identity(@invalid_attrs)
    end

    test "update_identity/2 with valid data updates the identity" do
      identity = identity_fixture()

      update_attrs = %{
        first_name: "some updated first_name",
        other_names: "some updated other_names",
        surname: "some updated surname",
        birth_date: ~D[2025-03-17],
        id_doc: "some updated id_doc",
        nationality: "some updated nationality",
        kra_pin: "some updated kra_pin",
        passport_photo: "some updated passport_photo"
      }

      assert {:ok, %Identity{} = identity} = Accounts.update_identity(identity, update_attrs)
      assert identity.first_name == "some updated first_name"
      assert identity.other_names == "some updated other_names"
      assert identity.surname == "some updated surname"
      assert identity.birth_date == ~D[2025-03-17]
      assert identity.id_doc == "some updated id_doc"
      assert identity.nationality == "some updated nationality"
      assert identity.kra_pin == "some updated kra_pin"
      assert identity.passport_photo == "some updated passport_photo"
    end

    test "update_identity/2 with invalid data returns error changeset" do
      identity = identity_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_identity(identity, @invalid_attrs)
      assert identity == Accounts.get_identity!(identity.id)
    end

    test "delete_identity/1 deletes the identity" do
      identity = identity_fixture()
      assert {:ok, %Identity{}} = Accounts.delete_identity(identity)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_identity!(identity.id) end
    end

    test "change_identity/1 returns a identity changeset" do
      identity = identity_fixture()
      assert %Ecto.Changeset{} = Accounts.change_identity(identity)
    end
  end
end
