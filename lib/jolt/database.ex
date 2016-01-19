defmodule Jolt.Database do
  defstruct entries: %{}, file: "db.json"
  
  require Logger

  @doc """
  Returns all the entries in the `database`.

  ## Example

      iex> DatabaseServer.entries
      %{"products" => [...], "todos" => [...]}
  """
  def entries(database) do
    database.entries
  end

  @doc """
  Returns the names of all the collections in the `database`.
  
  ## Example

      iex> Database.collections
      ["products", "todos"]
  """
  def collections(database) do    
    Map.keys(database.entries)
  end

  @doc """
  Returns all the entries of the `collection` in the `database`.
  
  ## Example

      iex> Database.find(database, "todos")
      [%{"id" => 1, "name" => "Shovel snow"}, ...]
  """
  def find(database, collection) do    
    Map.get(database.entries, collection, [])
  end

  @doc """
  Returns the entry matching `id` from the `collection` in the `database`.

  ## Example

      iex> Database.find(database, "todos", 1)
      {"id" => 1, "name" => "Shovel snow"}
  """
  def find(database, collection, id) when is_number(id) do    
    Map.get(database.entries, collection, [])
      |> Enum.find(fn(e) -> e["id"] == id end)
  end

  @doc """
  Adds the `entry` to the `collection` in the `database`.

  Returns the updated database.

  ## Example

      iex> Database.create(database, "todos", %{"name" => "Mow lawn"})
      %{"todos" => [%{"id" => 1, "name" => "Mow lawn"}]}
  """
  def create(database, collection, entry) do  
    new_entry = Map.put(entry, "id", next_id(find(database, collection)))

    entries = Map.get(database.entries, collection, [])
    new_entries = Map.put(database.entries, collection, entries ++ [ new_entry ])
    
    %Jolt.Database{database | entries: new_entries }
  end

  @doc """
  Updates the `entry` matching the `id` in the `collection`
  in the `database`.

  Returns the updated database.

  ## Example

      iex> Database.update(database, "todos", 1, %{"id" => 1, "name" => "Rake leaves"})
      %{"todos" => [%{"id" => 1, "name" => "Rake leaves"}]}
  """
  def update(database, collection, id, entry) when is_number(id) do   
    db = delete(database, collection, id)
    entries = Map.get(db.entries, collection, [])
    new_entries = Map.put(db.entries, collection, entries ++ [ entry ])

    %Jolt.Database{database | entries: new_entries }
  end

  @doc """
  Deletes the entry matching the `id` from the `collection`
  in the `database`.

  Returns the updated database.

  ## Example

      iex> Database.delete(database, "todos", 1)
      %{"todos" => []}
  """
  def delete(database, collection, id) when is_number(id) do    
    entry = find(database, collection, id)
    
    new_entries = 
      Map.get(database.entries, collection, [])
        |> List.delete(entry)

    entries = Map.put(database.entries, collection, new_entries)
    %Jolt.Database{database | entries: entries}
  end

  @doc """
  Reads and parses the given source JSON file.

  Returns `{ok, database}` if the file was successfully read
  and parsed, `{:error, reason}` otherwise.
  """
  def read(source \\ "db.json") do
    case File.read(source) do
      {:ok, contents} ->
        case Poison.Parser.parse(contents) do
          {:ok, body} ->
            {:ok, %Jolt.Database{entries: body, file: source} }
          {:error, reason} ->
            Logger.error("Malformed JSON in '#{source}'!")
            {:error, reason}
        end
      {:error, :enoent} -> 
        {:ok, %Jolt.Database{entries: %{}, file: source}}
      {:error, reason} ->
        Logger.error("Error reading '#{source}': #{:file.format_error(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Writes the database entries in JSON format to the original source file.

  Returns `:ok` if successful, `{:error, reason}` otherwise.
  """
  def write(database) do
    json = Poison.Encoder.encode(database.entries, [pretty: true])

    case File.write(database.file, json) do
      :ok -> 
        :ok
      {:error, reason} -> 
        Logger.error "Error writing to #{database.file}: #{reason}"
        {:error, reason}
    end
  end

  defp next_id([]), do: 1

  defp next_id(entries) do
    last_entry = Enum.max_by(entries, fn(x) -> x["id"] end) 
    last_entry["id"] + 1
  end
end
