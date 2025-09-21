defmodule ETitleWeb.LandLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.LandsFixtures

  @create_attrs %{
    size: "120.5",
    title_number: "some title_number",
    gps_cordinates: "some gps_cordinates"
  }
  @update_attrs %{
    size: "456.7",
    title_number: "some updated title_number",
    gps_cordinates: "some updated gps_cordinates"
  }
  @invalid_attrs %{size: nil, title_number: nil, gps_cordinates: nil}

  setup :register_and_log_in_account

  defp create_land(%{scope: scope}) do
    land = land_fixture(scope)

    %{land: land}
  end

  describe "Index" do
    setup [:create_land]

    test "lists all lands", %{conn: conn, land: land} do
      {:ok, _index_live, html} = live(conn, ~p"/lands")

      assert html =~ "Listing Lands"
      assert html =~ land.title_number
    end

    test "saves new land", %{conn: conn} do
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

      assert {:ok, index_live, _html} =
               form_live
               |> form("#land-form", land: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/lands")

      html = render(index_live)
      assert html =~ "Land created successfully"
      assert html =~ "some title_number"
    end

    test "updates land in listing", %{conn: conn, land: land} do
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

      assert {:ok, index_live, _html} =
               form_live
               |> form("#land-form", land: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/lands")

      html = render(index_live)
      assert html =~ "Land updated successfully"
      assert html =~ "some updated title_number"
    end

    test "deletes land in listing", %{conn: conn, land: land} do
      {:ok, index_live, _html} = live(conn, ~p"/lands")

      assert index_live |> element("#lands-#{land.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lands-#{land.id}")
    end
  end

  describe "Show" do
    setup [:create_land]

    test "displays land", %{conn: conn, land: land} do
      {:ok, _show_live, html} = live(conn, ~p"/lands/#{land}")

      assert html =~ "Show Land"
      assert html =~ land.title_number
    end

    test "updates land and returns to show", %{conn: conn, land: land} do
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

      assert {:ok, show_live, _html} =
               form_live
               |> form("#land-form", land: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/lands/#{land}")

      html = render(show_live)
      assert html =~ "Land updated successfully"
      assert html =~ "some updated title_number"
    end
  end
end
