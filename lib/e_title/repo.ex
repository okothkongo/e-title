defmodule ETitle.Repo do
  use Ecto.Repo,
    otp_app: :e_title,
    adapter: Ecto.Adapters.Postgres
end
