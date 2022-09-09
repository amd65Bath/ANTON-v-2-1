
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


%% compose.lp
%%
%% Martin Brain
%% mjb@cs.bath.ac.uk
%% 27/03/08
%%
%% Uses the melodic and harmonic rules to generate valid pieces of music

#hide.

#show mode(K).
#show style(C).
#show part(P).
#show partTime(P,T).
#show partTimeMax(P,TM).

#show choosenNote(P,T,N).
#show rest(P,T).

#show leapBy(P,T,L).
#show stepBy(P,T,S).
#show repeated(P,T).
#show incorrectProgression(P,T).
#show toRest(P,T).
#show fromRest(P,T).

#show chordal(B).
#show chord(T,TR).
#show chordPosition(T,TP).
#show cadence(T,C).

% AD - 08/22

#show form(FRM).
#show setKey(SK).

% AD End


% No errors are allowed
#domain reason(R).
 :- error(P,T,R).
