defmodule DatabaseServerTest do
  use ExUnit.Case
  
  alias Jolt.DatabaseServer

  @db_file Path.join(["test", "fixtures", "full.json"])
  @test_file Path.join(["test", "fixtures", "test.json"])

  setup do
    File.copy!(@db_file, @test_file)

    {:ok, db_server} = DatabaseServer.start_link(@test_file)

    on_exit fn ->
      File.rm_rf(@test_file)
    end

    {:ok, db_server: db_server}
  end

  test "returns all the entries in the database" do
    entries = DatabaseServer.entries

    assert Map.keys(entries) == ["products", "todos"]
  end

  test "returns the names of all the collections in the database" do
    collections = DatabaseServer.collections

    assert collections == ["products", "todos"]
  end

  test "finds a collection of entries" do
    todos = DatabaseServer.find "todos"

    assert Enum.count(todos) == 3

    products = DatabaseServer.find "products"

    assert Enum.count(products) == 3
  end

  test "finds a specific entry by collection and id" do
    todo = DatabaseServer.find("todos", 1)

    assert todo != nil

    product = DatabaseServer.find("products", 1)

    assert product != nil
  end

  test "creates an entry in a collection and assigns an id" do
    new_todo = %{"title" => "New Todo", "completed" => false }

    DatabaseServer.create("todos", new_todo)

    todo = DatabaseServer.find("todos", 4)

    assert todo == %{"id" => 4, "title" => "New Todo", "completed" => false }
  end

  test "updates an entry matching an id in a collection" do
    new_todo = %{"title" => "New Todo", "completed" => false }

    DatabaseServer.create("todos", new_todo)

    updated_todo = %{"id" => 4, "title" => "Updated Todo", "completed" => true }

    DatabaseServer.update("todos", 4, updated_todo)

    assert DatabaseServer.find("todos", 4) == updated_todo
  end

  test "deletes an entry matching an id in a collection" do
    DatabaseServer.delete("todos", 1)

    assert DatabaseServer.find("todos", 1) == nil
  end

end
