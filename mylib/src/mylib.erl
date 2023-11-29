-module(mylib).

%% API exports
-export([empty/1, head/1, tail/1, enqueue/2, dequeue/1, enqueue_front/2, dequeue_back/1, get_size/1]).

%%====================================================================
%% API functions
%%====================================================================

empty({Size, A, B}) when not is_list(A) or not is_list(B) or not is_integer(Size)->
    fail;
empty({0, [], []}) ->
    true;
empty({_Size, A, B})->
    false;
empty(_Not_tuple) ->
    fail.

head({_Size, Non_list1, Non_list2}) when not is_list(Non_list1) or not is_list(Non_list2) -> fail;
head({_Size, [], []}) ->
    nil;
head({_Size, [], Rear}) ->
    lists:last(Rear);
head({_Size, [H|_T], _Rear}) ->
    H;
head(_Bad_parameter) -> fail.


tail({_Size, Non_list1, Non_list2}) when not is_list(Non_list1) or not is_list(Non_list2) -> fail;
tail({_Size, [], []}) -> nil;
tail({_Size, List, []}) -> lists:last(List);
tail({_Size, _Front, [H | _T]}) -> H;
tail(_Bad_parameter) -> fail.


enqueue({_Size, Non_list1, Non_list2}, _) when not is_list(Non_list1) or not is_list(Non_list2) -> fail;
enqueue({0, [], []}, A)->
    {1, [A], []};
enqueue({Size, F_list, L_list}, A) ->
    {Size + 1, F_list, [A] ++ L_list}.

dequeue({_Size, Non_list1, Non_list2}) when not is_list(Non_list1) or not is_list(Non_list2) -> fail;
dequeue({0, [], []}) ->
    {0, [], []};
dequeue({Size, [_H|[]], Rear}) ->
    {Size - 1, lists:reverse(Rear), []};
dequeue({Size, [_H|T], Rear}) ->
    {Size - 1, T, Rear}.

enqueue_front({_, Non_list1, Non_list2}, _A) when not is_list(Non_list1) or not is_list(Non_list2) ->
    fail;
enqueue_front({Size, Front, Rear}, A) ->
    {Size + 1, [A] ++ Front, Rear}.

dequeue_back({0, [], []}) ->
    {0, [], []};
dequeue_back({Size, Front, []}) ->
    [_H | T] = lists:reverse(Front),
    {Size - 1, [], T};
dequeue_back({Size, Front, [_H|T]}) ->
    {Size - 1, Front, T};
dequeue_back(_Bad_parameter) -> fail.

get_size({Size, _Front, _Rear}) ->
    Size.





%%====================================================================
%% Test functions
%%====================================================================

%%% Only include the eunit testing library and functions
%%% in the compiled code if testing is 
%%% being done.
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

empty_test_()->
	[?_assertEqual(true, empty({0, [],[]})),%happy path
	?_assertEqual(false, empty({4, [1, 3], [4, 2]})),%happy path
	?_assertEqual(false, empty({3, ['Hi', 'How are you?'], ['Goodbye']})),%happy path
	?_assertEqual(false, empty({5, [dogs, cats, cows], [pigs, zebras]})),%happy path      
    ?_assertEqual(false, empty({1, [5], []})),
    ?_assertEqual(false, empty({1, [], [4]})),
    %nasty thoughts start here
    ?_assertEqual(fail, empty({1, 2, 3})),
    ?_assertEqual(fail, empty({[2], [5], [6]}))].

head_test_()->
	[?_assertEqual(nil, head({0, [],[]})),%happy path
	?_assertEqual(5, head({2, [],[4,5]})),%happy path
	?_assertEqual(6, head({3, [],[4, 5, 6]})),%happy path
	?_assertEqual(4, head({1, [4], []})),%happy path      
    ?_assertEqual(3, head({5, [3, 4], [4, 7, 2]})),%happy path
    %nasty thoughts start here
    ?_assertEqual(fail, head({24, [3, 4], [2, 7, 8], [1]})),
    ?_assertEqual(fail, head({3, 5, 6})),
    ?_assertEqual(fail, head({5, hello})),
    ?_assertEqual(fail, head("This is a string")),
    ?_assertEqual(fail, head({not_list, []})),
    ?_assertEqual(fail, head({[], not_list}))].


