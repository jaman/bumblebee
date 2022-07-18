defmodule Bumblebee.Utils.Axon do
  @moduledoc false

  @doc """
  Returns a list with all nodes in the given model and their names.
  """
  @spec nodes_with_names(Axon.t()) :: list({Axon.t(), String.t()})
  def nodes_with_names(model) do
    model
    |> nodes()
    |> Enum.map_reduce(%{}, fn axon, op_counts ->
      name = axon.name.(axon.op, op_counts)
      op_counts = Map.update(op_counts, axon.op, 1, &(&1 + 1))
      {{axon, name}, op_counts}
    end)
    |> elem(0)
  end

  defp nodes(axon) do
    {_ids, nodes} = nodes(axon, MapSet.new(), [])
    Enum.reverse(nodes)
  end

  defp nodes(axon, ids, nodes) do
    if MapSet.member?(ids, axon.id) do
      {ids, nodes}
    else
      {ids, nodes} = do_nodes(axon, ids, nodes)
      {MapSet.put(ids, axon.id), [axon | nodes]}
    end
  end

  defp do_nodes(%Axon{op: :container, parent: [container]}, ids, nodes) do
    Nx.Container.reduce(container, {ids, nodes}, &nodes_reducer/2)
  end

  defp do_nodes(%Axon{parent: parent}, ids, nodes) do
    Enum.reduce(parent || [], {ids, nodes}, &nodes_reducer/2)
  end

  defp nodes_reducer(%Axon{} = axon, {ids, nodes}) do
    nodes(axon, ids, nodes)
  end

  defp nodes_reducer(container, {ids, nodes}) do
    Nx.Container.reduce(container, {ids, nodes}, &nodes_reducer/2)
  end

  @doc """
  Extracts the underlying value from Axon container.
  """
  @spec unwrap_container(Axon.t()) :: term()
  def unwrap_container(%Axon{op: :container, parent: [container]}) do
    container
  end
end
