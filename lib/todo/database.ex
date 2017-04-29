defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder,
      name: :database_server
    )
  end

  def store(key, data) do
    worker = Todo.Database.get_worker(key)
    Todo.DatabaseWorker.store(worker, key, data)
  end

  def get(key) do
    worker = Todo.Database.get_worker(key)
    Todo.DatabaseWorker.get(worker, key)
  end

  def get_worker(key) do
    GenServer.call(:database_server, {:get_worker, key})
  end

  def init(db_folder) do
    File.mkdir_p(db_folder)
    workers = start_workers(db_folder)
    {:ok, workers}
  end

  defp start_workers(db_folder) do
    Enum.reduce(0..2, %{},
      &(start_worker(&1, &2, db_folder)))
  end

  defp start_worker(index, acc, db_folder) do
    {:ok, worker} = Todo.DatabaseWorker.start(db_folder)
    Map.put(acc, index, worker)
  end

  def handle_call({:get_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    worker_pid = Map.get(workers, worker_key)
    {:reply, worker_pid, workers}
  end
end
