-module(chatroomserver).
-export([start_server/0, start_listen/0, loop_server/1, client_handler/1]).

start_server() ->
    spawn(chatroomserver, start_listen, []).

start_listen() ->
    {ok, Listen} = gen_tcp:listen(8000, [binary, {reuseaddr, true},{active, true}]),
    loop_server(Listen),
    start_listen().

loop_server(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    HandlerPID = spawn(chatroomserver, client_handler, [Socket]),
    ok = gen_tcp:controlling_process(Socket, HandlerPID),
    loop_server(Listen).

client_handler(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            Str = binary_to_term(Bin),
            io:format("received ~p~n", [Str]),
            client_handler(Socket);

        {tcp_closed, Socket} ->
            io:format("Handler socket closed ~n")
    end.
            