tail_test_()->
	[?_assertEqual(nil, tail({0, [], []})),%happy path
	?_assertEqual(3, tail({3, [1,2,3], []})),%happy path
	?_assertEqual(1, tail({3, [], [1,2,3]})),%happy path
	?_assertEqual(1, tail({6, [4,5,6], [1,2,3]})),%happy path      
    ?_assertEqual(1, tail({4, [4,5,6], [1]})),
    ?_assertEqual(6, tail({1, [6], []})),
    %nasty thoughts start here
    ?_assertEqual(fail, head({10000, [3, 4], [2, 7, 8], [1]})),
    ?_assertEqual(fail, head({3, 5, 6})),
    ?_assertEqual(fail, head({hello})),
    ?_assertEqual(fail, head("This is a string")),
    ?_assertEqual(fail, head({10, not_list, []})),
    ?_assertEqual(fail, head({10, [], not_list}))].

enqueue_test_()->
	[?_assertEqual({1, [1], []}, enqueue({0, [], []}, 1)),%happy path
	?_assertEqual({2, [1], [2]}, enqueue({1, [1], []}, 2)),%happy path
	?_assertEqual({3, [1], [3, 2]}, enqueue({2, [1], [2]}, 3)),%happy path
	?_assertEqual({4, [1], [4, 3, 2]}, enqueue({3, [1], [3, 2]}, 4)),%happy path      
    ?_assertEqual({5, [1], [atom, 4, 3, 2]}, enqueue({4, [1], [4, 3, 2]}, atom)),%happy path  
    %nasty thoughts start here
    ?_assertEqual(fail, enqueue({0, not_list, []}, 5)),
    ?_assertEqual(fail, enqueue({0, [], not_list}, 7))].

dequeue_test_()->
	[?_assertEqual({0, [], []}, dequeue({0, [], []})),%happy path
	?_assertEqual({5, [2,3], [6,5,4]}, dequeue({6, [1,2,3], [6,5,4]})),%happy path
	?_assertEqual({3, [4,5,6], []}, dequeue({4, [3], [6,5,4]})),%happy path
	?_assertEqual({0, [], []}, dequeue({1, [3], []})),%happy path
    %nasty thoughts start here
    ?_assertEqual(fail, dequeue({0, not_list, []})),
    ?_assertEqual(fail, dequeue({0, [], not_list}))].

enqueue_front_test_()->
	[?_assertEqual({1, [1], []}, enqueue_front({0, [], []}, 1)),%happy path
	?_assertEqual({2, [2, 1], []}, enqueue_front({1, [1], []}, 2)),%happy path
	?_assertEqual({3, [3, 2, 1], []}, enqueue_front({2, [2, 1], []}, 3)),%happy path
	?_assertEqual({5, [4, 3, 2, 1], ["hi"]}, enqueue_front({4, [3, 2, 1], ["hi"]}, 4)),%happy path      
    ?_assertEqual({5, [atom, 4, 3, 2, 1], []}, enqueue_front({4, [4, 3, 2, 1], []}, atom))%happy path  
    %nasty thoughts start here
    ].

dequeue_back_test_()->
	[?_assertEqual({5, [2, 5, 6], [3, 6]}, dequeue_back({6, [2, 5, 6], [9, 3, 6]})),%happy path
	?_assertEqual({2, [3], [4]}, dequeue_back({3, [3], [7, 4]})),%happy path
	?_assertEqual({5, [5, 8], [4, 6, 8]}, dequeue_back({6, [5 ,8], [1, 4, 6, 8]})),%happy path
	?_assertEqual({1, [], [2]}, dequeue_back({2, [], [3, 2]})),%happy path      
    ?_assertEqual({0, [], []}, dequeue_back({1, [], [3]})),
    ?_assertEqual({2, [], [2, 1]}, dequeue_back({3, [1,2,3], []})),
    %nasty thoughts start here
    ?_assertEqual(fail, dequeue_back('Hello world')),
    ?_assertEqual(fail, dequeue_back(this_isnt_a_variable)),
    ?_assertEqual(fail, dequeue_back([1, 3, 4]))].

get_size_test()->
    [?_assertEqual(6, get_size({6, [2, 5, 6], [9, 3, 6]}))%happy path
    %nasty thoughts start here
    ].
-endif.