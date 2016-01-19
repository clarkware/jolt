defmodule RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias Jolt.Router
  alias Jolt.DatabaseServer

  @router_opts Router.init([])
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

  test "GET /db" do
    conn = conn(:get, "/db")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/todos/)
    assert String.match?(conn.resp_body, ~r/products/)
  end

  test "GET /todos" do
    conn = conn(:get, "/todos")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/Shovel snow/)
    assert String.match?(conn.resp_body, ~r/Rake leaves/)
    assert String.match?(conn.resp_body, ~r/Mow lawn/)
  end

  test "GET /todos/1" do
    conn = conn(:get, "/todos/1")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/Shovel snow/)
  end

  test "GET /todos/:id with invalid id" do
    conn = conn(:get, "/todos/0")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert String.match?(conn.resp_body, ~r/Not found/)
  end

  test "POST /todos" do
    conn = conn(:post, "/todos", "{}")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == "null"
  end

  test "POST /todos with bad data" do
    conn = conn(:post, "/todos", "")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert String.match?(conn.resp_body, ~r/Bad data/)
  end

  test "PUT /todos" do
    conn = conn(:put, "/todos/1", "{}")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == "null"
  end

  test "PUT /todos with bad data" do
    conn = conn(:put, "/todos/1", "")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert String.match?(conn.resp_body, ~r/Bad data/)
  end

  test "DELETE /todos/1" do
    conn = conn(:delete, "/todos/1")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 204
    assert conn.resp_body == "null"
  end

  test "GET /x/y/z" do
    conn = conn(:get, "/x/y/z")
    conn = Router.call(conn, @router_opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert String.match?(conn.resp_body, ~r/Not found/)
  end

end
