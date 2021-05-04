defmodule CAIData.API do
  @moduledoc """
  API for interacting with a CAIData node running on the same network.
  The default short name for the node is "data". The calling process will
  crash if there is no connection to the node running CAIData.
  """

	alias CAIData.CharacterSession

  @type info_type ::
          :vehicle
          | :experience
          | :event
          | :weapon
          | :zone
          | :world
          | :faction

  @spec get_info(info_type) :: map()
  def get_info(type) do
    get_data(CAIData, String.to_existing_atom("#{type}_info"), [])
  end

	@spec get_session(String.t()) :: {:ok, map()} | :none
  def get_session(character_id) do
    with nil <- get_data(CAIData, :get_session, [character_id]),
         nil <- get_data(CAIData, :get_active_session, [character_id]) do
      :none
    else
      session -> {:ok, struct(CharacterSession, Map.delete(session, :__struct__))}
    end
  end

	@spec get_session_by_name(String.t()) :: {:ok, map()} | :none
  def get_session_by_name(character_name) do
    case get_data(CAIData, :get_session_by_name, [character_name]) do
      nil -> :none
      session -> {:ok, struct(CharacterSession, Map.delete(session, :__struct__))}
    end
  end

	@spec get_all_sessions(String.t()) :: {:ok, map()} | :none
  def get_all_sessions(character_id) do
		case get_data(CAIData, :get_all_sessions, [character_id]) do
      nil -> :none
      sessions -> {:ok, Enum.map(sessions, &struct(CharacterSession, Map.delete(&1, :__struct__)))}
    end
  end

  defp get_data(module, fn_name, args) do
    Task.Supervisor.async(
      {CAIData.DataTasks, Application.get_env(:caidata_api, :data_hostname)},
      module,
      fn_name,
      args
    )
    |> Task.await()
  end
end
