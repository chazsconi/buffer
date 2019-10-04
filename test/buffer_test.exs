defmodule BufferTest do
  use ExUnit.Case
  doctest Buffer

  Enum.each([Buffer.Queue, Buffer.List, Buffer.InstrumentedQueue], fn impl ->
    describe "#{impl}" do
      setup do
        impl = unquote(impl)
        {:ok, impl: impl, emtpy: impl.new()}
      end

      test "empty", %{impl: impl, emtpy: empty} do
        assert 0 == impl.size(empty)

        {popped, _} = impl.pop(empty, 1)
        assert [] == popped

        {popped, _} = impl.pop(empty, 2)
        assert [] == popped
      end

      test "push/pop 1", %{impl: impl, emtpy: empty} do
        {popped, updated} = empty |> impl.push([:a, :b]) |> impl.pop(1)
        assert [:a] == popped
        assert 1 == impl.size(updated)
      end

      test "push/pop all in steps", %{impl: impl, emtpy: empty} do
        {_, updated} = empty |> impl.push([:a, :b]) |> impl.pop(1)
        {popped, updated} = updated |> impl.pop(1)
        assert [:b] == popped
        assert 0 == impl.size(updated)
      end

      test "push/pop all", %{impl: impl, emtpy: empty} do
        {popped, updated} = empty |> impl.push([:a, :b]) |> impl.pop(2)
        assert [:a, :b] == popped
        assert 0 == impl.size(updated)
      end

      test "push/pop 3", %{impl: impl, emtpy: empty} do
        {popped, updated} = empty |> impl.push([:a, :b]) |> impl.pop(3)
        assert [:a, :b] == popped
        assert 0 == impl.size(updated)
      end

      test "push multiple/pop", %{impl: impl, emtpy: empty} do
        {popped, updated} = empty |> impl.push([:a, :b]) |> impl.push([:c, :d]) |> impl.pop(3)
        assert [:a, :b, :c] == popped
        assert 1 == impl.size(updated)
      end

      if impl == Buffer.InstrumentedQueue do
        test "queueing_time", %{impl: impl, emtpy: empty} do
          buffer = empty |> impl.push([:a])
          :timer.sleep(100)
          buffer = buffer |> impl.push([:b])
          :timer.sleep(100)
          queueing_ms_a = buffer |> impl.queueing_time(:millisecond)
          queueing_s_a = buffer |> impl.queueing_time()
          {_, buffer} = buffer |> impl.pop(1)
          queueing_ms_b = buffer |> impl.queueing_time(:millisecond)

          assert 0 == queueing_s_a
          assert 200 <= queueing_ms_a
          assert queueing_ms_a < 250

          assert 100 <= queueing_ms_b
          assert queueing_ms_b < 150
        end

        test "queueing time with empty", %{impl: impl, emtpy: empty} do
          assert nil == impl.queueing_time(empty)
          assert nil == impl.queueing_time(empty, :millisecond)
        end
      end
    end
  end)
end
