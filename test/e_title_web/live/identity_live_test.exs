defmodule ETitleWeb.IdentityLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ETitle.Factory

  @create_attrs %{
    first_name: "some first_name",
    other_names: "some other_names",
    surname: "some surname",
    birth_date: "2025-03-16",
    id_doc: "some id_doc",
    nationality: "some nationality1",
    kra_pin: "some kra_pin",
    passport_photo: "some passport_photo"
  }
  @update_attrs %{
    first_name: "some updated first_name",
    other_names: "some updated other_names",
    surname: "some updated surname",
    birth_date: "2025-03-17",
    id_doc: "some updated id_doc",
    nationality: "some updated nationality",
    kra_pin: "some updated kra_pin",
    passport_photo: "some updated passport_photo"
  }

  setup do
    identity = Factory.insert!(:identity)
    %{identity: identity}
  end

  describe "Index" do
    test "lists all identities", %{conn: conn, identity: identity} do
      {:ok, _index_live, html} = live(conn, ~p"/identities")

      assert html =~ "Listing Identities"
      assert html =~ identity.first_name
    end

    test "saves new identity", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/identities")

      assert index_live |> element("a", "New Identity") |> render_click() =~
               "New Identity"

      assert_patch(index_live, ~p"/identities/new")

      assert index_live
             |> form("#identity-form", identity: %{})
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#identity-form", identity: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/identities")

      html = render(index_live)
      assert html =~ "Identity created successfully"
      assert html =~ "some first_name"
    end

    test "updates identity in listing", %{conn: conn, identity: identity} do
      {:ok, index_live, _html} = live(conn, ~p"/identities")

      assert index_live |> element("#identities-#{identity.id} a", "Edit") |> render_click() =~
               "Edit Identity"

      assert_patch(index_live, ~p"/identities/#{identity}/edit")

      assert index_live
             |> form("#identity-form", identity: %{first_name: nil})
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#identity-form", identity: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/identities")

      html = render(index_live)
      assert html =~ "Identity updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes identity in listing", %{conn: conn, identity: identity} do
      {:ok, index_live, _html} = live(conn, ~p"/identities")

      assert index_live |> element("#identities-#{identity.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#identities-#{identity.id}")
    end
  end

  describe "Show" do
    test "displays identity", %{conn: conn, identity: identity} do
      {:ok, _show_live, html} = live(conn, ~p"/identities/#{identity}")

      assert html =~ "Show Identity"
      assert html =~ identity.first_name
    end

    test "updates identity within modal", %{conn: conn, identity: identity} do
      {:ok, show_live, _html} = live(conn, ~p"/identities/#{identity}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Identity"

      assert_patch(show_live, ~p"/identities/#{identity}/show/edit")

      assert show_live
             |> form("#identity-form", identity: %{first_name: nil})
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#identity-form", identity: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/identities/#{identity}")

      html = render(show_live)
      assert html =~ "Identity updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
