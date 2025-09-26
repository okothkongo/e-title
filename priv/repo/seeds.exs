# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ETitle.Repo.insert!(%ETitle.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query, warn: false
alias ETitle.Repo
alias ETitle.Accounts.Schemas.Account
alias ETitle.Accounts.Schemas.AccountRole
alias ETitle.Accounts.Schemas.Role
alias ETitle.Accounts.Schemas.User
alias ETitle.Locations.Schemas.County
alias ETitle.Locations.Schemas.Registry
alias ETitle.Locations.Schemas.SubCounty
alias ETitle.Lands.Schemas.Land
alias ETitle.Accounts.Schemas.Scope

role_types_and_names = [
  {:staff, "admin"},
  {:staff, "land_registrar"},
  {:staff, "land_registry_clerk"},
  {:staff, "land_board_chair"},
  {:staff, "land_board_clerk"},
  {:professional, "lawyer"},
  {:professional, "surveyor"},
  {:citizen, "user"}
]

for {type, role_name} <- role_types_and_names do
  case Repo.get_by(Role, name: role_name, type: type) do
    nil -> Repo.insert!(%Role{name: role_name, type: type, status: :active})
    _existing -> :ok
  end
end

admin_role = ETitle.Accounts.get_role_by_name("admin")

# Check if admin account already exists
case Repo.get_by(Account, email: "etitle@admin.com") do
  nil ->
    admin_attrs = %{
      first_name: "John",
      surname: "Admin",
      identity_doc_no: "22222222",
      accounts: [%{email: "etitle@admin.com", type: :staff, phone_number: "254000000000"}]
    }

    {:ok, %{accounts: [account]}} = ETitle.Accounts.register_account(admin_attrs)

    Repo.insert!(%AccountRole{
      account_id: account.id,
      role_id: admin_role.id
    })

  existing_account ->
    # Check if admin role is already assigned
    case Repo.get_by(AccountRole, account_id: existing_account.id, role_id: admin_role.id) do
      nil ->
        Repo.insert!(%AccountRole{
          account_id: existing_account.id,
          role_id: admin_role.id
        })

      _existing_role ->
        :ok
    end
end

users =
  for _ <- 1..80 do
    Repo.insert!(%User{
      first_name: Faker.Person.first_name(),
      middle_name: Faker.Person.name(),
      surname: Faker.Person.last_name(),
      identity_doc_no: Faker.String.base64(10)
    })
  end

[citizen_users, rest_users] = Enum.chunk_every(users, 40)

[professional_users, staff_users] = Enum.chunk_every(rest_users, 20)

citizen_accounts =
  for user <- citizen_users do
    Repo.insert!(%Account{
      user_id: user.id,
      email: Faker.Internet.email(),
      type: :citizen,
      phone_number: "#{Enum.random(254_000_000_001..254_999_999_999)}"
    })
  end

professional_accounts =
  for user <- professional_users do
    Repo.insert!(%Account{
      user_id: user.id,
      email: Faker.Internet.email(),
      type: :professional,
      phone_number: "#{Enum.random(254_000_000_001..254_999_999_999)}"
    })
  end

staff_accounts =
  for user <- staff_users do
    Repo.insert!(%Account{
      user_id: user.id,
      email: Faker.Internet.email(),
      type: :staff,
      phone_number: "#{Enum.random(254_000_000_001..254_999_999_999)}"
    })
  end

# #citizen
user_role = Repo.get_by(Role, name: "user")

for citizen <- citizen_accounts do
  Repo.insert!(%AccountRole{
    account_id: citizen.id,
    role_id: user_role.id
  })
end

# # professionals

{lawyers_accounts, surveyors_accounts} = Enum.split(professional_accounts, 2)

lawyer_role = Repo.get_by(Role, name: "lawyer")
surveyor_role = Repo.get_by(Role, name: "surveyor")

for lawyer <- lawyers_accounts do
  Repo.insert!(%AccountRole{
    account_id: lawyer.id,
    role_id: lawyer_role.id
  })
end

for surveyor <- surveyors_accounts do
  Repo.insert!(%AccountRole{
    account_id: surveyor.id,
    role_id: surveyor_role.id
  })
end

# staff

land_registrar_role = ETitle.Repo.get_by(Role, name: "land_registrar")

land_registry_clerk_role = ETitle.Repo.get_by(Role, name: "land_registry_clerk")

land_board_chair_role = ETitle.Repo.get_by(Role, name: "land_board_chair")

land_board_clerk_role = ETitle.Repo.get_by(Role, name: "land_board_clerk")
admin_role = ETitle.Repo.get_by(Role, name: "admin")

[land_registrar, land_registry_clerk, land_board_chair, land_board_clerk, admin] =
  Enum.chunk_every(staff_accounts, 4)

for land_registrar <- land_registrar do
  Repo.insert!(%AccountRole{
    account_id: land_registrar.id,
    role_id: land_registrar_role.id
  })
end

for land_registry_clerk <- land_registry_clerk do
  Repo.insert!(%AccountRole{
    account_id: land_registry_clerk.id,
    role_id: land_registry_clerk_role.id
  })
end

for land_board_chair <- land_board_chair do
  Repo.insert!(%AccountRole{
    account_id: land_board_chair.id,
    role_id: land_board_chair_role.id
  })
