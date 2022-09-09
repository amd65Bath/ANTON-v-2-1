
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


%% monorhythmic.lp
%%
%% 02/02/10
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% If the rhythm option is not used, this gives default definitions
%% of rhythmic concepts.


%% Parts overlap if their timesteps match
noteOverlap(P1,T,P2,T) :- not rhythm(1), P1 != P2,
                          partTime(P1,T), partTime(P2,T).

%% Every time step is a possible chord
possibleChord(PC) :- partTime(P,PC).

%% Thus the progression is obvious
nextPossibleChord(PC,PC+1) :- possibleChord(PC), possibleChord(PC+1).
lastPossibleChord(PC) :- not possibleChord(PC+1), possibleChord(PC).

%% With the corresponding notes in each chord
noteInPossibleChord(P,PC,PC) :- partTime(P,PC), possibleChord(PC).


