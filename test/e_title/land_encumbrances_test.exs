defmodule ETitle.LandEncumbrancesTest do
  use ETitle.DataCase
  import ETitle.Factory
  alias ETitle.Lands
  alias ETitle.Lands.Schemas.LandEncumbrance

  setup do
    # Create a citizen account for created_for
    citizen_user = insert(:user, identity_doc_no: "12345678")
    citizen_account = insert(:account, user: citizen_user, type: :citizen)
    user_role = insert(:role, name: "user", type: :citizen)
    insert(:account_role, account: citizen_account, role: user_role)

    # Create a land
    registry = insert(:registry)
    land = insert(:land, account: citizen_account, registry: registry)

    # Create a surveyor account for created_by
    surveyor_account = insert(:surveyor_account)
    surveyor_role = insert(:surveyor_role)
    insert(:account_role, account: surveyor_account, role: surveyor_role)

    # Create a land registrar account for approval/dismissal/deactivation
    registrar_account = insert(:land_registrar_account)
    registrar_role = insert(:land_registrar_role)
    insert(:account_role, account: registrar_account, role: registrar_role)

    # land_encumbrance = insert(:land_encumbrance, status: :active, created_by: surveyor_account, created_for: citizen_account)

    land_encumbrance_attrs = %{
      land_id: land.id,
      reason: "loan",
      created_for_id: citizen_account.id,
      identity_doc_no: citizen_account.user.identity_doc_no
    }

    {:ok, land_encumbrance} =
      Lands.create_land_encumbrance(
        build(:account_scope, account: surveyor_account),
        land_encumbrance_attrs
      )

    %{
      citizen_account: citizen_account,
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account,
      registrar_account: registrar_account,
      land_encumbrance: land_encumbrance
    }
  end

  describe "land encumbrances" do
    test "create_land_encumbrance/2 with valid data creates a land encumbrance", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)

      assert {:ok, %LandEncumbrance{} = land_encumbrance} =
               Lands.create_land_encumbrance(scope, valid_attrs)

      assert land_encumbrance.land_id == land.id
      assert land_encumbrance.reason == :loan
      assert land_encumbrance.status == :pending
      assert land_encumbrance.created_by_id == surveyor_account.id
    end

    test "create_land_encumbrance/2 with invalid data returns error changeset", %{
      surveyor_account: surveyor_account
    } do
      invalid_attrs = %{land_id: nil, reason: nil}
      scope = build(:account_scope, account: surveyor_account)

      assert {:error, %Ecto.Changeset{}} =
               Lands.create_land_encumbrance(scope, invalid_attrs)
    end

    test "create_land_encumbrance/2 fails when created_by is not a surveyor or lawyer", %{
      citizen_user: citizen_user,
      land: land,
      citizen_account: citizen_account
    } do
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: citizen_account)

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  created_by_id: {"Only surveyors or lawyers can create land encumbrances", []}
                ]
              }} =
               Lands.create_land_encumbrance(scope, valid_attrs)
    end

    test "create_land_encumbrance/2 works with lawyer account", %{
      citizen_user: citizen_user,
      land: land
    } do
      # Create a lawyer account
      lawyer_account = insert(:lawyer_account)
      lawyer_role = insert(:lawyer_role)
      insert(:account_role, account: lawyer_account, role: lawyer_role)

      valid_attrs = %{
        land_id: land.id,
        reason: :bond,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: lawyer_account)

      assert {:ok, %LandEncumbrance{} = land_encumbrance} =
               Lands.create_land_encumbrance(scope, valid_attrs)

      assert land_encumbrance.reason == :bond
      assert land_encumbrance.created_by_id == lawyer_account.id
    end

    test "create_land_encumbrance/2 fails when citizen not found", %{
      land: land,
      surveyor_account: surveyor_account
    } do
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: "nonexistent"
      }

      scope = build(:account_scope, account: surveyor_account)

      assert {:error, %Ecto.Changeset{errors: [identity_doc_no: {"Citizen not found", []}]}} =
               Lands.create_land_encumbrance(scope, valid_attrs)
    end

    test "list_land_encumbrances/1 returns all encumbrances for admin", %{
      land_encumbrance: land_encumbrance
    } do
      # scope = build(:account_scope, account: surveyor_account)

      # Create admin account with admin role
      admin_account = insert(:account, type: :staff)
      admin_role = insert(:admin_role)
      insert(:account_role, account: admin_account, role: admin_role)

      # Admin scope
      admin_scope = build(:account_scope, account: admin_account)
      land_encumbrances = Lands.list_land_encumbrances(admin_scope)

      assert length(land_encumbrances) == 1
      assert hd(land_encumbrances).id == land_encumbrance.id
    end

    test "list_land_encumbrances/1 returns scoped encumbrances for non-admin", %{
      surveyor_account: surveyor_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: surveyor_account)

      # Surveyor scope
      land_encumbrances = Lands.list_land_encumbrances(scope)

      assert length(land_encumbrances) == 1
      assert hd(land_encumbrances).id == land_encumbrance.id
    end

    test "get_land_encumbrance!/2 returns the land encumbrance with given id", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      retrieved_encumbrance = Lands.get_land_encumbrance!(scope, land_encumbrance.id)
      assert retrieved_encumbrance.id == land_encumbrance.id
      assert retrieved_encumbrance.status == land_encumbrance.status
      assert retrieved_encumbrance.reason == land_encumbrance.reason
    end

    test "get_land_encumbrance!/2 raises when land encumbrance not found for user", %{
      surveyor_account: surveyor_account
    } do
      scope = build(:account_scope, account: surveyor_account)

      assert_raise Ecto.NoResultsError, fn ->
        Lands.get_land_encumbrance!(scope, 999_999)
      end
    end

    test "approve_land_encumbrance/3 with valid data approves the land encumbrance", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account,
      registrar_account: registrar_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      surveyor_scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(surveyor_scope, valid_attrs)

      # Approve it
      approval_attrs = %{status: :active}
      registrar_scope = build(:account_scope, account: registrar_account)

      assert {:ok, %LandEncumbrance{} = approved_encumbrance} =
               Lands.approve_land_encumbrance(registrar_scope, land_encumbrance, approval_attrs)

      assert approved_encumbrance.status == :active
      assert approved_encumbrance.approved_by_id == registrar_account.id
    end

    test "approve_land_encumbrance/3 fails when approver is not a land registrar", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      # Try to approve with surveyor account
      approval_attrs = %{status: :active}

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  approved_by_id: {"Only land registrars can approve land encumbrances", []}
                ]
              }} =
               Lands.approve_land_encumbrance(scope, land_encumbrance, approval_attrs)
    end

    test "dismiss_land_encumbrance/3 with valid data dismisses the land encumbrance", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account,
      registrar_account: registrar_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      surveyor_scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(surveyor_scope, valid_attrs)

      # Dismiss it
      dismissal_attrs = %{status: :dismissed}
      registrar_scope = build(:account_scope, account: registrar_account)

      assert {:ok, %LandEncumbrance{} = dismissed_encumbrance} =
               Lands.dismiss_land_encumbrance(registrar_scope, land_encumbrance, dismissal_attrs)

      assert dismissed_encumbrance.status == :dismissed
      assert dismissed_encumbrance.dismissed_by_id == registrar_account.id
    end

    test "dismiss_land_encumbrance/3 fails when dismisser is not a land registrar", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      # Try to dismiss with surveyor account
      dismissal_attrs = %{status: :dismissed}

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  dismissed_by_id: {"Only land registrars can dismiss land encumbrances", []}
                ]
              }} =
               Lands.dismiss_land_encumbrance(scope, land_encumbrance, dismissal_attrs)
    end

    test "deactivate_land_encumbrance/3 fails when deactivator is not a land registrar", %{
      surveyor_account: surveyor_account,
      land_encumbrance: land_encumbrance,
      registrar_account: registrar_account
    } do
      scope = build(:account_scope, account: surveyor_account)
      registrar_scope = build(:account_scope, account: registrar_account)

      {:ok, approved_encumbrance} =
        Lands.approve_land_encumbrance(registrar_scope, land_encumbrance, %{status: :active})

      assert {:error, changeset} =
               Lands.deactivate_land_encumbrance(scope, approved_encumbrance, %{status: :inactive})

      refute changeset.valid?

      assert %{deactivated_by_id: ["Only land registrars can deactivate land encumbrances"]} =
               errors_on(changeset)
    end

    test "update_land_encumbrance/3 with valid data updates the land encumbrance", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      # Update it
      update_attrs = %{reason: :bond}

      assert {:ok, %LandEncumbrance{} = updated_encumbrance} =
               Lands.update_land_encumbrance(scope, land_encumbrance, update_attrs)

      assert updated_encumbrance.reason == :bond
    end

    test "update_land_encumbrance/3 fails when user is not the creator", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      # Try to update with different account
      other_account = insert(:account)
      other_scope = build(:account_scope, account: other_account)
      update_attrs = %{reason: :bond}

      assert_raise MatchError, fn ->
        Lands.update_land_encumbrance(other_scope, land_encumbrance, update_attrs)
      end
    end

    test "delete_land_encumbrance/2 deletes the land encumbrance", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      # Delete it
      assert {:ok, %LandEncumbrance{}} = Lands.delete_land_encumbrance(scope, land_encumbrance)

      assert_raise Ecto.NoResultsError, fn ->
        Lands.get_land_encumbrance!(scope, land_encumbrance.id)
      end
    end

    test "delete_land_encumbrance/2 fails when user is not the creator", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      # Try to delete with different account
      other_account = insert(:account)
      other_scope = build(:account_scope, account: other_account)

      assert_raise MatchError, fn ->
        Lands.delete_land_encumbrance(other_scope, land_encumbrance)
      end
    end

    test "change_land_encumbrance/3 returns a land encumbrance changeset", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(scope, valid_attrs)

      assert %Ecto.Changeset{} = Lands.change_land_encumbrance(scope, land_encumbrance)
    end

    test "change_land_encumbrance_approval/3 returns an approval changeset", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account,
      registrar_account: registrar_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      surveyor_scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(surveyor_scope, valid_attrs)

      registrar_scope = build(:account_scope, account: registrar_account)

      assert %Ecto.Changeset{} =
               Lands.change_land_encumbrance_approval(registrar_scope, land_encumbrance)
    end

    test "change_land_encumbrance_dismissal/3 returns a dismissal changeset", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account,
      registrar_account: registrar_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      surveyor_scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(surveyor_scope, valid_attrs)

      registrar_scope = build(:account_scope, account: registrar_account)

      assert %Ecto.Changeset{} =
               Lands.change_land_encumbrance_dismissal(registrar_scope, land_encumbrance)
    end

    test "change_land_encumbrance_deactivation/3 returns a deactivation changeset", %{
      citizen_user: citizen_user,
      land: land,
      surveyor_account: surveyor_account,
      registrar_account: registrar_account
    } do
      # Create land encumbrance
      valid_attrs = %{
        land_id: land.id,
        reason: :loan,
        identity_doc_no: citizen_user.identity_doc_no
      }

      surveyor_scope = build(:account_scope, account: surveyor_account)
      {:ok, land_encumbrance} = Lands.create_land_encumbrance(surveyor_scope, valid_attrs)

      registrar_scope = build(:account_scope, account: registrar_account)

      assert %Ecto.Changeset{} =
               Lands.change_land_encumbrance_deactivation(registrar_scope, land_encumbrance)
    end
  end

  describe "Action functionality" do
    test "land registrar can approve pending encumbrance", %{
      registrar_account: registrar_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: registrar_account)

      # Approve the encumbrance
      {:ok, updated_encumbrance} =
        Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

      # Verify timestamps are set
      assert updated_encumbrance.approved_at != nil
      assert updated_encumbrance.approved_by_id == registrar_account.id
      assert updated_encumbrance.dismissed_at == nil
      assert updated_encumbrance.deactivated_at == nil
    end

    test "land registrar can dismiss pending encumbrance", %{
      registrar_account: registrar_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: registrar_account)

      # Dismiss the encumbrance
      {:ok, updated_encumbrance} =
        Lands.dismiss_land_encumbrance(scope, land_encumbrance, %{status: :dismissed})

      # Verify timestamps are set
      assert updated_encumbrance.dismissed_at != nil
      assert updated_encumbrance.dismissed_by_id == registrar_account.id
      assert updated_encumbrance.approved_at == nil
      assert updated_encumbrance.deactivated_at == nil
    end

    test "land registrar can deactivate active encumbrance", %{
      registrar_account: registrar_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: registrar_account)

      # First approve the encumbrance to make it active
      {:ok, approved_encumbrance} =
        Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

      # Deactivate the encumbrance
      {:ok, updated_encumbrance} =
        Lands.deactivate_land_encumbrance(scope, approved_encumbrance, %{status: :inactive})

      # # Verify timestamps are set
      assert updated_encumbrance.deactivated_at != nil
      assert updated_encumbrance.deactivated_by_id == registrar_account.id
      assert updated_encumbrance.approved_at != nil
      assert updated_encumbrance.dismissed_at == nil
    end

    # test "admin can approve pending encumbrance", %{admin_account: admin_account, land_encumbrance: land_encumbrance} do
    #   scope = build(:account_scope, account: admin_account)

    #   # Test the context function directly
    #   {:ok, updated_encumbrance} = Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

    #   # Verify the encumbrance was approved
    #   assert updated_encumbrance.status == :active
    #   assert updated_encumbrance.approved_by_id == admin_account.id
    #   assert updated_encumbrance.approved_at != nil
    # end

    # test "admin can dismiss pending encumbrance", %{admin_account: admin_account, land_encumbrance: land_encumbrance} do
    #   scope = build(:account_scope, account: admin_account)

    #   # Test the context function directly
    #   {:ok, updated_encumbrance} = Lands.dismiss_land_encumbrance(scope, land_encumbrance, %{status: :dismissed})

    #   # Verify the encumbrance was dismissed
    #   assert updated_encumbrance.status == :dismissed
    #   assert updated_encumbrance.dismissed_by_id == admin_account.id
    #   assert updated_encumbrance.dismissed_at != nil
    # end

    # test "admin can deactivate active encumbrance", %{admin_account: admin_account, land_encumbrance: land_encumbrance} do
    #   scope = build(:account_scope, account: admin_account)

    #   # First approve the encumbrance to make it active
    #   {:ok, _} = Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

    #   # Test the context function directly
    #   {:ok, updated_encumbrance} = Lands.deactivate_land_encumbrance(scope, land_encumbrance, %{status: :inactive})

    #   # Verify the encumbrance was deactivated
    #   assert updated_encumbrance.status == :inactive
    #   assert updated_encumbrance.deactivated_by_id == admin_account.id
    #   assert updated_encumbrance.deactivated_at != nil
    # end

    test "surveyor cannot approve their own encumbrance", %{
      surveyor_account: surveyor_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: surveyor_account)

      # Test that surveyor cannot approve - should return error
      {:error, changeset} =
        Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

      # Verify the changeset has validation errors
      refute changeset.valid?

      assert %{approved_by_id: ["Only land registrars can approve land encumbrances"]} =
               errors_on(changeset)
    end

    test "citizen cannot approve encumbrance", %{
      citizen_account: citizen_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: citizen_account)

      # Test that citizen cannot approve - should return error
      {:error, changeset} =
        Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

      # Verify the changeset has validation errors
      refute changeset.valid?

      assert %{approved_by_id: ["Only land registrars can approve land encumbrances"]} =
               errors_on(changeset)
    end

    test "cannot approve already active encumbrance", %{
      registrar_account: registrar_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: registrar_account)

      # First approve the encumbrance to make it active
      {:ok, approved_encumbrance} =
        Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

      # Try to approve again - should fail
      {:error, changeset} =
        Lands.approve_land_encumbrance(scope, approved_encumbrance, %{status: :active})

      # Verify the changeset has validation errors
      refute changeset.valid?
      assert %{status: ["Can only deactivate active encumbrances"]} = errors_on(changeset)
    end

    test "cannot dismiss already active encumbrance", %{
      registrar_account: registrar_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: registrar_account)

      # First approve the encumbrance to make it active
      {:ok, approved_encumbrance} =
        Lands.approve_land_encumbrance(scope, land_encumbrance, %{status: :active})

      # Try to dismiss active encumbrance - should fail
      {:error, changeset} =
        Lands.dismiss_land_encumbrance(scope, approved_encumbrance, %{status: :dismissed})

      # # Verify the changeset has validation errors
      refute changeset.valid?
      assert %{status: ["Can only deactivate active encumbrances"]} = errors_on(changeset)
    end

    test "cannot deactivate pending encumbrance", %{
      registrar_account: registrar_account,
      land_encumbrance: land_encumbrance
    } do
      scope = build(:account_scope, account: registrar_account)

      # Try to deactivate pending encumbrance - should fail
      {:error, changeset} =
        Lands.deactivate_land_encumbrance(scope, land_encumbrance, %{status: :inactive})

      # Verify the changeset has validation errors
      refute changeset.valid?
      assert %{status: ["Cannot deactivate pending encumbrances"]} = errors_on(changeset)
    end
  end
end
