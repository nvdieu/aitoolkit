:- module(aitool, 
    [
        best_first_search/4,
        greedy_search/4,
        aStar/4, 
        csp/3,
        truth_table/2,
        to_cnf/2,
        prove_resolution/2,
        printPath/2
    ]).

:- use_module(library(lists)).

% 1. Định nghĩa toán tử (Precedence: neg > and > or > imp)
:- op(400, fy, neg).   % ¬
:- op(500, yfx, and).  % ∧
:- op(600, yfx, or).   % ∨
:- op(700, yfx, imp).  % ⇒

% 2. Đẩy toán tử ra GLOBAL để môi trường hiểu được cú pháp
:- initialization(op(400, fy, neg)).
:- initialization(op(500, yfx, and)).
:- initialization(op(600, yfx, or)).
:- initialization(op(700, yfx, imp)).

% -----------------------------------------------------------------
% A. Cac thuat toan tim kiem 
% -----------------------------------------------------------------

best_first_search(Start, Goal, Path, TotalCost) :-
    bfs_search([[0, Start, [Start]]], Goal, Path, TotalCost).

bfs_search([[H, Goal, PathReversed] | _], Goal, Path, H) :-
    reverse(PathReversed, Path), !.

bfs_search([[H, Current, PathSoFar] | Rest], Goal, Path, TotalCost) :-
    findall(
        [H_next, Next, [Next | PathSoFar]],
        (
            edge(Current, Next, StepCost),
            \+ member(Next, PathSoFar),
            H_next is H + StepCost
        ),
        NextNodes
    ),
    append(Rest, NextNodes, NewQueue),
    sort(NewQueue, SortedQueue),
    bfs_search(SortedQueue, Goal, Path, TotalCost).
% GREEDY SEARCH - PHIÊN BẢN ÉP DETERMINISTIC MẠNH
greedy_search(Start, Goal, Path, TotalCost) :-
    h(Start, H),
    InitialState = [[H, Start, [Start]]],
    once(greedy_engine(InitialState, Goal, PathRev)),   % once ở đây là chìa khóa
    reverse(PathRev, Path),
    calculate_path_cost(Path, TotalCost).

% 1. Tìm thấy Goal → succeed và cắt hết
greedy_engine([[_, Goal, PathRev] | _], Goal, PathRev) :- !.

% 2. Mở rộng node
greedy_engine([[_, Current, PathSoFar] | Rest], Goal, FinalPath) :-
    findall([Hn, Next, [Next | PathSoFar]],
            (   edge(Current, Next, _),
                \+ memberchk(Next, PathSoFar),
                h(Next, Hn)
            ),
            Children),

    append(Children, Rest, NewOpen),
    sort(0, @=<, NewOpen, SortedOpen),

    SortedOpen = [[_, BestNext, BestPath] | Remaining],   % fail nếu rỗng

    !,   % commit chọn BestNext, không backtrack
    greedy_engine([[_, BestNext, BestPath] | Remaining], Goal, FinalPath).

% 3. Không còn đường đi
greedy_engine(_, _, _) :- !, fail.

calculate_path_cost([_], 0) :- !.
calculate_path_cost([A, B | T], Cost) :-
    edge(A, B, C),
    calculate_path_cost([B | T], Rest),
    Cost is C + Rest.


aStar(Start, Goal, Path, TotalCost) :-
    h(Start, H),
    a_star_search([[H, 0, Start, [Start]]], Goal, Path, TotalCost).

a_star_search([[_, G, Goal, PathReversed] | _], Goal, Path, G) :-
    reverse(PathReversed, Path), !.

a_star_search([[_, G, Current, PathSoFar] | Rest], Goal, Path, TotalCost) :-
    findall(
        [F_next, G_next, Next, [Next | PathSoFar]],
        (
            edge(Current, Next, StepCost),
            \+ member(Next, PathSoFar),
            G_next is G + StepCost,
            h(Next, H_next),
            F_next is G_next + H_next
        ),
        NextNodes
    ),
    append(Rest, NextNodes, NewQueue),
    sort(NewQueue, SortedQueue),
    a_star_search(SortedQueue, Goal, Path, TotalCost).

printPath(Path, Cost) :-
    format('~n--- SEARCH COMPLETED ---~n'),
    format('Optimal Path: ~w~n', [Path]),
    format('Total Cost  : ~w~n', [Cost]).

% -----------------------------------------------------------------
% B. CSP - Constraint Satisfaction Problems
% -----------------------------------------------------------------

csp(Variables, Domain, ConstraintPredicate) :-
    assign_all(Variables, Domain),
    call(ConstraintPredicate, Variables).

assign_all([], _).
assign_all([Var|Rest], Domain) :-
    member(Var, Domain),
    assign_all(Rest, Domain).

% -----------------------------------------------------------------
% C. Logic menh de - Bang chan tri
% -----------------------------------------------------------------

truth_table(Expr, Vars) :-
    format('~nTable for: ~w~n', [Expr]),
    foreach(member(V, Vars), format('~w     | ', [V])),
    format('Result~n'),
    format('~`-t~32|~n'),
    findall(Res, (
        generate_assign(Vars, Assigns),
        (eval_logic(Expr, Assigns) -> Res = true ; Res = false),
        foreach(member(_-Val, Assigns), format('~w  | ', [Val])),
        format('~w~n', [Res])
    ), Results),
    analyze_logic(Results).

eval_logic(true, _) :- !.
eval_logic(false, _) :- !, fail.
eval_logic(V, Assigns) :- atom(V), !, member(V-true, Assigns).
eval_logic(neg A, Assigns) :- \+ eval_logic(A, Assigns).
eval_logic(A and B, Assigns) :- eval_logic(A, Assigns), eval_logic(B, Assigns).
eval_logic(A or B, Assigns) :- eval_logic(A, Assigns) ; eval_logic(B, Assigns).
eval_logic(A imp B, Assigns) :- (eval_logic(A, Assigns) -> eval_logic(B, Assigns) ; true).

