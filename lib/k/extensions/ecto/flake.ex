# TODO
defmodule Ecto.Flake do
  @moduledoc false

  use Ecto.Type

  @type t :: <<_::96>>

  @impl true
  def type, do: :binary

  @impl true
  def cast(<<_::96>> = flake) do
    {:ok, flake}
  end

  def cast(_), do: :error

  @impl true
  def dump(<<_::96>> = flake) do
    {:ok, flake}
  end

  def dump(_), do: :error

  @impl true
  def load(<<_::96>> = flake) do
    {:ok, flake}
  end

  def load(_), do: :error

  @spec bingenerate :: t
  def bingenerate do
    <<
      System.system_time(:millisecond)::48,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::24
    >>
  end

  @impl true
  def autogenerate, do: bingenerate()

  @spec datetime(t) :: DateTime.t()
  def datetime(<<ms::48, _::48>>) do
    DateTime.from_unix!(ms, :millisecond)
  end

  # @spec inspect(t, Inspect.Opts.t()) :: Inspect.Algebra.t()
  # def inspect(<<ms::48, worker::24, uniq::24>>, opts) do
  #   Inspect.Algebra.concat([
  #     "#Flake<",
  #     Inspect.Algebra.to_doc(
  #       [
  #         datetime: DateTime.from_unix!(ms, :millisecond),
  #         worker: worker,
  #         uniq: uniq
  #       ],
  #       opts
  #     ),
  #     ">"
  #   ])
  # end
end
