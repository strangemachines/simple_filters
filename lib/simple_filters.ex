defmodule SimpleFilters do
  @moduledoc """
  Macros for applying filters to ecto queries.
  """
  @spec parse_integer(value :: String.t() | integer()) :: integer()
  @spec cut_operator(string :: String.t()) :: String.t()

  @doc """
  Parses a value to an integer, converting it when necessary.
  """
  def parse_integer(value) when is_integer(value), do: value

  def parse_integer(value) do
    case Integer.parse(value) do
      :error -> 0
      n -> elem(n, 0)
    end
  end

  @doc """
  Gets the column from opts or name
  """
  def get_column(name, opts) do
    if opts[:column], do: opts[:column], else: :"#{name}"
  end

  @doc """
  Cuts the operator part from a string, so that it can be put in a query.
  """
  def cut_operator(string), do: String.slice(string, 1..-1//1)

  @doc """
  Filters for a boolean a value.
  """
  defmacro filter_boolean(name, bindings, table) do
    function = :"filter_by_#{name}"
    column = :"#{name}"
    binds = var!(bindings)

    quote do
      def unquote(function)(query, %{"#{unquote(name)}" => "true"}) do
        where(query, unquote(binds), unquote(table).unquote(column) == true)
      end

      def unquote(function)(query, %{"#{unquote(name)}" => "false"}) do
        where(query, unquote(binds), unquote(table).unquote(column) == false)
      end

      def unquote(function)(query, %{"#{unquote(name)}" => value})
          when is_boolean(value) do
        where(query, unquote(binds), unquote(table).unquote(column) == ^value)
      end

      def unquote(function)(query, _params), do: query
    end
  end

  defmacro filter_range(name, bindings, table) do
    function = :"filter_by_#{name}"
    column = :"#{name}"
    binds = var!(bindings)

    quote do
      def unquote(function)(query, %{
            "from_#{unquote(name)}" => from_value,
            "to_#{unquote(name)}" => to_value
          }) do
        query
        |> where(
          unquote(binds),
          unquote(table).unquote(column) >= ^Filters.parse_integer(from_value)
        )
        |> where(
          unquote(binds),
          unquote(table).unquote(column) <= ^Filters.parse_integer(to_value)
        )
      end

      def unquote(function)(query, %{"from_#{unquote(name)}" => value}) do
        where(
          query,
          unquote(binds),
          unquote(table).unquote(column) >= ^Filters.parse_integer(value)
        )
      end

      def unquote(function)(query, %{"to_#{unquote(name)}" => value}) do
        where(
          query,
          unquote(binds),
          unquote(table).unquote(column) <= ^SimpleFilters.parse_integer(value)
        )
      end

      def unquote(function)(query, _params), do: query
    end
  end

  defmacro filter_string(name, bindings, table, opts \\ []) do
    function = :"filter_by_#{name}"
    binds = var!(bindings)
    column = SimpleFilters.get_column(name, opts)

    quote do
      def unquote(function)(query, %{"#{unquote(name)}" => value}) do
        cond do
          String.starts_with?(value, "!") ->
            new_value = SimpleFilters.cut_operator(value)

            where(
              query,
              unquote(binds),
              unquote(table).unquote(column) != ^String.downcase(new_value)
            )

          true ->
            where(
              query,
              unquote(binds),
              unquote(table).unquote(column) == ^String.downcase(value)
            )
        end
      end

      def unquote(function)(query, _params), do: query
    end
  end

  defmacro filter_list(name, bindings, table, opts \\ []) do
    function = :"filter_by_#{name}"
    binds = var!(bindings)
    column = SimpleFilters.get_column(name, opts)

    quote do
      def unquote(function)(query, %{"#{unquote(name)}" => value})
          when is_list(value) do
        where(query, unquote(binds), unquote(table).unquote(column) in ^value)
      end

      def unquote(function)(query, %{"#{unquote(name)}" => value}) do
        where(query, unquote(binds), unquote(table).unquote(column) == ^value)
      end

      def unquote(function)(query, _params), do: query
    end
  end

  @doc """
  Filters for a string using ilike.
  """
  defmacro filter_like(name, bindings, table, opts \\ []) do
    function = :"filter_by_#{name}"
    binds = var!(bindings)
    column = SimpleFilters.get_column(name, opts)

    quote do
      def unquote(function)(query, %{"#{unquote(name)}" => value}) do
        if is_binary(value) do
          cond do
            String.starts_with?(value, "^") ->
              new_value = Filters.cut_operator(value)

              where(
                query,
                unquote(binds),
                ilike(unquote(table).unquote(column), ^"#{new_value}%")
              )

            String.starts_with?(value, "!") ->
              new_value = Filters.cut_operator(value)

              where(
                query,
                unquote(binds),
                not ilike(unquote(table).unquote(column), ^"%#{new_value}%")
              )

            true ->
              where(
                query,
                unquote(binds),
                ilike(unquote(table).unquote(column), ^"%#{value}%")
              )
          end
        else
          first_value = value |> List.first() |> Filters.cut_operator()
          second_value = value |> List.last() |> Filters.cut_operator()

          where(
            query,
            unquote(binds),
            ilike(unquote(table).unquote(column), ^"#{first_value}%")
          )
          |> where(
            unquote(binds),
            unquote(table).unquote(column) != ^second_value
          )
        end
      end

      def unquote(function)(query, _params), do: query
    end
  end
end