end

for land_board_clerk <- land_board_clerk do
  Repo.insert!(%AccountRole{
    account_id: land_board_clerk.id,
    role_id: land_board_clerk_role.id
  })
end

for admin <- admin do
  Repo.insert!(%AccountRole{
    account_id: admin.id,
    role_id: admin_role.id
  })
end

# create counties and sub counties
current_dir = File.cwd!()
counties_file_path = Path.join(current_dir, "priv/counties.json")

counties =
  counties_file_path
  |> File.read!()
  |> Jason.decode!()
  |> Enum.reduce([], fn %{"name" => name, "code" => code, "sub_counties" => sub_counties}, acc ->
    normalized_code =
      case Integer.digits(code) do
        [_, _] -> "#{code}"
        _ -> "0#{code}"
      end

    county = %{
      name: name,
      code: normalized_code,
      sub_counties: Enum.map(sub_counties, &%{name: &1})
    }

    [county | acc]
  end)
  |> Enum.reverse()

for county_attrs <- counties do
  case Repo.get_by(County, code: county_attrs.code) do
    nil ->
      county_changeset = County.changeset(%County{}, county_attrs)
      Repo.insert!(county_changeset)

    _existing ->
      :ok
  end
end

# Create registries for each sub-county
for county <- Repo.all(County) do
  sub_counties = Repo.all(from s in SubCounty, where: s.county_id == ^county.id)

  for sub_county <- sub_counties do
    registry_name = "#{sub_county.name} Land Registry"

    case Repo.get_by(Registry,
           name: registry_name,
           county_id: county.id,
           sub_county_id: sub_county.id
         ) do
      nil ->
        registry_attrs = %{
          name: registry_name,
          phone_number: "254#{Enum.random(100_000_000..999_999_999)}",
          email:
            "#{String.downcase(String.replace(sub_county.name, " ", "_"))}_registry@etitle.gov.ke",
          county_id: county.id,
          sub_county_id: sub_county.id
        }

        registry_changeset = Registry.changeset(%Registry{}, registry_attrs)
        Repo.insert!(registry_changeset)

      _existing ->
        :ok
    end
  end
end

# Get some citizen accounts and registries for land creation
citizen_accounts = Repo.all(from a in Account, where: a.type == :citizen, limit: 20)
all_registries = Repo.all(Registry)

# Create sample lands
lands_created =
  for i <- 1..50 do
    title_number = "TITLE-#{String.pad_leading(to_string(i), 6, "0")}"

    case Repo.get_by(Land, title_number: title_number) do
      nil ->
        citizen = Enum.random(citizen_accounts)
        registry = Enum.random(all_registries)

        land_attrs = %{
          title_number: title_number,
          size: Decimal.new("#{Enum.random(1..100)}.#{Enum.random(0..99)}"),
          gps_cordinates:
            "#{Enum.random(-1..1)}.#{Enum.random(100_000..999_999)},#{Enum.random(36..37)}.#{Enum.random(100_000..999_999)}",
          registry_id: registry.id,
          account_id: citizen.id,
          created_by_id: citizen.id
        }

        land_changeset = Land.changeset(%Land{}, land_attrs, %Scope{account: citizen})
        Repo.insert!(land_changeset)

      _existing ->
        nil
    end
  end
  |> Enum.reject(&is_nil/1)

IO.puts("Seeded #{length(lands_created)} new lands successfully!")

# Create land encumbrances
IO.puts("Creating land encumbrances...")

# Get all accounts with their roles for easier filtering
all_accounts = citizen_accounts ++ professional_accounts ++ staff_accounts

land_encumbrances_created =
  lands_created
  |> Enum.take(5)
  |> Enum.map(fn land ->
    # Get a professional account (surveyor or lawyer)
    professional_accounts =
      all_accounts
      |> Enum.filter(fn account ->
        ETitle.Accounts.account_has_role?(account, "surveyor") or
          ETitle.Accounts.account_has_role?(account, "lawyer")
      end)

    case professional_accounts do
      [] ->
        nil

      [professional | _] ->
        # Get a different citizen account for created_for
        citizen_accounts_for_encumbrance =
          all_accounts
          |> Enum.filter(fn account ->
            ETitle.Accounts.account_has_role?(account, "user")
          end)
          |> Enum.reject(fn account -> account.id == land.account_id end)

        case citizen_accounts_for_encumbrance do
          [] ->
            nil

          [citizen_for | _] ->
            # Get the user's identity document number
            user = Repo.get!(User, citizen_for.user_id)

            land_encumbrance_attrs = %{
              land_id: land.id,
              reason: Enum.random(["loan", "bond"]),
              created_for_id: citizen_for.id,
              identity_doc_no: user.identity_doc_no
            }

            land_encumbrance_changeset =
              ETitle.Lands.Schemas.LandEncumbrance.changeset(
                %ETitle.Lands.Schemas.LandEncumbrance{},
                land_encumbrance_attrs,
                %Scope{account: professional}
              )

            case Repo.insert(land_encumbrance_changeset) do
              {:ok, land_encumbrance} -> land_encumbrance
              {:error, _changeset} -> nil
            end
        end
    end
  end)
  |> Enum.reject(&is_nil/1)

IO.puts("Seeded #{length(land_encumbrances_created)} new land encumbrances successfully!")
