
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


%% trio.lp
%%
%% 21/03/07
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Rules for composing / analysising melodies for a trio of instrument

%% This is a trio
style(trio).

%% There are three parts
part(1..3).

%% The top part plays the melody
melodicPart(1).

%% For chords we need to know the lowest part
lowestPart(3).

%% We need a range of up to 2 octaves (24 steps) for each part,
%% thus need 24 notes above and below the lowest / highest start
#const trioBottomNote=1.
#const trioTopNote=61.
note(trioBottomNote..trioTopNote).
bottomNote(trioBottomNote).
topNote(trioTopNote).


% %% Starting positions are 1 - 5 - 1
% #const err_isn="Incorrect starting note".
% reason(err_isn).
% error(1,1,err_isn) :- not choosenNote(1,1,37).
% error(2,1,err_isn) :- not choosenNote(2,1,32).
% error(3,1,err_isn) :- not choosenNote(3,1,25).

% AD - 08/22

% Melody starts on the tonic in the octave above the C an octave higher than "middle C"
#const err_isnl="Incorrect starting note (too low)".
reason(err_isnl).
error(1,1,err_isnl) :- choosenNote(1,1,SN), SN < 37.

% Melody starts inbetween "middle C" and the octave above.
#const err_isnh="Incorrect starting note (too high)".
reason(err_isnh).
error(1,1,err_isnh) :- choosenNote(1,1,SN), SN > 48.

% Accompanying parts start on the dominant and tonic below the melody respectively
#const err_ishn="Incorrect starting harmonising note".
reason(err_ishn).
error(2,1,err_ishn) :- not choosenNote(2,1,SN-5), choosenNote(1,1,SN).
error(3,1,err_ishn) :- not choosenNote(3,1,SN-12), choosenNote(1,1,SN).

% First notes to be Tonic, Dominant and Tonic for respective parts
#const err_fmnnat = "First melody note not a Tonic".
reason(err_fmnnat).
error(1,1,err_fmnnat) :- not choosenChromatic(1,1,1).
error(2,1,err_fmnnat) :- not choosenChromatic(2,1,8).
error(3,1,err_fmnnat) :- not choosenChromatic(3,1,1).

% AD End

%% No rests
#const err_nrfw="No rest for the wicked".
reason(err_nrfw).
error(P,T,err_nrfw) :- rest(P,T).

%% With three or more parts allow intervals of a major fourth
%% (5 semitones) between parts
validInterval(5).

#include "rules/notes.lp"
#include "rules/modes.lp"
#include "rules/progression.lp"
#include "rules/melody.lp"
#include "rules/harmony.lp"
#include "rules/chord.lp"
