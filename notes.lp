
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


%% notes.lp
%%
%% 13/05/09
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% General background rules on notes and intervals

%% Model in chromatic steps - 12 notes in an octave
%% needed for major and minor
chromaticPosition(1..12).
#domain chromaticPosition(C).
#domain chromaticPosition(C1).
#domain chromaticPosition(C2).

%% The correspondance between number and note name is given by the key
%% and is applied at the synthesis step and is thus not modelled.
%% The number of notes depends on the style of the piece
#domain note(N).
#domain note(N1).
#domain note(N2).

% %% Map notes to their chromatic position
% chromatic(N,N mod 12) :- (N mod 12) != 0.
% chromatic(N,12) :- (N mod 12) == 0.

% AD - 08/22

%% Map notes to their chromatic position
chromatic(N + SK,N mod 12) :- (N mod 12) != 0, setKey(SK).
chromatic(N + SK,12) :- (N mod 12) == 0, setKey(SK).

% AD End

%% Intervals between notes are refered to as consonant if they are of a given distance:
%% unison (0), minor third (3), major third (4), fourth (5), perfect fifth (7) (mod 12)
consonantInterval(0).
consonantInterval(3).
consonantInterval(4).
consonantInterval(5).
consonantInterval(7).
#domain consonantInterval(CI).

%% Pairs of chromatic positions that are consonant
consonant(C1,C2) :- chromatic(N,C1), chromatic(N + CI, C2).

%% The interval between two notes
%% Note there are two possible definitions of modulo distance
%% Thus it is important that the first chromatic position is
%% that of the higher note.
chromaticInterval(C1,C2,C1 - C2) :- C1 > C2.
chromaticInterval(C1,C2,(C1 + 12) - C2) :- C1 < C2.
chromaticInterval(C,C,0).

possibleChromaticInterval(0..11).
#domain possibleChromaticInterval(D).

