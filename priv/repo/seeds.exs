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

alias ETitle.Repo
alias ETitle.Accounts.Schemas.Account
alias ETitle.Accounts.Schemas.AccountRole
alias ETitle.Accounts.Schemas.Role
alias ETitle.Accounts.Schemas.User

for role_name <-
      ~w[user lawyer land_registrar surveyor land_registry_clerk land_board_chair land_board_clerk admin] do
  unless Repo.get_by(Role, name: role_name) do
    Repo.insert!(%Role{name: role_name})
  end
end

admin_role = ETitle.Accounts.get_role_by_name("admin")

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
      phone_number: "#{Enum.random(254_000_000_0001..254_999_999_999)}"
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
  county_changeset = ETitle.Locations.County.changeset(%ETitle.Locations.County{}, county_attrs)
  Repo.insert!(county_changeset)

  # registrar
  # registry_clerk
  # board_chair
  # board_clerk
  # lawyer
  # survery
  # user
end
