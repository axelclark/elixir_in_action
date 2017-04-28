defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(Todo.Server, nil, name: :todo_server)
  end

  def add_entry(new_entry) do
    GenServer.cast(:todo_server, {:add_entry, new_entry})
  end

  def entries(date) do
    GenServer.call(:todo_server, {:entries, date})
  end

  def init(_) do
    {:ok, Todo.List.new}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, new_entry)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end
end
