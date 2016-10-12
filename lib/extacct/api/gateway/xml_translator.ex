defmodule Extacct.API.Gateway.XmlTranslator do
  require Logger

  def decode_xml(body) do
    Logger.debug "XML to be processed: #{body}"
    results = body
    |> transform_xml
    |> extract_response
    |> extract_operation
    |> extract_result

    headers = results
    |> extract_metadata

    content = results
    |> extract_data
    |> normalize_response

    {:endpoint_response, [headers, content]}
  end

  def transform_xml(body) do
    :erlsom.simple_form(body)
    |> elem(1)
  end

  def extract_response({'response', _, body}),                               do: body
  def extract_operation([{'control', _, _}, {'operation', _, operation}]),   do: operation
  def extract_operation([{'control', _, _}, {'errormessage', _, errors}]),   do: [{'errormessage', nil, errors}]
  def extract_result([{'authentication', _, _}, {'result', _, result}]),     do: result
  def extract_result([{'errormessage', _, errors}]),                         do: {:error, errors}
  def extract_data(
    [
      {'status', _, _},
      {'function', _, ['get_list']},
      {'controlid', _, _},
      {'listtype', _, _},
      {'data', _, data}
    ]), do: data
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
  def extract_data({:error, errors}), do: errors

  def extract_metadata(
    [
      {'status', _, _},
      {'function', _, _},
      {'controlid', _, control_id},
      {'data', _, _}
    ]), do:
    {
      :response_metadata,
      [
          control_id: control_id,
              status: :success,
               total: :not_applicable,
         last_record: :not_applicable,
        first_record: :not_applicable
      ]
    }
  def extract_metadata(
    [
      {'status', _, _},
      {'function', _, _},
      {'controlid', _, control_id},
      {'errormessage', _, _}
    ]), do:
    {
      :response_metadata,
      [
          control_id: control_id,
              status: :failure,
               total: :not_applicable,
         last_record: :not_applicable,
        first_record: :not_applicable
      ]
    }
  def extract_metadata(
    [
      {'status', _, _},
      {'function', _, ['get_list']},
      {'controlid', _, control_id},
      {'listtype',
       [
         {'total', total},
         {'end', last_record},
         {'start', first_record}
       ], _},
      {'data', _, _}
    ]), do:
    {
      :response_metadata,
      [
          control_id: control_id,
              status: :success,
               total: generate_number(total),
         last_record: generate_number(last_record),
        first_record: generate_number(first_record)
      ]
    }
  def extract_metadata({:error, _errors}), do:
    {
      :response_metadata,
      [
          control_id: :not_applicable,
              status: :failure,
               total: :not_applicable,
         last_record: :not_applicable,
        first_record: :not_applicable
      ]
    }

  def generate_number(entry), do:
    entry |> to_string |> Integer.parse |> elem(0)

  def normalize_response(data_blob) do
    content = data_blob
    |> Enum.map(&generate_tuple/1)

    {:response_content, content}
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
