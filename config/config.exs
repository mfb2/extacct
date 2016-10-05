use Mix.Config

config :extacct, :intacct_api,
  gateway: Extacct.API.Gateway,
  endpoint: "https://api.intacct.com/ia/xml/xmlgw.phtml",
  dtd_version: "3.0",
  return_format: "xml",
  minify_xml: true,
  page_size: 100,
  wait_time: 30,
  connection_timeout: 60000,
  recv_timeout: 60000,
  timeout: 60000,
  read_more_wait_time: 5000

config :logger,
  level: :warn

import_config "#{Mix.env}.exs"
