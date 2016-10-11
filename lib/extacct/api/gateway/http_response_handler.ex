defmodule Extacct.API.Gateway.HTTPResponseHandler do
  require Logger

  def handle({:error, %HTTPoison.Error{reason: reason}}), do:
    {:error, reason}
  def handle({:ok, %HTTPoison.Response{headers: headers, body: body}}), do:
     get_message_type(headers) |> parse_body(body)

  defp get_message_type(headers) do
    headers_to_map(headers)
    |> case do
      %{"Content-Type" => "application/json"}             -> :json
      %{"Content-Type" => "text/xml; encoding=\"UTF-8\""} -> :xml
    end
  end

  defp headers_to_map(headers), do: Enum.into(headers, %{})

  defp parse_body(:json, body), do: decode_json(body)
  defp parse_body(:xml, body),  do: decode_xml(body)

  defp decode_json(body) do
    elem(Poison.decode(body), 1)
    |> trim
  end

  defp trim(decoded_body) when is_list(decoded_body), do: hd(decoded_body)
  defp trim(decoded_body) when is_map(decoded_body),  do: decoded_body

  def decode_xml(body) do
    Logger.debug "XML to be processed: #{body}"
    :erlsom.simple_form(body)
    |> elem(1)
    |> extract_response
    |> extract_operation
    |> extract_result
    |> extract_data
    |> normalize_response
  end

  def extract_response({'response', _, body}),                               do: body
  def extract_operation([{'control', _, _}, {'operation', _, operation}]),   do: operation
  def extract_result([{'authentication', _, _}, {'result', _, result}]),     do: result
  def extract_data(
    [
      {'status', _, _},
      {'function', _, ['get_list']},
      {'controlid', _, _},
      {'listtype',
       [
         {'total', total},
         {'end', last_record},
         {'start', first_record}
       ], _},
      {'data', _, data}
    ]) do
    [
      {:record_metadata, [],
        [
          {:total,        [], generate_number(total)},
          {:last_record,  [], generate_number(last_record)},
          {:first_record, [], generate_number(first_record)}
        ]
      },
      {:records, [], data}
    ]
  end
  def extract_data(
    [
      {'status', _, _},
      {'function', _, _},
      {'controlid', _, _},
      {'data', _, data}
    ]), do: data
  def extract_data(
    [
      {'status', _, _},
      {'function', _, _},
      {'controlid', _, _},
      {'errormessage', _, error}
    ]), do: error

  def generate_number(entry), do:
    entry |> to_string |> Integer.parse |> elem(0)

  def normalize_response(data_blob) do
    data_blob
    |> Enum.map(&generate_tuple/1)
  end

  def generate_tuple({key, _attr, value}) do
    {
      generate_key(key),
      generate_value(value)
    }
  end

  def generate_key(key) do
    key
    |> to_string
    |> String.downcase
    |> String.to_atom
  end

  def generate_value(value) when is_integer(value),   do: value
  def generate_value(value) when is_bitstring(value), do: to_string(value)
  def generate_value(value) do
    value = Enum.map(value, &handle_value(&1))
    case length(value) do
      1 -> hd(value)
      0 -> nil
      _ -> value
    end
  end

  def handle_value(entry) do
    case is_tuple(entry) do
      true  -> generate_tuple(entry)
      false -> to_string(entry)
    end
  end
end
