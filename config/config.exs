use Mix.Config

config :extacct, :intacct_api,
  gateway: Extacct.Gateway,
  endpoint: "https://api.intacct.com/ia/xml/xmlgw.phtml",
  dtd_version: "3.0",
  page_size: 100,
  wait_time: 30,
  connection_timeout: 60000,
  recv_timeout: 60000,
  timeout: 60000

import_config "#{Mix.env}.exs"
