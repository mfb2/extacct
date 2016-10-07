# Extacct

Elixir library for communicating with the Intacct API.

*__Note:__ This module is under active development and not yet available on `hex.pm`.*

## Installation

To use `Extacct` in your application, add `extacct` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:extacct, "~> 0.1.0"}]
    end
    ```

## Configuration

To configure Extacct, update the appropriate runtime environment configuration
with the API credentials provided to your firm by Intacct.

```elixir
config :extacct, :intacct_api,
  gateway:             Extacct.API.Gateway,  # Configurable Gateway module for testing purposes
  endpoint:            "https://api.intacct.com/ia/xml/xmlgw.phtml", # The Intacct endpoint URL
  dtd_version:         "3.0",  # Version 3.0 is currently the only supported option.
  return_format:       "xml",  # XML is the only supported option at this time.
  minify_xml:          true,   # This option toggles the presence of new lines and tabs on outbound XML messages.
  page_size:           100,    # Number of records to return on response messages
  wait_time:           30,     # Time in seconds to wait for Intacct processing to complete
  connection_timeout:  60000,  # Timeout in milliseconds for the HTTP connection
  recv_timeout:        60000,  # Timeout in milliseconds for receiving data back from the HTTP request
  timeout:             60000,  # Overall timeout parameter for HTTPoison
  read_more_wait_time: 5000,   # Time in milliseconds to wait before issuing a `readMore` command to Intacct
  sender_id:           "SENDER_ID_GOES_HERE",
  sender_password:     "SENDER_PW_GOES_HERE",
  user_id:             "USER_ID_GOES_HERE",
  company_id:          "COMPANY_ID_GOES_HERE",
  user_password:       "USER_PW_GOES_HERE"
```

## Notes

Messages returned to Extacct consumers will be formatted as Keyword lists.

### Example
```elixir

# Note: All examples are contrived; actual fields and data returned from Intacct will vary
# based on the object and the implementation details for your firm.

iex> Extacct.read("GLENTRY", [])
[glentry: [recordno: "1000", entry_date: "09/16/2016"], glentry: [recordno: "1001", entry_date: "09/17/2016"]]

```

## Contributing

Sure, go for it!  Send through a PR with some tests and I'll happily review.  I am friendly.
