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

for role_name <-
      ~w[user lawyer land_registrar surveyor land_registry_clerk land_board_chair land_board_clerk admin] do
  unless ETitle.Repo.get_by(ETitle.Accounts.Role, name: role_name) do
    ETitle.Repo.insert!(%ETitle.Accounts.Role{name: role_name})
  end
end

users =
  for _ <- 1..80 do
    ETitle.Repo.insert!(%ETitle.Accounts.User{
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
    ETitle.Repo.insert!(%ETitle.Accounts.Account{
      user_id: user.id,
      email: Faker.Internet.email(),
      type: :citizen,
      phone_number: "#{Enum.random(254_000_000_000..254_999_999_999)}"
    })
  end

professional_accounts =
  for user <- professional_users do
    ETitle.Repo.insert!(%ETitle.Accounts.Account{
      user_id: user.id,
      email: Faker.Internet.email(),
      type: :professional,
      phone_number: "#{Enum.random(254_000_000_000..254_999_999_999)}"
    })
  end

staff_accounts =
  for user <- staff_users do
    ETitle.Repo.insert!(%ETitle.Accounts.Account{
      user_id: user.id,
      email: Faker.Internet.email(),
      type: :staff,
      phone_number: "#{Enum.random(254_000_000_000..254_999_999_999)}"
    })
  end

# #citizen
user_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "user")

for citizen <- citizen_accounts do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: citizen.id,
    role_id: user_role.id
  })
end

# # professionals

{lawyers_accounts, surveyors_accounts} = Enum.split(professional_accounts, 2)

lawyer_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "lawyer")
surveyor_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "surveyor")

for lawyer <- lawyers_accounts do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: lawyer.id,
    role_id: lawyer_role.id
  })
end

for surveyor <- surveyors_accounts do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: surveyor.id,
    role_id: surveyor_role.id
  })
end

# staff

land_registrar_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "land_registrar")

land_registry_clerk_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "land_registry_clerk")

land_board_chair_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "land_board_chair")

land_board_clerk_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "land_board_clerk")
admin_role = ETitle.Repo.get_by(ETitle.Accounts.Role, name: "admin")

[land_registrar, land_registry_clerk, land_board_chair, land_board_clerk, admin] =
  Enum.chunk_every(staff_accounts, 4)

for land_registrar <- land_registrar do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: land_registrar.id,
    role_id: land_registrar_role.id
  })
end

for land_registry_clerk <- land_registry_clerk do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: land_registry_clerk.id,
    role_id: land_registry_clerk_role.id
  })
end

for land_board_chair <- land_board_chair do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: land_board_chair.id,
    role_id: land_board_chair_role.id
  })
end

for land_board_clerk <- land_board_clerk do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: land_board_clerk.id,
    role_id: land_board_clerk_role.id
  })
end

for admin <- admin do
  ETitle.Repo.insert!(%ETitle.Accounts.AccountRole{
    account_id: admin.id,
    role_id: admin_role.id
  })
end
