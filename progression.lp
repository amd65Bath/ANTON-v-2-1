
%% Copyright (C) 2010 Martin Brain and Georg Boenn
%% 
%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public License
%% as published by the Free Software Foundation; either version 2
%% of the License, or (at your option) any later version.
%% 
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%% 
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
%% 02110-1301, USA.


%% progression.lp
%%
%% 03/11/06
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Rules for the progression of all parts, melodic and harmonic

%% Note selection
%% may move by any reasonable amount (i.e. not just step)
%% are allowed the same note repeatedly


%% The number of parts is given by the style
#domain part(P).
#domain part(P1).
#domain part(P2).


%% Time steps are given independantly for each part
partTime(P,1..TM) :- partTimeMax(P,TM).

%% Each part can only play one note at a given time
%% This is needed so that partial pieces can be supplied.
 :- 2 { choosenNote(P,T,NN) : note(NN), rest(P,T) }, partTime(P,T).

%% At every time step the note may change
%% It changes by stepping (moving one note in the scale)
%% or leaping (moving more than one note)
%% These can either be upwards or downwards
1 { changes(P,T), repeated(P,T),
    toRest(P,T), fromRest(P,T),
    incorrectProgression(P,T) } 1 :- partTime(P,T), partTimeMax(P,TM), T != TM.
1 { stepAt(P,T), leapAt(P,T) } 1 :- changes(P,T), partTimeMax(P,TM), T != TM.
1 { downAt(P,T),   upAt(P,T) } 1 :- changes(P,T), partTimeMax(P,TM), T != TM.

stepDown(P,T) :- stepAt(P,T), downAt(P,T).
stepUp(P,T)   :- stepAt(P,T),   upAt(P,T).

leapDown(P,T) :- leapAt(P,T), downAt(P,T).
leapUp(P,T)   :- leapAt(P,T),   upAt(P,T).

#const err_ip="Incorrect progression".
reason(err_ip).
error(P,T,err_ip) :- incorrectProgression(P,T).

%% We start by moving from rest
fromRest(P,0).

%% Sanity checks so on the transition to and from rests
%% These are constraints rather than errors as fromRest / toRest
%% aren't part of the example format.
 :- rest(P,T), not repeated(P,T), not fromRest(P,T).
 :- fromRest(P,T), not rest(P,T), T > 0.


%% A step is to the next note of the mode
%% This assumes that for every given mode either N+1 or N+2 is in the mode
%% - but not both
%% Equivalently either N-1 or N-2 is in the mode
stepSize(2).
stepSize(1).
stepSize(-1).
stepSize(-2).
#domain stepSize(S).
#domain stepSize(S1).
#domain stepSize(S2).
#domain stepSize(S3).

%% If we step, we must pick an amount to step by
1 { stepBy(P,T,SS) : stepSize(SS) : SS < 0 } 1 :- stepDown(P,T).
1 { stepBy(P,T,SS) : stepSize(SS) : SS > 0 } 1 :- stepUp(P,T).
% (note that because of the structure of the mode
%  there should only be one option for each of these)

%% Leaps can only use consonant intervals
%% Connected - no jumps of over 12 chromatic steps
%% nor are dissonant leaps allowed (1), (6), (8), (9), (10), (11)
leapSize(CI) :- CI != 0.
leapSize(-CI) :- CI != 0.
leapSize(12).
leapSize(-12).
#domain leapSize(L).
#domain leapSize(L1).
#domain leapSize(L2).
#domain leapSize(L3).

%% If we leap then we must leap by a given amount
1 { leapBy(P,T,LS) : leapSize(LS) : LS < 0 } 1 :- leapDown(P,T).
1 { leapBy(P,T,LS) : leapSize(LS) : LS > 0 } 1 :- leapUp(P,T).


%% Make it so
choosenNote(P,T + 1,N + S) :- choosenNote(P,T,N), stepAt(P,T),
                              stepBy(P,T,S), note(N + S).
choosenNote(P,T + 1,N + L) :- choosenNote(P,T,N), leapAt(P,T),
                              leapBy(P,T,L), note(N + L).
choosenNote(P,T + 1,N) :- choosenNote(P,T,N), repeated(P,T).

rest(P,T + 1) :- rest(P,T), repeated(P,T).
rest(P,T + 1) :- toRest(P,T).
1 { choosenNote(P,T + 1,NN) : note(NN) } 1 :- fromRest(P,T).
1 { choosenNote(P,1,NN)     : note(NN) } 1 :- fromRest(P,0).

%% In some cases we only care about the chromatic position of a part, not the note
choosenChromatic(P,T,C) :- choosenNote(P,T,N), chromatic(N,C).


%% Notes must be within the given range
%% Note this is not an 'error' as it can only be given by the program
%% not the user (assuming piece inputs are just a set of notes)
%% plus having notes 'outside' the usual range cause problems
%% with multiple simmultaneous notes.
 :- choosenNote(P,T,N), stepAt(P,T), stepBy(P,T,S), not note(N + S).
 :- choosenNote(P,T,N), leapAt(P,T), leapBy(P,T,L), not note(N + L).


%% Work out the range of the part
notePlayed(P,N) :- choosenNote(P,T,N).

highestNote(P,N) :- notePlayed(P,N), not lowerThanHighestNote(P,N).
lowerThanHighestNote(P,N-1) :- highestNote(P,N).
lowerThanHighestNote(P,N-1) :- lowerThanHighestNote(P,N).

lowestNote(P,N) :- notePlayed(P,N), not higherThanLowestNote(P,N).
higherThanLowestNote(P,N+1) :- lowestNote(P,N).
higherThanLowestNote(P,N+1) :- higherThanLowestNote(P,N).


%% Total range must not be more than 2 octaves
#const err_ro="Range over two octaves".
reason(err_ro).
error(P,TM,err_ro) :- lowestNote(P,N1), highestNote(P,N2), N1 + 24 < N2, partTimeMax(P,TM).


