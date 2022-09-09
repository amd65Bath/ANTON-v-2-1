
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


%% solo.lp
%%
%% 29/03/07
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Rules for composing / analysising melodies for a single instrument

%% This is a solo
style(solo).

%% There is only one part...
part(1).

%% ... and it is melodic
melodicPart(1).

%% We need a range of up to 2 octaves (24 steps), thus need 24 notes above and below the start / end
#const soloBottomNote=1.
#const soloTopNote=49.
note(soloBottomNote..soloTopNote).
bottomNote(soloBottomNote).
topNote(soloTopNote).

% %% Start on the (middle) fundamental, a 5th above or a 5th below
% %% (5 chromatic steps down or 7 up) ...
% #const err_isn="Incorrect starting note".
% reason(err_isn).
% error(1,1,err_isn) :- not choosenNote(1,1,20), not choosenNote(1,1,25),
%                       not choosenNote(1,1,32).

% Melody starts inbetween g below "middle C"...
#const err_isn="Incorrect starting note".
reason(err_isn).
error(1,1,err_isn) :- choosenNote(1,1,SN), SN < 20.
% error(2,1,err_isn) :- choosenNote(2,1,C).

% and the b above "middle C".
#const err_isnn="Incorrect starting note".
reason(err_isnn).
error(1,1,err_isnn) :- choosenNote(1,1,SN), SN > 36.
% error(2,1,err_isn) :- choosenNote(2,1,C).

% First note to be the Tonic or Dominant 
#const err_fmnnat = "First melody note not a Tonic".
reason(err_fmnnat).
error(1,1,err_fmnnat) :- not choosenChromatic(1,1,1), not choosenChromatic(1,1,8).

%% ... and finish on the fundamental
#const err_snff="Must finish on the fundamental".
reason(err_snff).
error(1,TM,err_snff) :- choosenNote(1,TM,N), chromatic(N,C), C != 1,
                       partTimeMax(1,TM).

%% No rests
#const err_nrfw="No rest for the wicked".
reason(err_nrfw).
error(P,T,err_nrfw) :- rest(P,T).


#include "rules/notes.lp"
#include "rules/modes.lp"
#include "rules/progression.lp"
#include "rules/melody.lp"
%% Harmonic rules are not needed for one part
%% Not chordal for the obvious reason

