defmodule Extacct.Mixfile do
  use Mix.Project

  def project do
    [app: :extacct,
     version: "0.2.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :erlsom, :httpoison]]
  end

  defp deps do
    [
      {:erlsom, "~> 1.4"},
      {:intacct_dtd, github: "intacct/intacct_dtd", compile: false, app: false},
      {:poison, " ~> 2.0"},
      {:httpoison, " ~> 0.9"},
      {:xml_builder, "~> 0.0.8"},
      {:sweet_xml, "~> 0.6"},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_)    , do: ["lib"]
end
