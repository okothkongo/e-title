defmodule ETitle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ETitleWeb.Telemetry,
      ETitle.Repo,
      {DNSCluster, query: Application.get_env(:e_title, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ETitle.PubSub},
      # Start a worker by calling: ETitle.Worker.start_link(arg)
      # {ETitle.Worker, arg},
      # Start to serve requests, typically the last entry
      ETitleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ETitle.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ETitleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
