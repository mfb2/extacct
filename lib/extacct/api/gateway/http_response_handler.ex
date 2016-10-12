defmodule Extacct.API.Gateway.HTTPResponseHandler do
  require Logger

  alias Extacct.API.Gateway.XmlTranslator

  def handle({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
  def handle({:ok, %HTTPoison.Response{headers: headers, body: body}}) do
     get_message_type(headers)
     |> parse_body(body)
  end

  defp get_message_type(headers) do
    headers_to_map(headers)
    |> case do
      %{"Content-Type" => "application/json"}             -> :json
      %{"Content-Type" => "text/xml; encoding=\"UTF-8\""} -> :xml
    end
  end

  defp headers_to_map(headers), do: Enum.into(headers, %{})

  defp parse_body(:json, body), do: decode_json(body)
  defp parse_body(:xml, body),  do: XmlTranslator.decode_xml(body)

  defp decode_json(body),       do: elem(Poison.decode(body), 1) |> trim

  defp trim(decoded_body) when is_list(decoded_body), do: hd(decoded_body)
  defp trim(decoded_body) when is_map(decoded_body),  do: decoded_body

end
