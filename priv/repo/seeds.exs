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
alias ETitle.Accounts.User
utc_datetime = DateTime.utc_now()
timestamp = DateTime.truncate(utc_datetime, :second)
# Create a large number of users with random data
1..1_0000
|> Enum.each(fn _ ->
  %User{
    first_name: Faker.Person.first_name(),
    middle_name: Faker.Person.last_name(),
    surname: Faker.Person.last_name(),
    national_id: "#{Enum.random(100_000_000..999_999_999)}",
    email: Faker.Internet.email(),
    phone_number: "254#{Enum.random(100_000_000..999_999_999)}"
  }
  |> Repo.insert!()
end)
