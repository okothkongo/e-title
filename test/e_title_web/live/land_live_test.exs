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
    test "lists all lands", %{logged_in_conn: conn, land: land} do
      {:ok, _index_live, html} = live(conn, ~p"/lands")

      assert html =~ "Listing Lands"
      assert html =~ land.title_number
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
  end

  describe "Show" do
    test "displays land", %{logged_in_conn: conn, land: land} do
      {:ok, _show_live, html} = live(conn, ~p"/lands/#{land}")

      assert html =~ "Show Land"
      assert html =~ land.title_number
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
