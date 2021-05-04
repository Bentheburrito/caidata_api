import Config

config :caidata_api, data_hostname: Application.get_env(:caidata_api, :datahost, "data") <> "@" <> (:inet.gethostname |> elem(1) |> List.to_string()) |> String.to_atom()
