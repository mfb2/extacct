defmodule Extacct.MessageBuilder do
  import Extacct.EnvironmentHelper

  def request(functions, control_id) do
    {
      :request, no_params, [control(control_id)] ++ [operation(functions)]
    }
  end

  def control(control_id), do:
    {
      :control, no_params,
      [
        {:senderid,          no_params, sender_id   },
        {:password,          no_params, sender_pw   },
        {:controlid,         no_params, control_id  },
        {:uniqueid,          no_params, false       },
        {:dtdversion,        no_params, dtd_version },
        {:includewhitespace, no_params, false       },
      ]
    }

  def operation(functions) when is_list(functions), do:
    {:operation, no_params, [authentication] ++ [{:content, no_params, functions}]}
  def operation(function), do:
    operation([function])

  def authentication, do:
    {
      :authentication, no_params,
      [
        {
          :login, no_params,
          [
            {:userid,    no_params, user_id       },
            {:companyid, no_params, company_id    },
            {:password,  no_params, user_password },
          ]
        }
      ]
    }

  defp no_params,     do: %{}
  defp sender_id,     do: env_var(:sender_id)
  defp sender_pw,     do: env_var(:sender_password)
  defp dtd_version,   do: env_var(:dtd_version)
  defp user_id,       do: env_var(:user_id)
  defp company_id,    do: env_var(:company_id)
  defp user_password, do: env_var(:user_password)
end
