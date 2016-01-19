defmodule Jolt.Supervisor do
  use Supervisor

  def start_link(db_file) do
    Supervisor.start_link(__MODULE__, { db_file })
  end

  def init({db_file}) do
    children = [
      worker(Jolt.DatabaseServer, [ db_file ])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
