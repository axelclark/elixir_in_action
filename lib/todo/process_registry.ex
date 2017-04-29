defmodule Todo.ProcessRegistry do
  use GenServer

  import Kernel, except: [send: 2]

  def start_link do
    IO.puts "Starting process registry"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
  end

  def whereis_name(key) do
    read_process_registry(key)
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def init(_) do
    :ets.new(:process_registry, [:named_table])
    {:ok, nil}
  end

  def handle_call({:register_name, key, pid}, _, state) do
    case read_process_registry(key) do
      :undefined ->
        Process.monitor(pid)
        register_pid(key, pid)
        {:reply, :yes, state}

      _ ->
        {:reply, :no, state}
    end

  end

  def handle_call({:unregister_name, key}, _, state) do
    :ets.delete(:process_registry, key)
    {:reply, key, state}
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    IO.puts "handling DOWN message for pid: #{inspect pid}"
    :ets.match_delete(:process_registry, {:_, pid})
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp read_process_registry(key) do
    case :ets.lookup(:process_registry, key) do
      [{^key, pid}] -> pid
      _ -> :undefined
    end
  end

  defp register_pid(key, pid) do
    :ets.insert(:process_registry, {key, pid})
  end
end
