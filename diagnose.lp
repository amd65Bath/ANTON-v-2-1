
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


%% diagnose.lp
%%
%% Martin Brain
%% mjb@cs.bath.ac.uk
%% 27/03/08
%%
%% Take a piece of music and identifies which (if any) rules it breaks.

#hide.
#show error(P,T,R).


% Must have at least one error
#domain reason(R).
errorFound :- error(P,T,R).
 :- not errorFound.

% To get a unique solution, remove models with 
% incorrect progression if correct progression is possible
possibleMove(M) :- stepSize(M).
possibleMove(M) :- leapSize(M).
possibleMove(0).
 :- choosenNote(P,T,N), choosenNote(P,T+1,N+M),
    incorrectProgression(P,T), possibleMove(M).

% Likewise with rests
 :- rest(P,T+1), incorrectProgression(P,T).
