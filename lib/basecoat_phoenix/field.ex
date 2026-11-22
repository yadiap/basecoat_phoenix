defmodule BasecoatPhoenix.Field do
  @moduledoc """
  Normalizes a `Phoenix.HTML.FormField` or explicit attributes into the values
  Basecoat form components need.
  """

  @type t :: %{
          name: String.t() | nil,
          id: String.t() | nil,
          value: term(),
          errors: [String.t()],
          invalid?: boolean(),
          describedby: String.t() | nil
        }

  @doc """
  Resolves a form field or explicit attributes.

  ## Options

    * `:name`, `:id`, `:value` - used when `field` is `nil`
    * `:errors` - list of messages or `{message, meta}` tuples
    * `:describedby` - string or list of ids, joined with the derived ids
    * `:has_description` - adds `"<id>-description"`
    * `:invalid` - forces `invalid?`
  """
  @spec resolve(Phoenix.HTML.FormField.t() | nil, keyword()) :: t()
  def resolve(field, opts \\ [])

  def resolve(%Phoenix.HTML.FormField{} = field, opts) do
    build(
      field.name,
      field.id,
      field.value,
      Enum.map(field.errors, &error_message/1),
      opts
    )
  end

  def resolve(nil, opts) do
    build(opts[:name], opts[:id], opts[:value], List.wrap(opts[:errors]), opts)
  end

  defp build(name, id, value, errors, opts) do
    describedby =
      []
      |> add_ids(opts[:describedby])
      |> add_ids(if opts[:has_description] && id, do: "#{id}-description")
      |> add_ids(if errors != [] && id, do: "#{id}-error")
      |> Enum.join(" ")

    %{
      name: name,
      id: id,
      value: value,
      errors: errors,
      invalid?: !!opts[:invalid] or errors != [],
      describedby: if(describedby == "", do: nil, else: describedby)
    }
  end

  defp add_ids(acc, nil), do: acc
  defp add_ids(acc, ids) when is_list(ids), do: acc ++ Enum.reject(ids, &is_nil/1)
  defp add_ids(acc, id), do: acc ++ [id]

  defp error_message({message, _meta}), do: to_string(message)
  defp error_message(message), do: to_string(message)
end
