defmodule CAIData.API do
  @moduledoc """
  API for interacting with a CAIData node running on the same network.
  The default short name for the node is "data". The calling process will
  crash if there is no connection to the node running CAIData.
  """

  @type info_type ::
          :vehicle
          | :experience
          | :event
          | :weapon
          | :zone
          | :world
          | :faction
          | :ivi_weapon_ids

  @doc """
  Retrieve static info from CAIData.
  """
  @spec get_info(info_type) :: map()
  def get_info(:ivi_weapon_ids), do: get_data(CAIData, :ivi_weapon_ids, [])

  def get_info(type) do
    # Yes, the dev can shoot themself in the foot if they don't follow the typespec ¯\_(ツ)_/¯
    get_data(CAIData, String.to_atom("#{type}_info"), [])
  end

  @doc """
  Retrieves a character's current session, or the most recent session if they
  are offline.
  """
  @spec get_session(String.t()) :: {:ok, map()} | :none
  def get_session(character_id) do
    with :none <- get_data(CAIData, :get_active_session, [character_id]),
         nil <- get_data(CAIData, :get_session, [character_id]) do
      :none
    else
      {:ok, session} -> {:ok, Map.drop(session, [:__struct__, :__meta__])}
			session when is_map(session) -> {:ok, Map.drop(session, [:__struct__, :__meta__])}
    end
  end

  @doc """
  Retrieves a character's most recent session by name.
  """
  @spec get_session_by_name(String.t()) :: {:ok, map()} | :none
  def get_session_by_name(character_name) do
    with :none <- get_data(CAIData, :get_active_session_by_name, [character_name]),
         nil <- get_data(CAIData, :get_session_by_name, [character_name]) do
      :none
    else
      {:ok, session} -> {:ok, Map.drop(session, [:__struct__, :__meta__])}
			session when is_map(session) -> {:ok, Map.drop(session, [:__struct__, :__meta__])}
    end
  end

  @doc """
  Retrieves all of a character's stored sessions.
  """
  @spec get_all_sessions(String.t()) :: {:ok, map()} | :none
  def get_all_sessions(character_id) do
    case get_data(CAIData, :get_all_sessions, [character_id]) do
      nil -> :none
      sessions -> {:ok, Enum.map(sessions, &Map.drop(&1, [:__struct__, :__meta__]))}
    end
  end

  defp get_data(module, fn_name, args) do
		datanode = Application.get_env(:caidata_api, :data_hostname, "data@" <> (:inet.gethostname |> elem(1) |> List.to_string()) |> String.to_atom())

    Task.Supervisor.async(
      {CAIData.DataTasks, datanode},
      module,
      fn_name,
      args
    )
    |> Task.await()
  end
end
