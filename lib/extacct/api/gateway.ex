defmodule Extacct.API.Gateway do

  alias Extacct.API.Gateway.Endpoint
  alias Extacct.API.Gateway.HTTPResponseHandler

  # Note: _request_type is provided here for ease of testing.
  #       The production code currently does not require the
  #       use of _request_type.
  def process(xml, _request_type) do
    Endpoint.post(xml)
    |> HTTPResponseHandler.handle
  end

end
