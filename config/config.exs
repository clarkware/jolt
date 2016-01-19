use Mix.Config

config :jolt, port: 4000

config :logger, compile_time_purge_level: :info

if Mix.env == :test do
  config :logger, backends: [ ]
end
