# Extacct

Elixir library for communicating with the Intacct API.

*__Note:__ This module is under active development and not yet available on `hex.pm`.*

## Installation

To use `Extacct` in your application,

  1. Add `extacct` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:extacct, "~> 0.1.0"}]
    end
    ```

  2. Ensure `extacct` is started before your application:

    ```elixir
    def application do
      [applications: [:extacct]]
    end
    ```

## Usage


Currently, only the `readReport` and `readMore` functions are supported.

```elixir
  iex> [report_reference] = Extacct.read_report("Report Name")
  [%{"REPORTID" => "report_id_string",
     "STATUS" => "PENDING"}]


  iex> report_content = Extacct.read_more(report_reference["REPORTID"])
  %{"0" => %{...}}
```
