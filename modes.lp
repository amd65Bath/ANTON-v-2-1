
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


%% modes.lp
%%
%% 29/03/07
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% A description of the various modes/keys the system can use

%% A mode is severn notes from the 12
%% (well, nine notes if it is a minor scale).
%% Must have one chromatic step between top of scale and fundamental.
%% Only pick from valid notes from mode.

%% mode is user defined.

% C major is C, D, E, F, G,  A,  B
% I.E.       1, 3, 5, 6, 8, 10, 12
modeChromaticPosition(1) :- mode(major).
modeChromaticPosition(3) :- mode(major).
modeChromaticPosition(5) :- mode(major).
modeChromaticPosition(6) :- mode(major).
modeChromaticPosition(8) :- mode(major).
modeChromaticPosition(10) :- mode(major).
modeChromaticPosition(12) :- mode(major).
lastChromaticPositionInMode(12) :- mode(major).

% C minor downwards is C, D, E^{\flat}, F, G, A^{\flat}, B^{\flat}, C
% I.E.                 1, 3, 4,         6, 8, 9,         11

% C minor upwards is C, D, E^{\flat}, F, G,  A,  B, C
% I.E.               1, 3, 4,         6, 8, 10, 12
modeChromaticPosition(1) :- mode(minor).
modeChromaticPosition(3) :- mode(minor).
modeChromaticPosition(4) :- mode(minor).
modeChromaticPosition(6) :- mode(minor).
modeChromaticPosition(8) :- mode(minor).
modeChromaticPosition(9) :- mode(minor).
modeChromaticPosition(10) :- mode(minor).
modeChromaticPosition(11) :- mode(minor).
modeChromaticPosition(12) :- mode(minor).
lastChromaticPositionInMode(11) :- mode(minor).
lastChromaticPositionInMode(12) :- mode(minor).


% The last two notes of a minor scale are dependant on direction
% upwards the last two are 10,12
% downwards the last two are 9,11
% You must be both progressing in the correct direction and continuing to
% progress in that directsion
#const err_imm="Invalid move in a minor key".
reason(err_imm).
error(P,T,err_imm) :- choosenChromatic(P,T,9), upAt(P,T - 1),
                      mode(minor), partTime(P,T - 1).
error(P,T,err_imm) :- choosenChromatic(P,T,11), upAt(P,T - 1),
                      mode(minor), partTime(P,T - 1).
error(P,T,err_imm) :- choosenChromatic(P,T,10), downAt(P,T - 1),
                      mode(minor), partTime(P,T - 1).
error(P,T,err_imm) :- choosenChromatic(P,T,12), downAt(P,T - 1),
                      mode(minor), partTime(P,T - 1).

error(P,T,err_imm) :- choosenChromatic(P,T,11), upAt(P,T), mode(minor).
error(P,T,err_imm) :- choosenChromatic(P,T,10), downAt(P,T), mode(minor).
error(P,T,err_imm) :- choosenChromatic(P,T,12), downAt(P,T), mode(minor).

%% 9 is an exception, you are allowed to move up, but not to 10 or 12
%error(P,T,err_imm) :- choosenChromatic(P,T,9), upAt(P,T), mode(minor).

error(P,T,err_imm) :- choosenChromatic(P,T,9), choosenChromatic(P,T+1,10), mode(minor).
error(P,T,err_imm) :- choosenChromatic(P,T,9), choosenChromatic(P,T+1,12), mode(minor).



%% Note that in some contexts C B C may be acceptable.
%%  B^{\flat} C B C is not one of them.


% Additionally, there are some restrictions
% Can't go from position (12,4), (10,4), (4,12), (4,10)
#const err_ijm="Invalid jump in a minor modeChromaticPosition".
reason(err_ijm).
error(P,T,err_ijm) :- choosenChromatic(P,T,12), choosenChromatic(P,T+1,4), mode(minor).
error(P,T,err_ijm) :- choosenChromatic(P,T,10), choosenChromatic(P,T+1,4), mode(minor).
error(P,T,err_ijm) :- choosenChromatic(P,T,4), choosenChromatic(P,T+1,10), mode(minor).
error(P,T,err_ijm) :- choosenChromatic(P,T,4), choosenChromatic(P,T+1,12), mode(minor).


% JPff suggests that B must also always resolve to C
#const err_mmmr="Problem with minor mode melodic resolution".
reason(err_mmmr).
error(P,T,err_mmmr) :- choosenChromatic(P,T,12), not choosenChromatic(P,T+1,1),
                       mode(minor), partTime(P,T+1).

% There are several restrictions on harmonic combinations in minor mode
% (12,9) = (12,21) and (12,4) = (12,16) aren't allowed
#const err_imh="Invalid minor harmonic combination".
reason(err_imh).
error(P1,T,err_imh) :- choosenChromatic(P1,T,12), choosenChromatic(P2,T,9), P1 < P2.
error(P1,T,err_imh) :- choosenChromatic(P1,T,9), choosenChromatic(P2,T,12), P1 < P2.
error(P1,T,err_imh) :- choosenChromatic(P1,T,12), choosenChromatic(P2,T,4), P1 < P2.
error(P1,T,err_imh) :- choosenChromatic(P1,T,4), choosenChromatic(P2,T,12), P1 < P2.



% Dorian - white notes starting from D
% I.E.       1, 3, 4, 6, 8, 10, 11
modeChromaticPosition(1) :- mode(dorian).
modeChromaticPosition(3) :- mode(dorian).
modeChromaticPosition(4) :- mode(dorian).
modeChromaticPosition(6) :- mode(dorian).
modeChromaticPosition(8) :- mode(dorian).
modeChromaticPosition(10) :- mode(dorian).
modeChromaticPosition(11) :- mode(dorian).
lastChromaticPositionInMode(11) :- mode(dorian).


% Phrygian - white notes starting from E
% 1, 2, 4, 6, 8, 9, 11
modeChromaticPosition(1) :- mode(phrygian).
modeChromaticPosition(2) :- mode(phrygian).
modeChromaticPosition(4) :- mode(phrygian).
modeChromaticPosition(6) :- mode(phrygian).
modeChromaticPosition(8) :- mode(phrygian).
modeChromaticPosition(9) :- mode(phrygian).
modeChromaticPosition(11) :- mode(phrygian).
lastChromaticPositionInMode(11) :- mode(phrygian).

% Lydian F - F
% 1, 3, 5, 7, 8, 10, 12
modeChromaticPosition(1) :- mode(lydian).
modeChromaticPosition(3) :- mode(lydian).
modeChromaticPosition(5) :- mode(lydian).
modeChromaticPosition(7) :- mode(lydian).
modeChromaticPosition(8) :- mode(lydian).
modeChromaticPosition(10) :- mode(lydian).
modeChromaticPosition(12) :- mode(lydian).
lastChromaticPositionInMode(12) :- mode(lydian).


% Mixolydian G - G
% 1, 3, 5, 6, 8, 10, 11
modeChromaticPosition(1) :- mode(mixolydian).
modeChromaticPosition(3) :- mode(mixolydian).
modeChromaticPosition(5) :- mode(mixolydian).
modeChromaticPosition(6) :- mode(mixolydian).
modeChromaticPosition(8) :- mode(mixolydian).
modeChromaticPosition(10) :- mode(mixolydian).
modeChromaticPosition(11) :- mode(mixolydian).
lastChromaticPositionInMode(11) :- mode(mixolydian).

%% Every choosen note must be in the mode
#const err_nik="Choosen note not in mode".
reason(err_nik).
error(P,T,err_nik) :- choosenChromatic(P,T,C), not modeChromaticPosition(C).

