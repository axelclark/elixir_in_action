defmodule Todo.Server do
  use GenServer

  def start_link(todo_list_name) do
    IO.puts "Starting to-do server #{todo_list_name}"

    GenServer.start_link(
      Todo.Server,
      todo_list_name,
      name: via_tuple(todo_list_name)
    )
  end

  defp via_tuple(name) do
    {:via, Registry, {:process_registry, {:todo_server, name}}}
  end

  def lookup(name) do
    Registry.lookup(:process_registry, {:todo_server, name})
  end

  def add_entry(name, new_entry) do
    GenServer.cast(via_tuple(name), {:add_entry, new_entry})
  end

  def entries(name, date) do
    GenServer.call(via_tuple(name), {:entries, date})
  end

  def init(todo_list_name) do
    send(self(), {:real_init, todo_list_name})
    {:ok, nil}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  def handle_info({:real_init, name}, _state) do
    todo_list = {name, Todo.Database.get(name) || Todo.List.new}
    {:noreply, todo_list}
  end
end
