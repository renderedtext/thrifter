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

### Credentials

Credentials needed to use Thrifter can be found at `s3://renderedtext-secrets/thrifter/credentials`.
