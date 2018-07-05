defmodule Lye.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Lye.Worker.start_link(arg)
      # {Lye.Worker, arg},
      {Lye, Lye.Environment.phoenix()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lye.Supervisor]
    Supervisor.start_link(children, opts)
  end
end