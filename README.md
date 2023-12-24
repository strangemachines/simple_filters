# Simple filters

Simple filters for Ecto from query params.


## Usage

```elixir
def MySchema do
  import SimpleFilters

  schema "myschema" do
    # your fields
  end

  filter_boolean("enabled", [m], m)
  filter_range("age", [m], m)
  filter_string("name", [m], m)
  filter_like("description", [m], m)
  filter_string("foreign", [n: n], n)
  filter_list("color", [m], m)

  def filter_by_params(query, params) do
    # plug the filters where ever you are handling where statements
    # I find it convenient to put them in one function
    query
    |> filter_by_enabled(params)
    |> filter_by_age(params)
    |> filter_by_name(params)
    |> filter_by_description(params)
    |> filter_by_foreign(params)
    |> filter_by_color(params)
  end
end
```

Now you can query `MySchema` like so:

```elixir
 MySchema 
 |> MySchema.filter_by_params(params)
```

Supported queries for boolean filters:

```elixir
%{"field" => "true"|"false"|true|false}
```

Supported queries for range filters:

```elixir
%{"from_field" => 0, "to_field" => 100}


# Strings will be converted to integers,
# or 0 when that can't be done
%{"from_field" => "15", "to_field" => "weird"}

# Works with only one side too:
%{"from_field" => 55}
%{"to_field" => 25}
```

Supported queries for string filters:

```elixir
%{"name" => "some name"}

# Supports != by prefixing !
%{"name" => "!some name"}
```

Supported queries for list filters:

```elixir
%{"color" => "red"}

# To get multiple colors:
%{"color" => ["red", "blue"]}
```

Supported queries for like filters:

```elixir
# Results in an ilike(:description, "%hello world%") where
%{"description" => "hello world"} 

# Supports != by prefixing !
%{"description" => "!hello world"}

# Supports matching only at the end with ^
# i.e. ilike(:description, "hello world%")
%{"description" => "^hello world"}
```