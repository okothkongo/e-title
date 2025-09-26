defmodule ETitleWeb.Admin.RegistryLive.IndexTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.Factory

  describe "index" do
    test "admin can see all registries", %{conn: conn} do
      admin = insert(:account, type: :staff)
      registry = insert(:registry)
      _ = insert(:account_role, account: admin, role: insert(:role, name: "admin", type: :staff))

      {:ok, _view, html} =
        conn
        |> log_in_account(admin)
        |> live(~p"/admin/registries")

      assert html =~ registry.name
    end

    test "non admin cannot access the page", %{conn: conn} do
      citizen = insert(:account)
      _ = insert(:account_role, account: citizen, role: insert(:role, name: "user"))

      {:error, {:redirect, %{to: "/"}}} =
        conn
        |> log_in_account(citizen)
        |> live(~p"/admin/registries")
    end
  end
end
