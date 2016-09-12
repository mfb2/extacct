defmodule Extacct.EnvironmentHelper do
  def  env_var(var),  do: Keyword.get(env, var)
  defp env,           do: Application.get_env(:extacct, :intacct_api)
end
