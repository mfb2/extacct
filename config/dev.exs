use Mix.Config

config :extacct, :intacct_api,
  gateway: Extacct.API.Gateway,
  endpoint: "https://api.intacct.com/ia/xml/xmlgw.phtml",
  user_password: "",
  return_format: "xml",
  minify_xml: false

config :logger,
  level: :debug
