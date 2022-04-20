-module(use_mnesia).
-export([insert_new_subscribers/0, list_all_subscribers/0, lookup_subscribers/1, delete_subscribers/1
    , update_subscribers/0]).
% -record(subscriber, {sub_id, account_id, last_deduction_date, next_deduction_date, installments_remaining, 
% installments_completed}).
-record(subscriber, {sub_id, name}).



insert_new_subscribers() ->
    Subscriber1 = #subscriber{sub_id=1,name=michael},
    subscriber_mnesia:store_subscriber(Subscriber1),
    Subscriber2 = #subscriber{sub_id=2, name=ramez},
    subscriber_mnesia:store_subscriber(Subscriber2).

list_all_subscribers() ->
    subscriber_mnesia:list_all().

lookup_subscribers(SubscriberID) ->
    Subscriber = subscriber_mnesia:lookup_subscriber(SubscriberID),
    io:format("Subscriber with id ~p is ~p~n", [SubscriberID, Subscriber]).


delete_subscribers(SubscriberID) ->
    subscriber_mnesia:delete_subscriber(SubscriberID).

update_subscribers() ->
    SubscriberEdit = #subscriber{sub_id=1, name=edited_name},
    subscriber_mnesia:update_subscriber(SubscriberEdit),

    SubscriberEditWrong = #subscriber{sub_id=17, name=wrong_edit},
    subscriber_mnesia:update_subscriber(SubscriberEditWrong).


