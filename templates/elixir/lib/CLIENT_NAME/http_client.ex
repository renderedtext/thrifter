defmodule <%= client_module_name %>.HttpClient do
  use ThriftHttpTransport.Client,
    host: <%= client_module_name %>.Config.get(:host),
    port: <%= client_module_name %>.Config.get(:port)
end
