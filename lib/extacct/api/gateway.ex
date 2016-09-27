defmodule Extacct.API.Gateway do

  alias Extacct.API.Gateway.Endpoint
  alias Extacct.API.Gateway.ResponseHandler

  def process(xml, request_type) do
    Endpoint.post(xml)
    |> ResponseHandler.handle(request_type)
  end

end
