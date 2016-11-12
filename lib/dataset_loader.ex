defmodule TspProblem do
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

  iex> TspProblem.new
  %TspProblem{
    name: nil,
    type: nil,
    comments: [],
    dimension: 0,
    edge_weight_type: nil,
    node_coord: []
  }
  """
  def new do
    %Mod{
      comments: [],
      dimension: 0,
      node_coord: []
    }
  end

  @doc """
  Sets a the given `value` for the specified `field`.

  ## Examples
      iex> problem = TspProblem.set(TspProblem.new, :name, "att48")
      iex> problem.name
      "att48"
  """
  def set(%Mod{} = problem, key, value) do
    struct(problem, %{key => value})
  end

  def add(%Mod{comments: comments} = problem, :comments, comment) do
    %Mod{problem | comments: [comment |comments]}
  end
  def add(%Mod{node_coord: nodes} = problem, :node_coord, node) do
    %Mod{problem | node_coord: [node |nodes]}
  end
end

defmodule DatasetLoader do
  require Logger

  alias TspProblem, as: Tsp
  NimbleCSV.define(HeaderParser, separator: ":", escape: "\"")
  NimbleCSV.define(CoordParser,  separator: " ", escape: "\"")

  @doc """
  iex> problem = DatasetLoader.load("st70-tsp.txt")
  iex> problem.type
  "TSP"
  """
  def load(filename) do
    Logger.info "Loading data..."

    data =
      Path.join(~w(#{File.cwd!} data #{filename}))
      |> Path.expand
      |> File.read!

    {problem, line_num} =
      data
      |> HeaderParser.parse_string
      |> Enum.reduce_while({TspProblem.new, 0}, &set_header(&1, &2))

    {problem, line_num} =
        data
        |> CoordParser.parse_string
        |> Enum.drop(line_num)
        |> Enum.reduce_while({problem, line_num}, &add_node_coord(&1, &2))
    problem
  end

  defp set_header(line, {problem, line_num}) do
    {cont, problem} =
      line
      |> Enum.map(&String.trim(&1))
      |> set_header(problem)

    {cont, {problem, line_num + 1}}
  end
  defp set_header(["NAME",                value], pb), do: {:cont, pb |> Tsp.set(:name, value)}
  defp set_header(["TYPE",                value], pb), do: {:cont, pb |> Tsp.set(:type, value)}
  defp set_header(["COMMENT",             value], pb), do: {:cont, pb |> Tsp.add(:comments, value)}
  defp set_header(["DIMENSION",           value], pb), do: {:cont, pb |> Tsp.set(:dimension, value)}
  defp set_header(["EDGE_WEIGHT_TYPE",    value], pb), do: {:cont, pb |> Tsp.set(:edge_weight_type, value)}
  defp set_header(["NODE_COORD_SECTION"],         pb), do: {:halt, pb}
  defp set_header(                _,              pb), do: pb

  defp add_node_coord(line, {problem, line_num}) do
    {cont, problem} =
      line
      |> Enum.map(&String.trim(&1))
      |> add_node_coord(problem)

    {cont, {problem, line_num + 1}}
  end
  defp add_node_coord([id, x, y], pb), do: {:cont, pb |> Tsp.add(:node_coord, {id, x, y})}
  defp add_node_coord(["EOF"], %Tsp{comments: comments, node_coord: nodes} = pb) do
    {
      :halt,
      %Tsp{ pb |
              comments: comments |> Enum.reverse,
              node_coord: nodes |> Enum.reverse
          }
    }
  end


  # def build([], %Tsp{comments: comments, node_coord: nodes} = problem) do
  #   %Tsp{problem |
  #         comments: Enum.reverse(comments),
  #         node_coord: Enum.reverse(nodes)
  #       }
  # end
  # def build([[line]|tail], problem) do
  #   problem =
  #     line
  #     |> String.split([":"])
  #     |> Enum.map(&String.trim(&1))
  #     |> store(problem)
  #
  #   build(tail, problem)
  # end



end
