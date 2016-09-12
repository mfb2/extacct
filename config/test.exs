use Mix.Config

config :extacct, :intacct_api,
  gateway: Extacct.GatewayMock,
  endpoint: "localhost",
  sender_id: "test_sender",
  sender_password: "test_sender_password",
  user_id: "test_user",
  company_id: "test_company",
  user_password: "test_user_password"
