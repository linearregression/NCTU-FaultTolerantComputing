defmodule FairlossLink do
    @lossrate 0.00002

    def init(name, upper) do
        :global.register_name(name, self)
        listen(upper)
    end

    def listen(upper) do
        receive do
            {:send, dest, mid, msg} -> on_send(dest, mid, msg)
            {:deliver, src, mid, msg} -> on_deliver(upper, src, mid, msg)
        end
        listen(upper)
    end

    def on_send(dest, mid, msg) do
        pid = :global.whereis_name(dest)
        if pid != :undefined and is_packet_loss?(msg) == :false do
            send pid, {:deliver, self, mid, msg}
        end
    end

    def on_deliver(upper, src, mid, msg) do
        send upper, {:deliver, src, mid, msg}
    end

    def is_packet_loss?(msg) do
        cond do
            msg == :start_exp or msg == :end_exp -> :false
            :random.uniform() < @lossrate ->
                IO.puts("packet loss")
                :true
            :true -> :false
        end
    end
end
