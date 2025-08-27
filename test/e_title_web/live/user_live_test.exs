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

  # @update_attrs %{
  #   first_name: "some updated first_name",
  #   middle_name: "some updated middle_name",
  #   surname: "some updated surname",
  #   identity_document: "some updated identity_document"
  # }
  # @invalid_attrs %{first_name: nil, middle_name: nil, surname: nil, identity_document: nil}

  # setup context do
  #   %{account: account, conn: conn} = register_and_log_in_account(context)
  #   %{account: account, conn: conn, user: account.user}
  # end

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

  # describe "Index" do
  #   test "lists all users", %{conn: conn, user: user} do
  #     {:ok, _index_live, html} = live(conn, ~p"/users")

  #     assert html =~ "Listing Users"
  #     assert html =~ user.first_name
  #   end

  #   test "saves new user", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, ~p"/users")

  #     assert {:ok, form_live, _} =
  #              index_live
  #              |> element("a", "New User")
  #              |> render_click()
  #              |> follow_redirect(conn, ~p"/users/new")

  #     assert render(form_live) =~ "New User"

  #     assert form_live
  #            |> form("#user-form", user: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert {:ok, index_live, _html} =
  #              form_live
  #              |> form("#user-form", user: @create_attrs)
  #              |> render_submit()
  #              |> follow_redirect(conn, ~p"/users")

  #     html = render(index_live)
  #     assert html =~ "User created successfully"
  #     assert html =~ "some first_name"
  #   end

  #   test "updates user in listing", %{conn: conn, user: user} do
  #     {:ok, index_live, _html} = live(conn, ~p"/users")

  #     assert {:ok, form_live, _html} =
  #              index_live
  #              |> element("#users-#{user.id} a", "Edit")
  #              |> render_click()
  #              |> follow_redirect(conn, ~p"/users/#{user}/edit")

  #     assert render(form_live) =~ "Edit User"

  #     assert form_live
  #            |> form("#user-form", user: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert {:ok, index_live, _html} =
  #              form_live
  #              |> form("#user-form", user: @update_attrs)
  #              |> render_submit()
  #              |> follow_redirect(conn, ~p"/users")

  #     html = render(index_live)
  #     assert html =~ "User updated successfully"
  #     assert html =~ "some updated first_name"
  #   end
  # end

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
