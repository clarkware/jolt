defmodule Jolt.DatabaseServer do
  use GenServer

  alias Jolt.Database

  ## Client API

  @doc """
  Starts the with the given `db_file`.

  ## Example

      iex> DatabaseServer.start_link "db.json"
      {:ok, #PID<0.269.0>}
  """
  def start_link(db_file) do
    GenServer.start_link(__MODULE__, db_file, name: __MODULE__)
  end

  def entries do
    GenServer.call(__MODULE__, {:entries})
  end

  def collections do    
    GenServer.call(__MODULE__, {:collections})
  end

  def find(collection) do
    GenServer.call(__MODULE__, {:find, collection})
  end

  def find(collection, id) do
    GenServer.call(__MODULE__, {:find, collection, id})
  end

  def create(collection, entry) do
    GenServer.call(__MODULE__, {:create, collection, entry})
  end

  def update(collection, id, entry) do
    GenServer.call(__MODULE__, {:update, collection, id, entry})
  end

  def delete(collection, id) do
    GenServer.call(__MODULE__, {:delete, collection, id})
  end

  ## Server Callbacks

  # init(arguments) -> {:ok, state}
  # see http://elixir-lang.org/docs/v1.0/elixir/GenServer.html
  def init(db_file) do
    Database.read(db_file)
  end

  # handle_call(message, from_pid, state) -> {:reply, response, new_state}
  # see http://elixir-lang.org/docs/v1.0/elixir/GenServer.html

  def handle_call({:entries}, _from, db) do 
    { :reply, Database.entries(db), db }
  end

  def handle_call({:collections}, _from, db) do 
    { :reply, Database.collections(db), db }
  end

  def handle_call({:find, collection}, _from, db) do 
    { :reply, Database.find(db, collection), db }
  end

  def handle_call({:find, collection, id}, _from, db) do 
    { :reply, Database.find(db, collection, id), db }
  end

  def handle_call({:create, collection, entry}, _from, db) do 
    new_db = Database.create(db, collection, entry)
    Database.write(new_db)
    { :reply, new_db, new_db }
  end

  def handle_call({:update, collection, id, entry}, _from, db) do 
    new_db = Database.update(db, collection, id, entry)
    Database.write(new_db)
    { :reply, new_db, new_db }
  end

  def handle_call({:delete, collection, id}, _from, db) do 
    new_db = Database.delete(db, collection, id)
    Database.write(new_db)
    { :reply, new_db, new_db }
  end
end

