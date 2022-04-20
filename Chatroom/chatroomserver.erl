-module(chatroomserver).
-export([start_server/0, clients_table_handler/1, client_register/1]).


start_server() ->
    ClientsReference = subscriberETS:start(),
    ClientsTablePID = spawn(chatroomserver, clients_table_handler, [ClientsReference]),
    register(clients, ClientsTablePID),
    start_listen().

clients_table_handler(ClientsReference) ->
    receive
        {insert, Username, Socket} ->
            true = subscriberETS:connect(ClientsReference, Username, Socket),
            clients_table_handler(ClientsReference);

        {delete, Username} ->
            subscriberETS:disconnect(ClientsReference, Username),
            clients_table_handler(ClientsReference);

        {send, Msg, Username, OtherUsername} ->
            OtherSocket = subscriberETS:get_socket(ClientsReference, OtherUsername),
            ok = gen_tcp:send(OtherSocket, term_to_binary({message, Msg, Username})),
            clients_table_handler(ClientsReference);

        {viewonline, Username} ->
            UserSocket = subscriberETS:get_socket(ClientsReference, Username),
            AllOnlineUsers = subscriberETS:get_online_users(ClientsReference),
            OtherOnlineUsers = lists:delete([Username], AllOnlineUsers),
            ok = gen_tcp:send(UserSocket, term_to_binary({online, OtherOnlineUsers})),
            clients_table_handler(ClientsReference)
    end.

start_listen() ->
    {ok, Listen} = gen_tcp:listen(8000, [binary, {reuseaddr, true},{active, true}]),
    loop_server(Listen),
    start_listen().

loop_server(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    HandlerPID = spawn(chatroomserver, client_register, [Socket]),
    ok = gen_tcp:controlling_process(Socket, HandlerPID),
    loop_server(Listen).


client_register(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            {register,Username} = binary_to_term(Bin),
            io:format("Registering ~p~n", [Username]),
            clients ! {insert, Username, Socket},
            clients ! {viewonline, Username},
            client_handler(Socket, Username);

        {tcp_closed, Socket} ->
            io:format("Handler socket closed ~n")
    end.

client_handler(Socket, Username) ->
    receive
        {tcp, Socket, Bin} ->
            ClientRequest = binary_to_term(Bin),
            handle_client_request(ClientRequest, Username),
            client_handler(Socket, Username);

        {tcp_closed, Socket} ->
            io:format("Handler socket closed ~n"),
            clients ! {delete, Username}
    end.
            

handle_client_request({send, Msg, OtherUsername}, Username) ->

            io:format("Sending ~p from ~p to ~p~n", [Msg, Username, OtherUsername]),
            clients ! {send, Msg, Username, OtherUsername};

handle_client_request(viewonline, Username) ->
            clients ! {viewonline, Username}.


