defmodule Extacct.API.MessageBuilder do
  import Extacct.EnvironmentHelper
  alias Extacct.API.FunctionBuilder

  @control_id "testFunctionId"

  def read(object, keys, fields) do
    FunctionBuilder.read(object, fields, keys, @control_id)
    |> build_xml_request(@control_id)
  end

  def read_by_name(object, keys, fields) do
    FunctionBuilder.read_by_name(object, fields, keys, @control_id)
    |> build_xml_request(@control_id)
  end

  def read_by_query(object, query, fields) do
    FunctionBuilder.read_by_query(object, fields, query, @control_id)
    |> build_xml_request(@control_id)
  end

  def read_report(report_name) do
    FunctionBuilder.read_report(report_name, false, @control_id)
    |> build_xml_request(@control_id)
  end

  def read_more(method, identifier) do
    FunctionBuilder.read_more(method, identifier, @control_id)
    |> build_xml_request(@control_id)
  end

  def build_xml_request(functions, control_id) do
    functions
    |> request(control_id)
    |> XmlBuilder.generate
    |> minify
  end

  def request(functions, control_id), do:
    {
      :request, no_params, [control(control_id)] ++ [operation(functions)]
    }

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

  defp minify(xml),        do: minify(xml, do_minify?)
  defp minify(xml, true),  do: xml |> remove_unnecessary_whitespace
  defp minify(xml, false), do: xml

  defp do_minify? do
    case env_var(:minify_xml) do
      true  -> true
      "yes" -> true
      1     -> true
      _     -> false
    end
  end

  defp remove_unnecessary_whitespace(xml) do
    xml
    |> String.replace("\n", "")
    |> String.replace("\t", "")
  end
end
