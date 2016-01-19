defmodule Jolt.Router do
  use Plug.Router

  alias Jolt.DatabaseServer

  if Mix.env == :dev do
    use Plug.Debugger
    plug Plug.Logger
  end

  plug :match
  plug :dispatch

  get "/" do
    resources = 
      DatabaseServer.collections
        |> Enum.map(fn(c) -> "http://localhost:#{conn.port}/" <> c end)
        |> Enum.map(fn(url) -> "<p><a href=\"#{url}\">#{url}</a></p>" end)

    conn 
      |> Plug.Conn.send_resp(200, resources)
  end

  get "/db" do
    entries = DatabaseServer.entries

    respond(conn, 200, entries)
  end

  get "/:collection" do
    entries = DatabaseServer.find(collection)

    respond(conn, 200, entries)
  end

  get "/:collection/:id" do
    entry = DatabaseServer.find(collection, parse_id(id))

    if entry do
      respond(conn, 200, entry)
    else
      respond(conn, 404,  "Not found")
    end
  end

  post "/:collection" do
    case parse_body(conn) do
      {:ok, entry} ->
        DatabaseServer.create(collection, entry)
        respond(conn, 204, nil)
      {:error, _} ->
        respond(conn, 404, "Bad data")
    end
  end

  put "/:collection/:id" do
    case parse_body(conn) do
      {:ok, entry} ->
        DatabaseServer.update(collection, parse_id(id), entry)
        respond(conn, 204, nil)
      {:error, _} ->
        respond(conn, 404, "Bad data")
    end
  end

  delete "/:collection/:id" do
    DatabaseServer.delete(collection, parse_id(id))

    respond(conn, 204, nil)
  end

  match _ do
    respond(conn, 404, "Not found!")
  end

  defp respond(conn, status, body) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Poison.Encoder.encode(body, [pretty: true]))
  end

  defp parse_id(id) do
    case Integer.parse(id) do
      {value, _} -> value
      :error -> 0
    end
  end

  defp parse_body(conn) do
    {:ok, data, _conn_details} = Plug.Conn.read_body(conn)
    Poison.Parser.parse(data)
  end

end
