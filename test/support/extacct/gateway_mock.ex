defmodule Extacct.GatewayMock do

  def send_request(xml), do: {:ok, response(xml)}

  defp response(xml), do: %HTTPoison.Response{headers: headers, body: body(xml), status_code: status_code}

  defp headers, do:
    [
      {"Date", "Fri, 09 Sep 2016 09:09:09 GMT"},
      {"Content-Type", "application/json"},
      {"Transfer-Encoding", "chunked"},
      {"Connection", "keep-alive"},
      {"Set-Cookie", "__cfduid=random_id; expires=Sat, 09-Sep-17 09:09:09 GMT; path=/; domain=.intacct.com; HttpOnly"},
      {"Cache-Control", "private"},
      {"X-Frame-Options", "SAMEORIGIN"},
      {"X-Content-Type-Options", "nosniff"},
      {"X-XSS-Protection", "1; mode=block"},
      {"Strict-Transport-Security", "max-age=86400"},
      {"Content-Security-Policy-Report-Only", "default-src 'self'; report-uri csp_listener.phtml; script-src 'self' 'unsafe-inline' 'unsafe-eval' ; style-src 'self' 'unsafe-inline' ; img-src 'self' data: ; frame-src 'self' https://www.youtube.com ;"},
      {"Set-Cookie", "pagePostTime=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT; path=/; secure"},
      {"Server", "cloudflare-nginx"},
      {"CF-RAY", "random_number-SEA"},
    ]

  defp body(xml) do
    cond do
      xml =~ "readReport" -> read_report_json
      xml =~ "readMore"   -> read_more_json
    end
  end

  defp read_report_json, do:
    ~s({
         "REPORTID":"random_string",
         "STATUS":"PENDING"
       }
    )

  defp read_more_json, do:
    ~s({
         "0":{
           "RECORD0COLUMN0":"RECORD0VALUE0",
           "RECORD0COLUMN1":"RECORD0VALUE1"
         },
         "1":{
           "RECORD1COLUMN0":"RECORD1VALUE0",
           "RECORD1COLUMN1":"RECORD1VALUE1"
         },
         "STATUS":"DONE"
       }
    )

  defp status_code, do: 200
end
