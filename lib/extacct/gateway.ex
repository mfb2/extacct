defmodule Extacct.Gateway do
  import Extacct.EnvironmentHelper

  @headers [{"content-type", "x-intacct-xml-request"}]

  def send_request(xml),   do: HTTPoison.post(url, xml, @headers, opts)

  defp url,                do: env_var(:endpoint)
  defp opts,               do: [connect_timeout: connection_timeout, recv_timeout: recv_timeout, timeout: timeout]

  defp connection_timeout, do: env_var(:connection_timeout)
  defp recv_timeout,       do: env_var(:recv_timeout)
  defp timeout,            do: env_var(:timeout)

end
