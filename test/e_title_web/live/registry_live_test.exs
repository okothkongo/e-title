defmodule ETitleWeb.RegistryLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.Factory

  @create_attrs %{name: "some name", phone_number: "some phone_number", email: "some email"}

  @invalid_attrs %{name: nil, phone_number: nil, email: nil}

  test "saves new registry", %{conn: conn} do
    county = insert(:county)
    sub_county = insert(:sub_county, county: county)
    admin_account = insert(:account, type: :staff)
    _ = insert(:account_role, account: admin_account, role: insert(:role, name: "admin"))
    conn = log_in_account(conn, admin_account)

    valid_attrs = Map.merge(@create_attrs, %{county_id: county.id, sub_county_id: sub_county.id})
    {:ok, index_live, _html} = live(conn, ~p"/admin/registries/new")

    assert index_live
           |> form("#registry-form", registry: @invalid_attrs)
           |> render_change() =~ "can&#39;t be blank"

    assert {:ok, index_live, _html} =
             index_live
             |> form("#registry-form", registry: valid_attrs)
             |> render_submit()
             |> follow_redirect(conn, ~p"/admin/dashboard")

    html = render(index_live)
    assert html =~ "Registry created successfully"
    assert html =~ "some name"
  end
end
