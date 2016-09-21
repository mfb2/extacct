defmodule Extacct.API.ResponseHandler do

  def parse({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
  def parse({:ok, %HTTPoison.Response{headers: headers, body: body}} = _response) do
    parse(Enum.into(headers, %{}), body)
  end
  def parse(%{"Content-Type" => "application/json"}, body) do
    decode(body)
  end
  def parse(_headers, body) do
    {:error, "Unparsable Response: #{inspect body}"}
  end

  def decode(body) do
    elem(Poison.decode(body), 1)
    |> trim
  end

  def trim(decoded_body) when is_list(decoded_body), do: hd(decoded_body)
  def trim(decoded_body) when is_map(decoded_body),  do: decoded_body

end
