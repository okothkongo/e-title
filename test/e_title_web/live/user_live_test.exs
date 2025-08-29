defmodule ETitleWeb.UserLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.Factory

  @create_attrs %{
    first_name: "some first_name",
    middle_name: "some middle_name",
    surname: "some surname",
    identity_document: "some identity_document",
    accounts: %{0 => %{email: "test@email.com", phone_number: "1111111"}}
  }

  describe "save user" do
    test "creates account and user but does not log in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/new")

      form = form(lv, "#user-form", user: @create_attrs)

      {:ok, _lv, html} =
        form
        |> render_submit()
        |> follow_redirect(conn, ~p"/accounts/log-in")

      assert html =~
               ~r/An email was sent to .*, please access it to confirm your account/
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/new")

      insert(:account, email: "test@email.com")

      form = form(lv, "#user-form", user: @create_attrs)

      result = render_submit(form)

      assert result =~ "has already been taken"
    end

    test "renders errors for duplicated phone number", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/new")

      insert(:account, phone_number: "1111111")

      form = form(lv, "#user-form", user: @create_attrs)

      result = render_submit(form)

      assert result =~ "has already been taken"
    end
  end

  describe "Index" do
    test "user is not logged in", %{conn: conn} do
      live(conn, ~p"/users")

      assert {:error,
              {:redirect,
               %{
                 to: "/accounts/log-in",
                 flash: %{"error" => "You must log in to access this page."}
               }}} = live(conn, ~p"/users")
    end

    test "lists all users if user is staff", %{conn: conn} do
      account = insert(:account, type: :staff)
      user = insert(:user)
      conn = log_in_account(conn, account)
      {:ok, _index_live, html} = live(conn, ~p"/users")

      assert html =~ "Listing Users"
      assert html =~ user.first_name
    end

    test "does not lists users if not staff", %{conn: conn} do
      account = insert(:account, type: :citizen)

      conn = log_in_account(conn, account)

      assert {:error, {:redirect, %{to: "/", flash: %{"error" => "Unauthorized access."}}}} =
               live(conn, ~p"/users")
    end
  end

  # describe "Show" do
  #   test "displays user", %{conn: conn, user: user} do
  #     {:ok, _show_live, html} = live(conn, ~p"/users/#{user}")

  #     assert html =~ "Show User"
  #     assert html =~ user.first_name
  #   end

  #   test "updates user and returns to show", %{conn: conn, user: user} do
  #     {:ok, show_live, _html} = live(conn, ~p"/users/#{user}")

  #     assert {:ok, form_live, _} =
  #              show_live
  #              |> element("a", "Edit")
  #              |> render_click()
  #              |> follow_redirect(conn, ~p"/users/#{user}/edit?return_to=show")

  #     assert render(form_live) =~ "Edit User"

  #     assert form_live
  #            |> form("#user-form", user: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert {:ok, show_live, _html} =
  #              form_live
  #              |> form("#user-form", user: @update_attrs)
  #              |> render_submit()
  #              |> follow_redirect(conn, ~p"/users/#{user}")

  #     html = render(show_live)
  #     assert html =~ "User updated successfully"
  #     assert html =~ "some updated first_name"
  #   end
  # end
end
