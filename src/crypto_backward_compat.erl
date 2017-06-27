%% Erlang/OTP 20 removed mpint/1 (it was marked as deprecated) and this is a temporary solution

-module(crypto_backward_compat).

-export([mpint/1]).

%% large integer in a binary with 32bit length
%% MP representaion  (SSH2)
mpint(X) when X < 0 ->
    case X of
	-1 ->
	    <<0,0,0,1,16#ff>>;
       _ ->
	    mpint_neg(X,0,[])
    end;
mpint(X) ->
    case X of
	0 ->
	    <<0,0,0,0>>;
	_ ->
	    mpint_pos(X,0,[])
    end.

-define(UINT32(X),   X:32/unsigned-big-integer).

mpint_neg(-1,I,Ds=[MSB|_]) ->
    if MSB band 16#80 =/= 16#80 ->
	    <<?UINT32((I+1)), (list_to_binary([255|Ds]))/binary>>;
       true ->
	    (<<?UINT32(I), (list_to_binary(Ds))/binary>>)
    end;
mpint_neg(X,I,Ds)  ->
    mpint_neg(X bsr 8,I+1,[(X band 255)|Ds]).

mpint_pos(0,I,Ds=[MSB|_]) ->
    if MSB band 16#80 == 16#80 ->
	    <<?UINT32((I+1)), (list_to_binary([0|Ds]))/binary>>;
       true ->
	    (<<?UINT32(I), (list_to_binary(Ds))/binary>>)
    end;
mpint_pos(X,I,Ds) ->
    mpint_pos(X bsr 8,I+1,[(X band 255)|Ds]).
