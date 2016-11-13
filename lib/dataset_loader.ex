defmodule DatasetLoader do
  @moduledoc """
  A module to import instances of a tsp problem (Works with `TSPLIB` format).
  The `DatasetLoader` assumes there is a `data` folder at the root of the
  project.
  Example of importing an instance located at "root_dir/data/st70-tsp.txt"

    DatasetLoader.import("st70-tsp.txt")

  Instances can be found at http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95/tsp/

  """

  require Logger
  alias DatasetLoader.TspProblem, as: Problem
  NimbleCSV.define(HeaderParser, separator: ":", escape: "\"")
  NimbleCSV.define(CoordParser,  separator: " ", escape: "\"")

  @doc """
  iex> problem = DatasetLoader.import("st70-tsp.txt")
  iex> problem.type
  "TSP"
  iex> problem.dimension
  "70"
  iex> length(problem.node_coord)
  70

  """
  def import(filename) do
    Logger.info "Loading data..."

    data =
      Path.join(~w(#{File.cwd!} data #{filename}))
      |> Path.expand
      |> File.read!

    {problem, line_num} =
      data
      |> HeaderParser.parse_string
      |> Enum.reduce_while({Problem.new, 0}, &set_header(&1, &2))

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
  defp set_header(["NAME",                value], pb), do: {:cont, pb |> Problem.set(:name, value)}
  defp set_header(["TYPE",                value], pb), do: {:cont, pb |> Problem.set(:type, value)}
  defp set_header(["COMMENT",             value], pb), do: {:cont, pb |> Problem.add(:comments, value)}
  defp set_header(["DIMENSION",           value], pb), do: {:cont, pb |> Problem.set(:dimension, value)}
  defp set_header(["EDGE_WEIGHT_TYPE",    value], pb), do: {:cont, pb |> Problem.set(:edge_weight_type, value)}
  defp set_header(["NODE_COORD_SECTION"],         pb), do: {:halt, pb}
  defp set_header(                _,              pb), do: pb

  defp add_node_coord(line, {problem, line_num}) do
    {cont, problem} =
      line
      |> Enum.map(&String.trim(&1))
      |> add_node_coord(problem)

    {cont, {problem, line_num + 1}}
  end
  defp add_node_coord([id, x, y], pb) do
    {id, _} = Integer.parse(id)
    {x, _}  = Float.parse(x)
    {y, _}  = Float.parse(y)

    {:cont, pb |> Problem.add(:node_coord, {id, x, y})}
  end
  defp add_node_coord(["EOF"], %Problem{comments: comments, node_coord: nodes} = pb) do
    {
      :halt,
      %Problem{ pb |
              comments: comments |> Enum.reverse,
              node_coord: nodes |> Enum.reverse
          }
    }
  end
end
