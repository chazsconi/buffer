defmodule Buffer do
  @moduledoc "Behaviour for Buffer"
  @type t :: Buffer.t()

  @typedoc "An item in a buffer"
  @type item :: any()

  @doc "Creates a new emtpy buffer"
  @callback new() :: t()

  @doc "Pushes items into the buffer and returns the buffer"
  @callback push(t(), [item()]) :: t()

  @doc "Pops `count` items from the buffer.  Returns `{items, buffer}`. If there are less than `count` items in the buffer all items are popped."
  @callback pop(t(), count :: integer()) :: {[item()], t()}

  @doc "Returns the number of items in the buffer"
  @callback size(t()) :: integer()
end

defmodule Buffer.List do
  @moduledoc "FIFO queue implemented with `List`"
  @behaviour Buffer

  def new(), do: []

  def push(list, items), do: list ++ items

  def pop(list, count), do: Enum.split(list, count)

  def size(list), do: length(list)
end

defmodule Buffer.Queue do
  @moduledoc "FIFO queue implemented with Erlang `:queue`"
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

defmodule Buffer.InstrumentedQueue do
  @moduledoc "An instumented FIFO queue"
  @behaviour Buffer

  defmodule Item do
    @moduledoc false
    defstruct [:inserted_at, :raw_item]
  end

  defmodule State do
    @moduledoc false
    defstruct [:impl, :buffer]
  end

  @doc "Creates a new empty queue. Can pass a module that implements the underlying `Buffer` behaviour."
  def new(impl \\ Buffer.Queue), do: %State{impl: impl, buffer: impl.new()}

  def push(%State{impl: impl, buffer: buffer} = state, raw_items) do
    items =
      raw_items
      |> Enum.map(fn raw_item ->
        %Item{inserted_at: System.monotonic_time(), raw_item: raw_item}
      end)

    %State{state | buffer: impl.push(buffer, items)}
  end

  def pop(%State{impl: impl, buffer: buffer} = state, count) do
    {items, buffer} = impl.pop(buffer, count)

    raw_items =
      items
      |> Enum.map(fn %Item{raw_item: raw_item} -> raw_item end)

    {raw_items, %State{state | buffer: buffer}}
  end

  @doc """
  Returns the elapsed time that the item at the head of the queue has been queued for
  If there is nothing in the queue, `nil` is returned
  """
  @spec queueing_time(Buffer.t(), System.time_unit()) :: integer()
  def queueing_time(%State{impl: impl, buffer: buffer}, time_unit \\ :second) do
    {items, _} = impl.pop(buffer, 1)

    case items do
      [] ->
        nil

      [%Item{inserted_at: inserted_at}] ->
        System.convert_time_unit(System.monotonic_time() - inserted_at, :native, time_unit)
    end
  end

  def size(%State{impl: impl, buffer: buffer}) do
    impl.size(buffer)
  end
end
