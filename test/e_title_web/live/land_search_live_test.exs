defmodule ETitleWeb.LandSearchLiveTest do
  use ETitleWeb.ConnCase

  import Phoenix.LiveViewTest
  import ETitle.Factory

  setup context do
    %{conn: logged_in_conn, account: account} = register_and_log_in_account(context)
    %{logged_in_conn: logged_in_conn, account: account}
  end

  describe "Land Search LiveView" do
    test "redirects unauthenticated users to login", %{conn: conn} do
      {:error, {:redirect, %{to: "/accounts/log-in"}}} = live(conn, ~p"/lands/search")
    end

    test "renders search form for authenticated users", %{logged_in_conn: conn} do
      {:ok, view, html} = live(conn, ~p"/lands/search")

      assert html =~ "Land Title Search"
      assert html =~ "Search for land details using the title deed number"
      assert has_element?(view, "#land-search-form")
      assert has_element?(view, "input[name=\"search[title_number]\"]")
      assert has_element?(view, "button[type=\"submit\"]")
    end

    test "displays search results when land is found", %{logged_in_conn: conn} do
      # Create test data
      user =
        insert(:user,
          first_name: "John",
          middle_name: "M",
          surname: "Doe",
          identity_doc_no: "12345678"
        )

      account = insert(:account, user: user, type: :citizen)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      insert(:account_role, account: account, role: user_role)

      registry = insert(:registry, name: "Nairobi Registry")

      _land =
        insert(:land,
          title_number: "T123456",
          size: Decimal.new("100.5"),
          gps_cordinates: "1.2921,36.8219",
          account: account,
          registry: registry
        )

      {:ok, view, _html} = live(conn, ~p"/lands/search")

      # Submit search form
      view
      |> form("#land-search-form", search: %{title_number: "T123456"})
      |> render_submit()

      # Check that results are displayed
      html = render(view)
      assert html =~ "Land Details Found"
      assert html =~ "John" and html =~ "M" and html =~ "Doe"
      assert html =~ "12345678"
      assert html =~ "T123456"
      assert html =~ "100.5 acres"
      assert html =~ "1.2921,36.8219"
      assert html =~ "Nairobi Registry"
    end

    test "displays no results message when land is not found", %{logged_in_conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/lands/search")

      # Submit search form with non-existent title number
      view
      |> form("#land-search-form", search: %{title_number: "NONEXISTENT"})
      |> render_submit()

      # Check that no results message is displayed
      html = render(view)
      assert html =~ "No Results Found"
      assert html =~ "No land found with the provided title deed number"
    end

    test "displays error message for invalid input", %{logged_in_conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/lands/search")

      # Submit search form with empty title number
      view
      |> form("#land-search-form", search: %{title_number: ""})
      |> render_submit()

      # Check that error message is displayed
      html = render(view)
      assert html =~ "Search Error"
      assert html =~ "Please enter a valid title deed number"
    end

    test "clears previous results when new search is performed", %{logged_in_conn: conn} do
      # Create test data
      user = insert(:user, first_name: "John", surname: "Doe", identity_doc_no: "12345678")
      account = insert(:account, user: user, type: :citizen)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      insert(:account_role, account: account, role: user_role)

      registry = insert(:registry, name: "Nairobi Registry")

      _land =
        insert(:land,
          title_number: "T123456",
          size: Decimal.new("100.5"),
          gps_cordinates: "1.2921,36.8219",
          account: account,
          registry: registry
        )

      {:ok, view, _html} = live(conn, ~p"/lands/search")

      # First search - should find results
      view
      |> form("#land-search-form", search: %{title_number: "T123456"})
      |> render_submit()

      html = render(view)
      assert html =~ "Land Details Found"
      assert html =~ "John" and html =~ "Doe"

      # Second search - should show no results
      view
      |> form("#land-search-form", search: %{title_number: "NONEXISTENT"})
      |> render_submit()

      html = render(view)
      assert html =~ "No Results Found"
      refute html =~ "Land Details Found"
      refute html =~ "John" or refute(html =~ "Doe")
    end

    test "form validation works correctly", %{logged_in_conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/lands/search")

      # Test that form requires title_number
      _html = render(view)
      assert has_element?(view, "input[required]")
    end

    test "search button has correct icon and text", %{logged_in_conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/lands/search")

      assert html =~ "Search"
      assert html =~ "hero-magnifying-glass"
    end

    test "displays owner information correctly with middle name", %{logged_in_conn: conn} do
      # Create user with middle name
      user =
        insert(:user,
          first_name: "John",
          middle_name: "Michael",
          surname: "Doe",
          identity_doc_no: "12345678"
        )

      account = insert(:account, user: user, type: :citizen)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      insert(:account_role, account: account, role: user_role)

      registry = insert(:registry)
      _land = insert(:land, title_number: "T123456", account: account, registry: registry)

      {:ok, view, _html} = live(conn, ~p"/lands/search")

      view
      |> form("#land-search-form", search: %{title_number: "T123456"})
      |> render_submit()

      html = render(view)
      assert html =~ "John" and html =~ "Michael" and html =~ "Doe"
    end

    test "displays owner information correctly without middle name", %{logged_in_conn: conn} do
      # Create user without middle name
      user =
        insert(:user,
          first_name: "Jane",
          middle_name: nil,
          surname: "Smith",
          identity_doc_no: "87654321"
        )

      account = insert(:account, user: user, type: :citizen)

      user_role =
        ETitle.Accounts.get_role_by_name("user") || insert(:role, name: "user", type: :citizen)

      insert(:account_role, account: account, role: user_role)

      registry = insert(:registry)
      _land = insert(:land, title_number: "T789012", account: account, registry: registry)

      {:ok, view, _html} = live(conn, ~p"/lands/search")

      view
      |> form("#land-search-form", search: %{title_number: "T789012"})
      |> render_submit()

      html = render(view)
      assert html =~ "Jane" and html =~ "Smith"
      # Should not have extra spaces
      refute html =~ "Jane  Smith"
    end
  end
end
