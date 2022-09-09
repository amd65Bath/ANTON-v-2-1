
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


%% melody.lp
%%
%% 03/11/06
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% The rules for melodic parts


%% These rules only apply to melodic parts
#domain melodicPart(MP).

%% Melodic parts are not allowed to repeat notes
#const err_nrmp="No repeated notes in melodic parts".
reason(err_nrmp).
error(MP,T,err_nrmp) :- repeated(MP,T).


%% Last interval is major or minor second (respectively two or one step)
%% I.E. It cannot be a leap
#const err_lins="Last interval is not a second".
reason(err_lins).
error(MP,TM-1,err_lins) :- leapAt(MP,TM-1), partTimeMax(MP,TM).


%% A leap of an octave is only allowed from the fundamental.
#const err_olnf="Leap of an octave from a note other than the fundamental".
reason(err_olnf).
error(MP,T,err_olnf) :- leapBy(MP,T,12), not choosenChromatic(MP,T,1).
error(MP,T,err_olnf) :- leapBy(MP,T,-12), not choosenChromatic(MP,T,1).


%% No two consecutive jumps that `cancel'
#const err_cl="Leaps cancel".
reason(err_cl).
error(MP,T,err_cl) :- leapBy(MP,T,L), leapBy(MP,T + 1,-L), partTime(MP,T+1).


%% Dissonant contour
%% distance between lowest and highest note of melody - should not be a dissonant interval
#const err_dc="Dissonant contour".
reason(err_dc).
error(MP,TM,err_dc) :- lowestNote(MP,N1), highestNote(MP,N2),
                       chromatic(N1,C1),  chromatic(N2,C2),
                       not consonant(C1,C2), N1 < N2, partTimeMax(MP,TM).



%% No tri-tones
%% A tritone occurs when a pair of notes, one time step apart differ
%% in tone by 6 semitones.
#const err_tt="Tri-tone".
reason(err_tt).
error(MP,T,err_tt) :- choosenNote(MP,T,N1), choosenNote(MP,T+2,N1+6).
error(MP,T,err_tt) :- choosenNote(MP,T,N1), choosenNote(MP,T+2,N1-6).





%% Impulse
%% Stepwise linear progression creates impulse
%% Leaps create impulse - using the notes inbetween resolves this
downwardImpulse(MP,T+1) :- leapDown(MP,T), partTime(MP,T+1).
downwardImpulse(MP,T+3) :- stepDown(MP,T+2), stepDown(MP,T+1),
                           stepDown(MP,T), partTime(MP,T+3).

upwardImpulse(MP,T+1) :- leapUp(MP,T), partTime(MP,T+1).
upwardImpulse(MP,T+3) :- stepUp(MP,T+2), stepUp(MP,T+1),
                         stepUp(MP,T), partTime(MP,T+3).


%% Resolution is in the oppersite direction to impulse
#const err_inr="Impulse not resolved".
reason(err_inr).
error(MP,T,err_inr) :- downwardImpulse(MP,T), downAt(MP,T).
error(MP,T,err_inr) :- upwardImpulse(MP,T), upAt(MP,T).


%% After a leap must use everything inbetween 
%% can jump again but it must be inside the range
#const err_ns="Note skipped".
reason(err_ns).
error(MP,TM,err_ns) :-  not notePlayed(MP,N),
                        lowerThanHighestNote(MP,N), higherThanLowestNote(MP,N),
                        chromatic(N,C), modeChromaticPosition(C),
                        partTimeMax(P,TM).




%% We have a window in which repetition isn't allowed
repetitionWindow(8).
#domain repetitionWindow(RW).

%% Shouldn't repeat simple patterns of progression
%% (things in mode) 0 - 2 - 1, 1 - 3 - 2, 
%% A pattern is a minimum of 3 notes and a maximum of melodyLength/2 notes
#const err_rp="Repeated pattern".
reason(err_rp).
error(MP,T1,err_rp) :- stepBy(MP,T1,S1), stepBy(MP,T1 + 1,S2),
                       stepBy(MP,T2,S1), stepBy(MP,T2 + 1,S2),
                       T1 + 1 < T2, T2 < T1 + 2 + RW.
error(MP,T1,err_rp) :- stepBy(MP,T1,S1), leapBy(MP,T1 + 1,L2),
                       stepBy(MP,T2,S1), leapBy(MP,T2 + 1,L2),
                       T1 + 1 < T2, T2 < T1 + 2 + RW.
error(MP,T1,err_rp) :- leapBy(MP,T1,L1), stepBy(MP,T1 + 1,S2),
                       leapBy(MP,T2,L1), stepBy(MP,T2 + 1,S2),
                       T1 + 1 < T2, T2 < T1 + 2 + RW.
error(MP,T1,err_rp) :- leapBy(MP,T1,L1), leapBy(MP,T1 + 1,L2),
                       leapBy(MP,T2,L1), leapBy(MP,T2 + 1,L2),
                       T1 + 1 < T2, T2 < T1 + 2 + RW.


%% No repetition of two or more notes
#const err_rn="Repeated notes".
reason(err_rn).

error(MP,T1,err_rn) :- choosenNote(MP,T1,N), stepBy(MP,T1,S1),
                       choosenNote(MP,T2,N), stepBy(MP,T2,S1),
                       T1 + 1 < T2, T2 < T1 + 2 + RW.
error(MP,T1,err_rn) :- choosenNote(MP,T1,N), leapBy(MP,T1,L1),
                       choosenNote(MP,T2,N), leapBy(MP,T2,L1),
                       T1 + 1 < T2, T2 < T1 + 2 + RW.


%% Split melodies occur when the even / odd notes form separate melodies.
%% A leap (in the same direction) are not allowed to be repeated at T+2.
%% Steps are only allowed if the intermediate movement is not a step
%% in the oppersite direction.
#const err_sm="Split melody".
reason(err_sm).

error(MP,T,err_sm) :- leapBy(MP,T,L), leapBy(MP,T+2,L).
error(MP,T,err_sm) :- stepBy(MP,T,S1), stepBy(MP,T+1,S2), stepBy(MP,T+2,S1),
                      S1 > 0, S2 < 0.
error(MP,T,err_sm) :- stepBy(MP,T,S1), stepBy(MP,T+1,S2), stepBy(MP,T+2,S1),
                      S1 < 0, S2 > 0.

%% AD - 08/22

% For continuous binary:
%% Last chord of middle bar should be of the dominant chord, so we have an imperfect cadence
#const err_mcnimp="Middle cadence is not imperfect for melodic part".
reason(err_mcnimp).
error(MP,TM/2,err_mcnimp) :- not choosenChromatic(MP,TM/2,3), not choosenChromatic(MP,TM/2,8), not choosenChromatic(MP,TM/2,12), partTimeMax(MP,TM), form(binaryCont).