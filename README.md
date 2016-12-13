# Thrifter

Generate thrift clients for multiple languages with ease.

## Installation

``` elixir
def deps do
  [
    {:thrifter, github: "renderedtext/thrifter", ref: "origin/master"}
  ]
end
```

### Generate Ruby client

``` bash
mix thrifter.ruby
```

### Generate Elixir client

``` bash
mix thrifter.elixir
```

### Generate all clients

``` bash
mix thrifter.all
```

### Environment variables and credentials

Environment variables for setup can be retrieved by using `mix thrifter.env` or
by pulling them manually from `s3://renderedtext-secrets/thrifter/env`.

Credentials for accounts that Thrifter uses can be found at 
`s3://renderedtext-secrets/thrifter/credentials`.
