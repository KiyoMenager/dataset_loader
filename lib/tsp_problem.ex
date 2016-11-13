defmodule DatasetLoader.TspProblem do
  @moduledoc """
  A module that represents a instance of a tsp problem.
  """
  @opaque t :: %__MODULE__{
    name: String.t,
    type: String.t,
    comments: list(String.t),
    dimension: String.t,
    edge_weight_type: String.t,
    node_coord: list(tuple)
  }
  defstruct [
    :name,
    :type,
    :comments,
    :dimension,
    :edge_weight_type,
    :node_coord
  ]

  alias __MODULE__, as: Mod

  @doc """
  Returns a new `TspProblem`.

  iex> DatasetLoader.TspProblem.new
  %DatasetLoader.TspProblem{
    name: nil,
    type: nil,
    comments: [],
    dimension: 0,
    edge_weight_type: nil,
    node_coord: []
  }
  """
  @spec new :: t

  def new do
    %Mod{
      comments: [],
      dimension: 0,
      node_coord: []
    }
  end

  @doc """
  Sets the given `value` under `key`.

  ## Examples
      iex> problem =
      ...>   DatasetLoader.TspProblem.new
      ...>   |> DatasetLoader.TspProblem.set(:name, "att48")
      iex> problem.name
      "att48"

  """
  @spec set(t, atom, term) :: t

  def set(%Mod{} = problem, key, value) do
    struct(problem, %{key => value})
  end

  @doc """
  Adds a the given `value` to the list under `key`.

  ## Examples
      iex> problem =
      ...>   DatasetLoader.TspProblem.new
      ...>   |> DatasetLoader.TspProblem.add(:node_coord, {"id", "x", "y"})
      iex> problem.node_coord
      [{"id", "x", "y"}]

  """
  @spec add(t, atom, term) :: t

  def add(%Mod{comments: comments} = problem, :comments, comment) do
    %Mod{problem | comments: [comment |comments]}
  end
  def add(%Mod{node_coord: nodes} = problem, :node_coord, {_, _, _} = node) do
    %Mod{problem | node_coord: [node |nodes]}
  end
end
