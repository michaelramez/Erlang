-module(chatroomclient).
-export([start_client/1, loop_client_send/1, loop_client_recv/1]).

start_client(Username) ->
    {ok, Socket} = gen_tcp:connect("localhost", 8000, [binary]),
    ok=gen_tcp:send(Socket, term_to_binary({register,Username})),
    ClientSendPID = spawn(chatroomclient, loop_client_send, [Socket]),
    ClientRecvPID = spawn(chatroomclient, loop_client_recv, [Socket]),    
    register(Username, ClientSendPID),
    ok=gen_tcp:controlling_process(Socket, ClientRecvPID).

loop_client_send(Socket) ->
    receive
        {send, Msg, OtherUsername} ->
            ok=gen_tcp:send(Socket, term_to_binary({send,Msg,OtherUsername})),
            loop_client_send(Socket);
        
        % {broadcast, Msg} -> 
        %     ok=gen_tcp:send(Socket, term_to_binary({broadcast,Msg})),
        %     loop_client_send(Socket);
        viewonline ->
            ok=gen_tcp:send(Socket, term_to_binary(viewonline));
        
        stop ->
            gen_tcp:close(Socket)
    end.

loop_client_recv(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            ServerReply = binary_to_term(Bin),
            % io:format("received ~p", [ServerReply]),
            handle_server_reply(ServerReply),
            loop_client_recv(Socket);

        {tcp_closed, Socket} ->
            io:format("Client socket closed ~n")
      
    end.


handle_server_reply({message, Msg, OtherUsername}) ->
    io:format("received a message from ~p: ~p~n", [OtherUsername, Msg]);

handle_server_reply({online, OnlineUsers}) ->
    io:format("Current Online Users: ~p~n", [OnlineUsers]).

