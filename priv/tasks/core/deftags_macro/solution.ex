defmodule Taggable do
  defmacro __using__(opts) do
    tags = Keyword.get(opts, :tags)

    unless is_list(tags) and tags != [] do
      raise ArgumentError, "use Taggable requires a non-empty :tags list"
    end

    predicates =
      for tag <- tags do
        name = :"#{tag}?"

        quote do
          def unquote(name)(list) when is_list(list), do: unquote(tag) in list
        end
      end

    quote do
      def tags, do: unquote(tags)

      def valid?(list) when is_list(list) do
        Enum.all?(list, &(&1 in unquote(tags)))
      end

      unquote_splicing(predicates)
    end
  end
end
