# CAIData.API

An API for interacting with a node running CAIData.

## Installation

```elixir
def deps do
  [
    {:caidata_api, "~> 0.1.0"}
  ]
end
```

caidata_api will call CAIData commands on node `data@computer-name` by default. 
You can configure a shortname with
```elixir
config :caidata_api, :data_shortname, "nodename"
```
or a full node name with
```elixir
config :caidata_api, :data_node, :nodename@host
```

