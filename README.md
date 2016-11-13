# DatasetLoader

DatasetLoader is a simple tsp dataset loader.

The `DatasetLoader` assumes there is a `data` folder at the root of your
project.
Example importing a dataset located at "root_dir/data/st70-tsp.txt"

  ```elixir
  # Load dataset from file.
  DatasetLoader.import("st70-tsp.txt")
  #=> DatasetLoader.TspProblem{
    name: "st70",
    type: "TSP",
    ...
    node_coord: [{id, x, y}, ... ]
  }
  ```

Note: Works only with **TSPLIB** format.

See [datasets](http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95/tsp/) to
get other tsp dataset.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `dataset_loader` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:dataset_loader, "~> 0.1.0"}]
    end
    ```

  2. Ensure `dataset_loader` is started before your application:

    ```elixir
    def application do
      [applications: [:dataset_loader]]
    end
    ```
