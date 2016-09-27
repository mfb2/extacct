defmodule Extacct.API.Gateway.ResponseHandler do
  alias Extacct.API.Gateway.ResponseHandler.HTTPResponseHandler

  def handle(httpoison_response, request_type) do
    HTTPResponseHandler.handle(httpoison_response)
    |> build_response(request_type)
  end

  defp build_response(response, request_type), do: {request_type, response}

end
