defmodule Extacct.API do

  import Extacct.EnvironmentHelper

  alias Extacct.API.MessageBuilder
  alias Extacct.API.ResponseHandler

  def read(object, keys) do
    MessageBuilder.read(object, keys)
    |> process_request
  end
  def read(object, fields, keys) do
    MessageBuilder.read(object, fields, keys)
    |> process_request
  end

  def read_by_name(object, keys) do
    MessageBuilder.read_by_name(object, keys)
    |> process_request
  end
  def read_by_name(object, fields, keys) do
    MessageBuilder.read_by_name(object, fields, keys)
    |> process_request
  end

  def read_by_query(object, query) do
    MessageBuilder.read_by_query(object, query)
    |> process_request
  end
  def read_by_query(object, fields, query) do
    MessageBuilder.read_by_query(object, fields, query)
    |> process_request
  end

  def read_report(report_name) do
    MessageBuilder.read_report(report_name)
    |> process_request
  end

  def read_more(method, identifier) do
    MessageBuilder.read_more(method, identifier)
    |> process_request
  end

  defp process_request(request) do
    request
    |> gateway.send_request
    |> ResponseHandler.parse
  end

  defp gateway, do: env_var(:gateway)

end