generate_assign([], []).
generate_assign([V|Vs], [V-Val|Rest]) :-
    member(Val, [true, false]),
    generate_assign(Vs, Rest).

count_trues([], 0).
count_trues([true|T], N) :- count_trues(T, N1), N is N1 + 1.
count_trues([false|T], N) :- count_trues(T, N).

analyze_logic(Results) :-
    count_trues(Results, TCount),
    length(Results, Total),
    FCount is Total - TCount,
    format('~nResult: ~d True, ~d False out of ~d total.~n', [TCount, FCount, Total]),
    (   FCount =:= 0 -> writeln('Status: VALID (Tautology)')
    ;   TCount > 0   -> writeln('Status: SATISFIABLE')
    ;   writeln('Status: UNSATISFIABLE (Contradiction)')
    ).

% -----------------------------------------------------------------
% D. Logic menh de - Bien doi CNF
% -----------------------------------------------------------------

to_cnf(Expr, CNF) :-
    eliminate_imp(Expr, E1),
    move_neg_in(E1, E2),
    distribute(E2, CNF).

eliminate_imp(V, V) :- atom(V), !.
eliminate_imp(neg A, neg A1) :- eliminate_imp(A, A1).
eliminate_imp(A and B, A1 and B1) :- eliminate_imp(A, A1), eliminate_imp(B, B1).
eliminate_imp(A or B, A1 or B1) :- eliminate_imp(A, A1), eliminate_imp(B, B1).
eliminate_imp(A imp B, (neg A1) or B1) :- eliminate_imp(A, A1), eliminate_imp(B, B1).

move_neg_in(neg (A and B), (A1 or B1)) :- !, move_neg_in(neg A, A1), move_neg_in(neg B, B1).
move_neg_in(neg (A or B), (A1 and B1)) :- !, move_neg_in(neg A, A1), move_neg_in(neg B, B1).
move_neg_in(neg (neg A), A1) :- !, move_neg_in(A, A1).
move_neg_in(neg A, neg A) :- atom(A), !.
move_neg_in(A and B, A1 and B1) :- !, move_neg_in(A, A1), move_neg_in(B, B1).
move_neg_in(A or B, A1 or B1) :- !, move_neg_in(A, A1), move_neg_in(B, B1).
move_neg_in(V, V) :- atom(V).

distribute(A and B, A1 and B1) :- !, distribute(A, A1), distribute(B, B1).
distribute(A or (B and C), (A1 or B1) and (A1 or C1)) :- !, distribute(A, A1), distribute(B, B1), distribute(C, C1).
distribute((B and C) or A, (B1 or A1) and (C1 or A1)) :- !, distribute(A, A1), distribute(B, B1), distribute(C, C1).
distribute(A or B, Result) :- 
    distribute(A, A1), distribute(B, B1),
    ( (A1 = (_ and _) ; B1 = (_ and _)) 
    -> distribute(A1 or B1, Result) 
    ;  Result = (A1 or B1) ).
distribute(V, V).

% -----------------------------------------------------------------
% E. Chung minh bang phuong phap resolution
% -----------------------------------------------------------------

prove_resolution(KB, Goal) :-
    format('~n--- Starting Resolution Proof ---~n'),
    NegGoal = neg(Goal),
    
    format('Step 1: Converting KB and ¬Goal to CNF...~n'),
    to_cnf(KB, KBCNF),
    to_cnf(NegGoal, GoalCNF),
    
    format('Step 2: Extracting Clauses...~n'),
    expr_to_clauses(KBCNF and GoalCNF, Clauses),
    list_to_set(Clauses, UniqueClauses),
    format('Initial Clauses: ~w~n', [UniqueClauses]),
    
    format('Step 3: Searching for Contradiction...~n'),
    (   resolve_all(UniqueClauses, ProofSteps)
    ->  format('~nSUCCESS: Empty Clause [] derived!~n'),
        format('The entailment (KB |= Goal) is PROVEN.~n'),
        format('Proof Steps:~n'),
        print_steps(ProofSteps)
    ;   format('~nFAILURE: No contradiction found. Goal cannot be proven.~n')
    ).

expr_to_clauses(A and B, Clauses) :- !,
    expr_to_clauses(A, C1),
    expr_to_clauses(B, C2),
    append(C1, C2, Clauses).
expr_to_clauses(Expr, [Clause]) :- 
    clause_to_list(Expr, Clause).

clause_to_list(A or B, List) :- !,
    clause_to_list(A, L1),
    clause_to_list(B, L2),
    append(L1, L2, List).
clause_to_list(Literal, [Literal]).

resolve_all(Clauses, []) :- member([], Clauses), !.
resolve_all(Clauses, [step(C1, C2, Res)|Steps]) :-
    member(C1, Clauses),
    member(C2, Clauses),
    C1 @< C2,
    resolve_literals(C1, C2, Res),
    \+ member(Res, Clauses),
    (   Res == [] 
    ->  Steps = [] 
    ;   resolve_all([Res|Clauses], Steps)
    ).

resolve_literals(C1, C2, Res) :-
    member(L1, C1),
    complement_of(L1, L2),
    member(L2, C2),
    delete(C1, L1, R1),
    delete(C2, L2, R2),
    append(R1, R2, Temp),
    list_to_set(Temp, Res).

complement_of(neg X, X) :- !.
complement_of(X, neg X).

print_steps([]).
print_steps([step(C1, C2, Res)|T]) :-
    format('  * ~w  Resolution with  ~w  ==>  ~w~n', [C1, C2, Res]),
    print_steps(T).