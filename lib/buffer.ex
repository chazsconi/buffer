defmodule Buffer do
  @moduledoc "Behaviour for Buffer"
  @type t :: Buffer.t()
  @callback new() :: t
  @callback push(t, []) :: t
  @callback pop(t, integer) :: {[], t}
  @callback size(t) :: integer
end

defmodule Buffer.List do
  @behaviour Buffer

  def new(), do: []

  def push(list, items), do: list ++ items

  def pop(list, count), do: Enum.split(list, count)

  def size(list), do: length(list)
end

defmodule Buffer.Queue do
  @behaviour Buffer

  def new(), do: :queue.new()

  def push(queue, items) do
    :queue.join(queue, :queue.from_list(items))
  end

  def pop(queue, request_count) do
    if request_count > :queue.len(queue) do
      {:queue.to_list(queue), :queue.new()}
    else
      {outq, queue} = :queue.split(request_count, queue)
      {:queue.to_list(outq), queue}
    end
  end

  def size(queue), do: :queue.len(queue)
end
