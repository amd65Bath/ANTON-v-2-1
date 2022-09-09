
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


%% duet.lp
%%
%% 29/03/07
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Rules for composing / analysising melodies for a duet

%% This is a duet
style(duet).

%% There are two parts
part(1..2).

%% The top part plays the melody
melodicPart(1).

%% We need a range of up to 2 octaves (24 steps) for each part,
%% thus need 24 notes above and below the lowest / highest start
#const duetBottomNote=1.
#const duetTopNote=61.
note(duetBottomNote..duetTopNote).
bottomNote(duetBottomNote).
topNote(duetTopNote).

% %% Either start on the same note or start an octave apart
% #const err_isn="Incorrect starting note".
% reason(err_isn).
% error(1,1,err_isn) :- not choosenNote(1,1,25), not choosenNote(1,1,37).
% error(2,1,err_isn) :- not choosenNote(2,1,25).

% AD - 08/22

% Melody starts inbetween "middle C" and the octave above.
#const err_isn="Incorrect starting note".
reason(err_isn).
error(1,1,err_isn) :- choosenNote(1,1,SN), SN < 25.
% error(2,1,err_isn) :- choosenNote(2,1,C).

% Melody starts inbetween "middle C" and the octave above.
#const err_isnn="Incorrect starting note".
reason(err_isnn).
error(1,1,err_isnn) :- choosenNote(1,1,SN), SN > 49.
% error(2,1,err_isn) :- choosenNote(2,1,C).

% Accompanying part starts on the same note as melody or an octave below
#const err_ishn="Incorrect starting harmonising note".
reason(err_ishn).
error(2,1,err_ishn) :- not choosenNote(2,1,SN), not choosenNote(2,1,SN-12), choosenNote(1,1,SN).

% First note to be Tonic
#const err_fmnnat = "First melody note not a Tonic".
reason(err_fmnnat).
error(1,1,err_fmnnat) :- not choosenChromatic(1,1,1).

%% AD End

%% Both finish on the fundamental
%% (As the range between parts is limited this is either the same note or exactly one octave apart)
#const err_dnff="Must finish on the fundamental".
reason(err_dnff).
error(P,TM,err_dnff) :- choosenNote(P,TM,N), chromatic(N,C), C != 1,
                        partTimeMax(P,TM).

%% No rests
#const err_nrfw="No rest for the wicked".
reason(err_nrfw).
error(P,T,err_nrfw) :- rest(P,T).


#include "rules/notes.lp"
#include "rules/modes.lp"
#include "rules/progression.lp"
#include "rules/melody.lp"
#include "rules/harmony.lp"
%% Not chordal for the obvious reason



