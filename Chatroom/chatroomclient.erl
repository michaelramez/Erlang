-module(chatroomclient).
-export([start_client/1, loop_client_commands/1, loop_client_server/1]).

start_client(Name) ->
    {ok, Socket} = gen_tcp:connect("localhost", 8000, [binary]),
    ok=gen_tcp:send(Socket, term_to_binary({register,Name})),
    ClientCommandsID = spawn(chatroomclient, loop_client_commands, [Socket]),
    ClientServerID = spawn(chatroomclient, loop_client_server, [Socket]),    
    register(Name, ClientCommandsID),
    ok=gen_tcp:controlling_process(Socket, ClientServerID).

loop_client_commands(Socket) ->
    receive
        {send, Msg, Other} ->
            ok=gen_tcp:send(Socket, term_to_binary([send,Msg,Other])),
            loop_client_commands(Socket);
        
        {broadcast, Msg} -> 
            ok=gen_tcp:send(Socket, term_to_binary([broadcast,Msg])),
            loop_client_commands(Socket);

        stop ->
            gen_tcp:close(Socket)
    end.

loop_client_server(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            Str = binary_to_term(Bin),
            io:format("received ~p", [Str]),
            loop_client_server(Socket);

        {tcp_closed, Socket} ->
            io:format("Client socket closed ~n")
      
    end.
