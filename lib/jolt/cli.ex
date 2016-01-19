defmodule Jolt.CLI do
  
  @moduledoc """
  Parses the command line and starts the server accordingly.
  """

  @doc """
  Starts the server.

  ## Examples

      > mix run -e 'Jolt.CLI.main(["--help"])'
      > mix run -e 'Jolt.CLI.main(["db.json"])'
      > mix run -e 'Jolt.CLI.main(["--port", "8080", "db.json"])'
  """
  def main(args) do
    args 
      |> parse_args 
      |> process
  end

  defp parse_args(args) do
    options = OptionParser.parse(args, switches: [ port:    :int,
                                                   help:    :boolean],
                                       aliases:  [ p:       :port,
                                                   h:       :help])

    case options do
      { [ help: true ], _, _ }   -> :help
      { options, [ source ], _ } -> { source, options }
      _                          -> :help
    end
  end

  defp process(:help) do
    IO.puts """
    Usage: jolt [options] <source>

    Options:
      --port, -p   Set the HTTP port (defaults to 4000)
      --help, -h   Show this help message

    Examples:
      jolt db.json
      jolt --port 8080 db.json

    Source:
    https://github.com/clarkware/jolt
    """
    
    System.halt(0)
  end

  defp process({source, options}) do
    port = port(options)

    IO.puts IO.ANSI.faint() <> "\nLoading #{source}..." <> IO.ANSI.reset()

    {:ok, _} = Jolt.Supervisor.start_link(source)

    {:ok, _} = Plug.Adapters.Cowboy.http(Jolt.Router, [], port: port)

    IO.puts IO.ANSI.bright() <> "\nResources:" <> IO.ANSI.reset()
    Jolt.DatabaseServer.collections
      |> Enum.map(fn(c) -> "http://localhost:#{port}/" <> c end)
      |> Enum.each(&IO.puts(&1))

    IO.puts IO.ANSI.bright() <> "\nReady!" <> IO.ANSI.reset()

    :timer.sleep(:infinity)
  end

  defp port([ port: port ]) do
    case Integer.parse(port) do
      {value, _} -> 
        value
      :error -> 
        IO.puts "Invalid port!"
        System.halt(0)
    end
  end

  defp port([]) do
    Application.get_env(:jolt, :port)
  end
end
