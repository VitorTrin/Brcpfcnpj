defmodule Brcpfcnpj.Changeset do
  @moduledoc """
  Define funções para serem utilizadas em conjunto com a API de changeset do Ecto.
  """

  @type t :: %{
          changes: %{required(atom()) => term()},
          errors: [{atom(), error()}],
          valid?: boolean()
        }
  @type error :: {atom, error_message}
  @type error_message :: String.t() | {String.t(), Keyword.t()}

  @doc """
  Valida se essa mudança é um cnpj válido. Aceita um ou mais fields

  ## Options

    * `:message` - A mensagem em caso de erro, o default é "Invalid Cnpj"

  ## Examples

      validate_cnpj(changeset, :cnpj)

      validate_cnpj(changeset, [:cnpj, :other_cnpj])

  """
  @spec validate_cnpj(t, atom | list, Keyword.t()) :: t
  def validate_cnpj(changeset, field), do: validate_cnpj(changeset, field, [])

  def validate_cnpj(changeset, field, opts) when is_atom(field) do
    validate(changeset, field, fn value ->
      cond do
        Brcpfcnpj.cnpj_valid?(%Cnpj{number: value}) -> []
        true -> [{field, message(opts, {"Invalid Cnpj", validation: :cnpj})}]
      end
    end)
  end

  def validate_cnpj(changeset, fields, opts) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, acc_changeset ->
      validate_cnpj(acc_changeset, field, opts)
    end)
  end

  @doc """
  Valida se essa mudança é um cpf válido. Aceita um ou mais fields

  ## Options

    * `:message` - A mensagem em caso de erro, o default é "Invalid Cpf"

  ## Examples

      validate_cpf(changeset, :cpf)

      validate_cpf(changeset, [:cpf, :cnpj])

  """
  @spec validate_cpf(t, atom | list, Keyword.t()) :: t
  def validate_cpf(changeset, field), do: validate_cpf(changeset, field, [])

  def validate_cpf(changeset, field, opts) when is_atom(field) do
    validate(changeset, field, fn value ->
      cond do
        Brcpfcnpj.cpf_valid?(%Cpf{number: value}) -> []
        true -> [{field, message(opts, {"Invalid Cpf", validation: :cpf})}]
      end
    end)
  end

  def validate_cpf(changeset, fields, opts) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, acc_changeset ->
      validate_cpf(acc_changeset, field, opts)
    end)
  end

  defp validate(changeset, field, validator) do
    %{changes: changes, errors: errors} = changeset

    value = Map.get(changes, field)
    new = if is_nil(value), do: [], else: validator.(value)

    case new do
      [] -> changeset
      [_ | _] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end

  defp message(opts, default) do
    message = Keyword.get(opts, :message, default)
    format_message(message)
  end

  defp format_message({_, _} = msg), do: msg
  defp format_message(msg) when is_binary(msg), do: {msg, []}
end
