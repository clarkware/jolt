defmodule DatabaseTest do
  use ExUnit.Case
  alias Jolt.Database

  @db_file Path.join(["test", "fixtures", "minimal.json"])
  @test_file Path.join(["test", "fixtures", "test.json"])

  setup do
    File.copy!(@db_file, @test_file)

    on_exit fn ->
      File.rm_rf(@test_file)
    end
  end

  test "reads data from a file" do
    {:ok, db} = Database.read(@test_file)

    assert db.entries == 
      %{"todos" => [], 
        "products" => [%{"id" => 1, "name" => "Unicycle"}] }
  end

  test "read returns an empty database if the file doesn't exist" do
    {:ok, db} = Database.read("missing.json")

    assert db.entries == %{ }
  end

  test "read returns an error if the file doesn't contain valid JSON" do
    invalid_file = Path.join(["test", "fixtures", "invalid.json"])

    assert {:error, {:invalid, "}"}} == Database.read(invalid_file)
  end

  test "writes data to a file" do
    data = %{"posts" => []}

    db = %Jolt.Database{entries: data, file: @test_file}

    assert Database.write(db) == :ok

    {:ok, db} = Database.read(@test_file)

    assert db.entries == %{"posts" => []}
  end

  test "finds a collection of entries" do
    {:ok, db} = Database.read(@test_file)

    entries = Database.find(db, "products")

    assert entries == [ %{"id" => 1, "name" => "Unicycle"} ]
  end

  test "returns an empty list if the collection could not be found" do
    {:ok, db} = Database.read(@test_file)

    entries = Database.find(db, "unknown")

    assert entries == [ ]
  end

  test "finds a specific entry by collection and id" do
    {:ok, db} = Database.read(@test_file)

    entry = Database.find(db, "products", 1)

    assert entry == %{"id" => 1, "name" => "Unicycle"}
  end

  test "returns nil if the entry could not be found" do
    {:ok, db} = Database.read(@test_file)

    entry = Database.find(db, "products", 0)

    assert entry == nil
  end

  test "creates an entry in a collection and assigns an auto-incremented id" do
    {:ok, db} = Database.read(@test_file)

    db = Database.create(db, "todos", %{"name" => "A"})

    entry = Database.find(db, "todos", 1)

    assert entry == %{"id" => 1, "name" => "A"}

    db = Database.create(db, "todos", %{"name" => "B"})

    entry = Database.find(db, "todos", 2)

    assert entry == %{"id" => 2, "name" => "B"}
  end

  test "creates an entry in a new collection" do
    {:ok, db} = Database.read(@test_file)

    db = Database.create(db, "people", %{"name" => "A"})

    entry = Database.find(db, "people", 1)

    assert entry == %{"id" => 1, "name" => "A"}
  end

  test "updates an entry matching an id in a collection" do
    {:ok, db} = Database.read(@test_file)

    updated_product = %{"id" => 1, "name" => "Bicycle" }

    db = Database.update(db, "products", 1, updated_product)

    entry = Database.find(db, "products", 1)

    assert entry == updated_product
  end

  test "deletes an entry matching an id in a collection" do
    {:ok, db} = Database.read(@test_file)

    entry = Database.find(db, "products", 1)

    assert entry != nil

    db = Database.delete(db, "products", 1)

    entry = Database.find(db, "products", 1)

    assert entry == nil
  end
end
