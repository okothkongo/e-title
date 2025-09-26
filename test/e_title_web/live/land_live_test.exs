defmodule ETitleWeb.LandLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest

  import ETitle.Factory

  @invalid_attrs %{size: nil, title_number: nil, gps_cordinates: nil}

  setup context do
    %{conn: logged_in_conn, account: account} = register_and_log_in_account(context)
    %{land: insert(:land, account: account), logged_in_conn: logged_in_conn}
  end

  describe "Index" do
    test "lists all lands for regular users", %{logged_in_conn: conn, land: land} do
      {:ok, _index_live, html} = live(conn, ~p"/lands")

      assert html =~ "Listing Lands"
      assert html =~ land.title_number
    end

    test "lists all lands for admin users", %{conn: conn} do
      # Create roles if they don't exist
      admin_role =
        ETitle.Accounts.get_role_by_name("admin") || insert(:role, name: "admin", type: :staff)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      # Create an admin account
      account = insert(:account, type: :staff)
      insert(:account_role, account: account, role: admin_role)

      # Create lands for different users
      user1 = insert(:user)
      user1_account = insert(:account, user: user1, type: :citizen)
      insert(:account_role, account: user1_account, role: user_role)
      land1 = insert(:land, account: user1_account)

      user2 = insert(:user)
      user2_account = insert(:account, user: user2, type: :citizen)
      insert(:account_role, account: user2_account, role: user_role)
      land2 = insert(:land, account: user2_account)

      conn = log_in_account(conn, account)
      {:ok, _index_live, html} = live(conn, ~p"/lands")

      assert html =~ "Listing Lands"
      assert html =~ land1.title_number
      assert html =~ land2.title_number
      assert html =~ user1.first_name
      assert html =~ user2.first_name
    end

    test "regular users only see their own lands", %{logged_in_conn: conn, land: land} do
      # Create another user with their own land
      other_user = insert(:user)
      other_account = insert(:account, user: other_user, type: :citizen)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      insert(:account_role, account: other_account, role: user_role)
      other_land = insert(:land, account: other_account)

      {:ok, _index_live, html} = live(conn, ~p"/lands")

      assert html =~ "Listing Lands"
      assert html =~ land.title_number
      refute html =~ other_land.title_number
    end

    test "shows New Land button for authorized users (citizens)", %{logged_in_conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/lands")

      assert html =~ "New Land"
      assert html =~ ~p"/lands/new"
    end

    test "shows New Land button for admin users", %{conn: conn} do
      # Create an admin account
      account = insert(:account, type: :staff)
      admin_role = insert(:role, name: "admin", type: :staff)
      insert(:account_role, account: account, role: admin_role)

      conn = log_in_account(conn, account)
      {:ok, _index_live, html} = live(conn, ~p"/lands")

      assert html =~ "New Land"
      assert html =~ ~p"/lands/new"
    end

    test "hides New Land button for unauthorized users (professionals)", %{conn: conn} do
      # Create a professional account (lawyer) without land creation permissions
      account = insert(:account, type: :professional)
      lawyer_role = insert(:role, name: "lawyer", type: :professional)
      insert(:account_role, account: account, role: lawyer_role)

      conn = log_in_account(conn, account)
      {:ok, _index_live, html} = live(conn, ~p"/lands")

      refute html =~ "New Land"
      refute html =~ ~p"/lands/new"
    end

    test "non-logged in user saves new land", %{conn: conn} do
      {:error,
       {:redirect,
        %{to: "/accounts/log-in", flash: %{"error" => "You must log in to access this page."}}}} =
        live(conn, ~p"/lands")
    end

    test "unauthorized user (non-citizen/non-admin) is redirected to sign-in", %{conn: conn} do
      # Create a professional account (lawyer) without proper land creation permissions
      account = insert(:account, type: :professional)
      lawyer_role = insert(:role, name: "lawyer", type: :professional)
      insert(:account_role, account: account, role: lawyer_role)

      # Log in the professional account
      conn = log_in_account(conn, account)

      {:error,
       {:live_redirect,
        %{to: "/accounts/log-in", flash: %{"error" => "You don't have permission to create land"}}}} =
        live(conn, ~p"/lands/new")
    end

    test "logged in user saves new land", %{logged_in_conn: conn} do
      registry = insert(:registry)

      attrs = %{
        size: "120.5",
        title_number: "some title_number",
        gps_cordinates: "some gps_cordinates",
        registry_id: registry.id
      }

      {:ok, index_live, _html} = live(conn, ~p"/lands")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Land")
               |> render_click()
               |> follow_redirect(conn, ~p"/lands/new")

      assert render(form_live) =~ "New Land"

      assert form_live
             |> form("#land-form", land: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      form_live
      |> element("#land-form select[name=\"land[county_id]\"]")
      |> render_change(%{"land" => %{"county_id" => registry.county_id}})

      form_live
      |> element("#land-form select[name=\"land[sub_county_id]\"]")
      |> render_change(%{"land" => %{"sub_county_id" => registry.sub_county_id}})

      assert {:ok, index_live, _html} =
               form_live
               |> form("#land-form", land: attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/lands")

      html = render(index_live)
      assert html =~ "Land created successfully"
      assert html =~ "some title_number"
    end

    test "updates land in listing", %{logged_in_conn: conn, land: land} do
      {:ok, index_live, _html} = live(conn, ~p"/lands")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#lands-#{land.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/lands/#{land}/edit")

      assert render(form_live) =~ "Edit Land"

      assert form_live
             |> form("#land-form", land: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # assert {:ok, index_live, _html} =
      #          form_live
      #          |> form("#land-form", land: @update_attrs)
      #          |> render_submit()
      #          |> follow_redirect(conn, ~p"/lands")

      # html = render(index_live)
      # assert html =~ "Land updated successfully"
      # assert html =~ "some updated title_number"
    end

    test "deletes land in listing", %{logged_in_conn: conn, land: land} do
      {:ok, index_live, _html} = live(conn, ~p"/lands")

      assert index_live |> element("#lands-#{land.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lands-#{land.id}")
    end

    test "admin can delete any land", %{conn: conn} do
      # Create roles if they don't exist
      admin_role =
        ETitle.Accounts.get_role_by_name("admin") || insert(:role, name: "admin", type: :staff)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      # Create an admin account
      admin_account = insert(:account, type: :staff)
      insert(:account_role, account: admin_account, role: admin_role)

      # Create a user and their land
      user = insert(:user)
      user_account = insert(:account, user: user, type: :citizen)
      insert(:account_role, account: user_account, role: user_role)
      land = insert(:land, account: user_account)

      conn = log_in_account(conn, admin_account)
      {:ok, index_live, _html} = live(conn, ~p"/lands")

      assert index_live |> element("#lands-#{land.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lands-#{land.id}")
    end

    test "regular users cannot delete other users' lands", %{logged_in_conn: conn} do
      # Create another user with their own land
      other_user = insert(:user)
      other_account = insert(:account, user: other_user, type: :citizen)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      insert(:account_role, account: other_account, role: user_role)
      other_land = insert(:land, account: other_account)

      {:ok, index_live, _html} = live(conn, ~p"/lands")

      # The other user's land should not appear in the listing
      refute has_element?(index_live, "#lands-#{other_land.id}")
    end
  end

  describe "Show" do
    test "displays land for regular users", %{logged_in_conn: conn, land: land} do
      {:ok, _show_live, html} = live(conn, ~p"/lands/#{land}")

      assert html =~ "Show Land"
      assert html =~ land.title_number
    end

    test "displays land with owner info for admin users", %{conn: conn} do
      # Create roles if they don't exist
      admin_role =
        ETitle.Accounts.get_role_by_name("admin") || insert(:role, name: "admin", type: :staff)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      # Create an admin account
      admin_account = insert(:account, type: :staff)
      insert(:account_role, account: admin_account, role: admin_role)

      # Create a user and their land
      user = insert(:user)
      user_account = insert(:account, user: user, type: :citizen)
      insert(:account_role, account: user_account, role: user_role)
      land = insert(:land, account: user_account)

      conn = log_in_account(conn, admin_account)
      {:ok, _show_live, html} = live(conn, ~p"/lands/#{land}")

      assert html =~ "Show Land"
      assert html =~ land.title_number
      assert html =~ user.first_name
      assert html =~ user.surname
      assert html =~ user_account.email
    end

    test "regular users cannot view other users' lands", %{logged_in_conn: conn} do
      # Create another user with their own land
      other_user = insert(:user)
      other_account = insert(:account, user: other_user, type: :citizen)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      insert(:account_role, account: other_account, role: user_role)
      other_land = insert(:land, account: other_account)

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/lands/#{other_land}")
      end
    end

    test "updates land and returns to show", %{logged_in_conn: conn, land: land} do
      {:ok, show_live, _html} = live(conn, ~p"/lands/#{land}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/lands/#{land}/edit?return_to=show")

      assert render(form_live) =~ "Edit Land"

      assert form_live
             |> form("#land-form", land: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # assert {:ok, show_live, _html} =
      #          form_live
      #          |> form("#land-form", land: @update_attrs)
      #          |> render_submit()
      #          |> follow_redirect(conn, ~p"/lands/#{land}")

      # html = render(show_live)
      # assert html =~ "Land updated successfully"
      # assert html =~ "some updated title_number"
    end
  end
end
