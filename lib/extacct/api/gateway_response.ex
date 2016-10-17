defmodule Extacct.API.GatewayResponse do
  alias Extacct.API.GatewayReponse.Headers

  defstruct headers: [],
            content: []

  @type t :: %__MODULE__{headers: Headers.t, content: list}
end

defmodule Extacct.API.GatewayResponse.Headers do

  defstruct control_id: nil,
             result_id: :not_applicable,
                status: :unknown,
                 total: :not_applicable,
           last_record: :not_applicable,
          first_record: :not_applicable,
     records_remaining: :not_applicable

  @type t :: %__MODULE__{control_id: String.t,
                          result_id: String.t,
                             status: :unknown | :success | :failure | :pending,
                              total: integer | :not_applicable,
                        last_record: integer | :not_applicable,
                       first_record: integer | :not_applicable,
                  records_remaining: integer | :not_applicable}
  defimpl Collectable, for: Extacct.API.GatewayResponse.Headers do
    def into(original) do
      {
        original, fn
          map, {:cont, {key, value}} -> Map.put(map, key, value)
          map, :done                 -> %Extacct.API.GatewayResponse.Headers{} |> Map.merge(map)
          _,   :halt                 -> :ok
        end
      }
    end
  end
end

