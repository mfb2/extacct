defmodule Extacct.API.GatewayMock do

  def process(xml, :readReport) do
    cond do
      xml =~ "Rando Report"  -> {:report_submitted, report_id: "random_string"}
      xml =~ "Broken Report" -> {:error, "Invalid Report"}
    end
  end

  def process(_xml, :readMore), do:
    %{
      "0" => %{
        "RECORD0COLUMN0" => "RECORD0VALUE0",
        "RECORD0COLUMN1" => "RECORD0VALUE1"
      },
      "1" => %{
        "RECORD1COLUMN0" => "RECORD1VALUE0",
        "RECORD1COLUMN1" => "RECORD1VALUE1"
      },
      "STATUS" => "DONE"
    }

  def process(_xml, :readByName),  do: {:readByName, object_map}
  def process(_xml, :readByQuery), do: {:readByQuery, object_map}
  def process(_xml, :read),        do: {:read, object_map}
  defp object_map, do:
    %{
      "ENTRY_DATE" => "09/16/2016",
      "RECORDNO" => "1000"
    }
end
