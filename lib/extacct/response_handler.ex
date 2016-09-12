defmodule Extacct.ResponseHandler do

  def parse({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
  def parse({:ok, %HTTPoison.Response{headers: headers, body: body}}) do
    parse(Enum.into(headers, %{}), body)
  end
  def parse(%{"Content-Type" => "application/json"}, body) do
    elem(Poison.decode(body), 1)
  end
  def parse(headers, body) do
    {:error, "Unparsable Response"}
  end

end
