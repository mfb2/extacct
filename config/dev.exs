use Mix.Config

config :extacct, :intacct_api,
  gateway: Extacct.API.Gateway,
  endpoint: "https://api.intacct.com/ia/xml/xmlgw.phtml",
  sender_id: "",
  sender_password: "",
  user_id: "",
  company_id: "",
  user_password: ""

config :logger,
  level: :info
