defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
    IO.puts "Starting Todo.Supervisor"

    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      supervisor(Registry, [:unique, :process_registry]),
      supervisor(Todo.SystemsSupervisor, []),
    ]
    supervise(processes, strategy: :rest_for_one)
  end
end
