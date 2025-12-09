% ===========================================
% Route and Path Planning in ASP (clingo)
% Same problem as the Prolog version:
% Find a path from a start city to a goal city
% whilst minimizing the total distance.
% ===========================================

% -------------------------------------------
% Cities and roads (undirected graph)
% -------------------------------------------

city(oklahoma_city; dallas; austin; houston;
     tulsa; kansas_city; wichita; denver).

road(oklahoma_city, dallas, 330).
road(dallas, austin, 315).
road(austin, houston, 265).
road(oklahoma_city, tulsa, 170).
road(tulsa, kansas_city, 380).
road(oklahoma_city, wichita, 260).
road(wichita, denver, 520).
road(denver, kansas_city, 850).
road(dallas, houston, 385).

% Undirected edges
edge(X,Y,D) :- road(X,Y,D).
edge(X,Y,D) :- road(Y,X,D).

node(X) :- edge(X,_,_).
node(Y) :- edge(_,Y,_).

% -------------------------------------------
% Start and goal
% -------------------------------------------

start(oklahoma_city).
goal(houston).

% -------------------------------------------
% Guess which edges are in the path
% -------------------------------------------

{ in_path(X,Y) : edge(X,Y,_) }.

% -------------------------------------------
% Degree counts (in- and out-degree of each node)
% -------------------------------------------

in_deg(V,N)  :- node(V), N = #count { U : in_path(U,V) }.
out_deg(V,N) :- node(V), N = #count { W : in_path(V,W) }.

% -------------------------------------------
% Constraints on start, goal, and internal nodes
% -------------------------------------------

% Start: exactly one outgoing, no incoming
:- start(S), in_deg(S,N), N > 0.
:- start(S), out_deg(S,N), N != 1.

% Goal: exactly one incoming, no outgoing
:- goal(G), out_deg(G,N), N > 0.
:- goal(G), in_deg(G,N), N != 1.

% Internal nodes: at most one in and at most one out
:- node(V), not start(V), not goal(V), in_deg(V,N),  N > 1.
:- node(V), not start(V), not goal(V), out_deg(V,N), N > 1.

% Internal nodes: if they are used, in = out
% case: in=1, out=0 (disallowed)
:- node(V), not start(V), not goal(V),
   in_deg(V,N), out_deg(V,M),
   N = 1, M = 0.

% case: in=0, out=1 (disallowed)
:- node(V), not start(V), not goal(V),
   in_deg(V,N), out_deg(V,M),
   N = 0, M = 1.

% -------------------------------------------
% Reachability: everything on the path must be
% reachable from start and goal must be reached.
% -------------------------------------------

reach(S) :- start(S).
reach(Y) :- reach(X), in_path(X,Y).

:- goal(G), not reach(G).

:- in_path(X,_), not reach(X).
:- in_path(_,Y), not reach(Y).

% -------------------------------------------
% Optimization: minimize total distance
% -------------------------------------------

#minimize { D,X,Y : in_path(X,Y), edge(X,Y,D) }.

% -------------------------------------------
% Show only chosen path edges
% -------------------------------------------

#show in_path/2.
