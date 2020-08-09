defmodule Lutis.Repo do
  use Ecto.Repo,
    otp_app: :lutis,
    adapter: Ecto.Adapters.Postgres
end
