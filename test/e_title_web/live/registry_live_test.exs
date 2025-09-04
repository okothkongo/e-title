defmodule ETitleWeb.RegistryLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.LocationsFixtures

  @create_attrs %{name: "some name", phone_number: "some phone_number", email: "some email"}
  @update_attrs %{
    name: "some updated name",
    phone_number: "some updated phone_number",
    email: "some updated email"
  }
  @invalid_attrs %{name: nil, phone_number: nil, email: nil}

  setup :register_and_log_in_account

  defp create_registry(%{scope: scope}) do
    registry = registry_fixture(scope)

    %{registry: registry}
  end

  describe "Index" do
    setup [:create_registry]

    test "lists all registries", %{conn: conn, registry: registry} do
      {:ok, _index_live, html} = live(conn, ~p"/registries")

      assert html =~ "Listing Registries"
      assert html =~ registry.name
    end

    test "saves new registry", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/registries")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Registry")
               |> render_click()
               |> follow_redirect(conn, ~p"/registries/new")

      assert render(form_live) =~ "New Registry"

      assert form_live
             |> form("#registry-form", registry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#registry-form", registry: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/registries")

      html = render(index_live)
      assert html =~ "Registry created successfully"
      assert html =~ "some name"
    end

    test "updates registry in listing", %{conn: conn, registry: registry} do
      {:ok, index_live, _html} = live(conn, ~p"/registries")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#registries-#{registry.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/registries/#{registry}/edit")

      assert render(form_live) =~ "Edit Registry"

      assert form_live
             |> form("#registry-form", registry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#registry-form", registry: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/registries")

      html = render(index_live)
      assert html =~ "Registry updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes registry in listing", %{conn: conn, registry: registry} do
      {:ok, index_live, _html} = live(conn, ~p"/registries")

      assert index_live |> element("#registries-#{registry.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#registries-#{registry.id}")
    end
  end

  describe "Show" do
    setup [:create_registry]

    test "displays registry", %{conn: conn, registry: registry} do
      {:ok, _show_live, html} = live(conn, ~p"/registries/#{registry}")

      assert html =~ "Show Registry"
      assert html =~ registry.name
    end

    test "updates registry and returns to show", %{conn: conn, registry: registry} do
      {:ok, show_live, _html} = live(conn, ~p"/registries/#{registry}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/registries/#{registry}/edit?return_to=show")

      assert render(form_live) =~ "Edit Registry"

      assert form_live
             |> form("#registry-form", registry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#registry-form", registry: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/registries/#{registry}")

      html = render(show_live)
      assert html =~ "Registry updated successfully"
      assert html =~ "some updated name"
    end
  end
end
