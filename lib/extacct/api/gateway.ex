defmodule Extacct.API.Gateway do

  alias Extacct.API.Gateway.Endpoint
  alias Extacct.API.Gateway.HTTPResponseHandler
  alias Extacct.API.GatewayResponse
  alias Extacct.API.GatewayResponse.Headers

  # Note: _request_type is provided here for ease of testing.
  #       The production code currently does not require the
  #       use of _request_type.
  def process(xml, _request_type) do
    Endpoint.post(xml)
    |> HTTPResponseHandler.handle
    |> generate_response
  end

  defp generate_response({:endpoint_response, response}) do
    %GatewayResponse{headers: headers(response), content: content(response)}
  end

  defp headers(response) do
    Keyword.get(response, :response_metadata)
    |> Enum.into(%Headers{})
  end

  defp content(response) do
    Keyword.get(response, :response_content)
  end
end
