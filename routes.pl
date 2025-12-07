% ===========================================
% Route and Path Planning in Prolog
% -------------------------------------------
% This program models a simple road map and
% can find routes and shortest paths between cities.
% ===========================================

% -------------------------------------------
% Facts: road(CityA, CityB, DistanceInKm).
% These are one-way declarations. We later
% define connected/3 to make roads bidirectional.
% -------------------------------------------

road(oklahoma_city, dallas, 330).
road(dallas, austin, 315).
road(austin, houston, 265).
road(oklahoma_city, tulsa, 170).
road(tulsa, kansas_city, 380).
road(oklahoma_city, wichita, 260).
road(wichita, denver, 520).
road(denver, kansas_city, 850).
road(dallas, houston, 385).

% -------------------------------------------
% connected(CityA, CityB, Distance)
% A road is considered bidirectional.
% -------------------------------------------

connected(A, B, D) :- road(A, B, D).
connected(A, B, D) :- road(B, A, D).

% -------------------------------------------
% path(Start, End, Path, Distance)
% Finds a path from Start to End.
% Path is a list of cities.
% Distance is the total distance in km.
%
% This is the main predicate you will query.
% It uses travel/5 which is recursive.
% -------------------------------------------

path(Start, End, Path, Distance) :-
    travel(Start, End, [Start], RevPath, Distance),
    reverse(RevPath, Path).

% -------------------------------------------
% travel(Current, Destination, VisitedSoFar,
%         FinalPathReversed, TotalDistance)
%
% Recursive definition:
%   Base case: when Current = Destination
%   Recursive case: move to a neighbor city
%   that has not been visited yet.
% -------------------------------------------

% Base case
travel(City, City, Path, Path, 0).

% Recursive case
travel(Current, Destination, Visited, FinalPath, TotalDistance) :-
    connected(Current, Next, StepDistance),
    Next \= Current,
    \+ member(Next, Visited),
    travel(Next, Destination, [Next | Visited], FinalPath, RemainingDistance),
    TotalDistance is StepDistance + RemainingDistance.

% -------------------------------------------
% shortest_path(Start, End, Path, Distance)
%
% Uses setof to collect all possible paths
% and distances, then selects the shortest.
% -------------------------------------------

shortest_path(Start, End, Path, Distance) :-
    setof(Dist-P,
          path(Start, End, P, Dist),
          [Distance-Path | _]).
