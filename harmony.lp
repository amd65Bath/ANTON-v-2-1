
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


%% harmony.lp
%%
%% 31/03/07
%%
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Rules for working with multiple parts.
%% Every rule should be predicated so that if there is only one part, they won't be generated



%% The only allowed intervals between parts are consonant intervals (but not the major fourth (5))
%% plus minor and major sixth (8/9) and 15/16 major and minor third over the octave
validInterval(CI) :- CI != 5.
validInterval(8).
validInterval(9).
validInterval(12).
validInterval(15).
validInterval(16).


%% To simplify instantiation of a few rules, we infer which octave
%% a part is playing in at each given time
%noteOctave(N,O) :- note(N), chromatic(N,C), O = (N - C) / 12.
%choosenOctave(P,T,O) :- choosenNote(P,T,N), noteOctave(N,O).
%% The octave based encoding seems to save about 35% of program size but is slower

#const err_dibp="Dissonant interval between parts".
reason(err_dibp).
error(P1,T1,err_dibp) :- choosenChromatic(P1,T1,C1), choosenChromatic(P2,T2,C2),
                         P1 < P2, chromaticInterval(C1,C2,D), not validInterval(D),
                         noteOverlap(P1,T1,P2,T2).
                        


%% The maximum distance between parts is an octave plus 4 semitones (i.e. 16 semitones).
#const err_mdbp="Over maximum distance between parts".
reason(err_mdbp).
error(P,T1,err_mdbp) :- choosenNote(P,T1,N1), choosenNote(P+1,T2,N2),
                        N1 > N2 + 16, part(P+1), noteOverlap(P,T1,P+1,T2).

% Alternative, octave based enocding
%error(P,T1,err_mdbp) :- choosenOctave(P,T1,O1), choosenOctave(P+1,T2,O2),
%                        O1 > O2 + 2, part(P+1), noteOverlap(P,T1,P+1,T2).
%error(P,T1,err_mdbp) :- choosenOctave(P,T1,O+1), choosenOctave(P+1,T2,O),
%			choosenNote(P,T1,N1), choosenNote(P+1,T2,N2),
%			noteOctave(N1,O+2), noteOctave(N2,O),
%                        N1 > N2 + 16, part(P+1), noteOverlap(P,T1,P+1,T2).
%error(P,T1,err_mdbp) :- choosenOctave(P,T1,O+1), choosenOctave(P+1,T2,O),
%			choosenNote(P,T1,N1), choosenNote(P+1,T2,N2),
%			noteOctave(N1,O+1), noteOctave(N2,O),
%                        N1 > N2 + 16, part(P+1), noteOverlap(P,T1,P+1,T2).


%% Parts can't cross over.
#const err_pcc="Parts can not cross".
reason(err_pcc).
error(P,T1,err_pcc) :- choosenNote(P,T1,N1), choosenNote(P+1,T2,N2),
                       N1 < N2, part(P+1), noteOverlap(P,T1,P+1,T2).


%% Parts can only ever meet at a single point, and this can only happen once.
%% P+1 is OK, because for P,P+N (N>1) to meet have to have P,P+1 meet.
unison(P1,P2,T1) :- choosenNote(P1,T1,N), choosenNote(P2,T2,N), P1 < P2, noteOverlap(P1,T1,P2,T2).
haveMet(P,T+1) :- unison(P,P+1,T), not haveMet(P,T), part(P+1), partTime(P,T).
haveMet(P,T+1) :- haveMet(P,T), partTime(P,T).

#const err_cmmt="Parts can not meet multiple times".
reason(err_cmmt).
error(P,T,err_cmmt) :- unison(P,P+1,T), haveMet(P,T), part(P+1).


%% If one voice leaps, neighbouring parts must step or leap
%% in the oppersite direction
#const err_nspj="No simultaneous parallel leaps".
reason(err_nspj).
error(P2,T1,err_nspj) :- leapDown(P1,T1), downAt(P2,T2),
                        P1-1 <= P2, P2 <= P1+1, P1 != P2,
                        noteOverlap(P1,T1,P2,T2).
error(P2,T1,err_nspj) :-   leapUp(P1,T1),   upAt(P2,T2),
                        P1-1 <= P2, P2 <= P1+1, P1 != P2,
                        noteOverlap(P1,T1,P2,T2).

%% Two parts shouldn't leap to the same chromatic position
#const err_ltscp="Leap to same chromatic position".
reason(err_ltscp).

error(P1,T1,err_ltscp) :- choosenChromatic(P1,T1,C), choosenChromatic(P2,T2,C),
                          leapAt(P1,T1-1), leapAt(P2,T2-1), P1 < P2,
                          noteOverlap(P1,T1,P2,T2).

%% Two parts shouldn't leap by the same amount in the same direction
#const err_plsi="Parallel leap by the same interval".
reason(err_plsi).

error(P1,T1,err_plsi) :- leapBy(P1,T1,L), leapBy(P2,T2,L), P1 < P2, noteOverlap(P1,T1,P2,T2).


%% No sequences of perfect fifths or perfect octaves
#const err_rpf="Repeated perfect fifth".
reason(err_rpf).
perfectFifth(P1,P2,T1) :- choosenChromatic(P1,T1,C1), choosenChromatic(P2,T2,C2),
                          chromaticInterval(C1,C2,7), P1 < P2,
                          noteOverlap(P1,T1,P2,T2).
error(P1,T,err_rpf) :- perfectFifth(P1,P2,T), perfectFifth(P1,P2,T+1),
                       P1 < P2,  partTime(P1,T+1).


% If two parts play in unison, we don't want this identified as a perfectOctave
#const err_rpo="Repeated perfect octave".
reason(err_rpo).
perfectOctave(P1,P2,T1) :- choosenChromatic(P1,T1,C1), choosenChromatic(P2,T2,C2),
                           chromaticInterval(C1,C2,0), P1 < P2, not unison(P1,P2,T1),
                           noteOverlap(P1,T1,P2,T2).
error(P1,T,err_rpo) :- perfectOctave(P1,P2,T), perfectOctave(P1,P2,T+1),
                       P1 < P2,  partTime(P1,T+1).




%% The same consonant interval can be repeated at most three times
%% (notes as well as semitone intervals)
#const err_qci="Consonant interval repeated more than three times".
reason(err_qci).

partChromaticInterval(P,P+1,T1,D) :- choosenChromatic(P,T1,C1),
                                    choosenChromatic(P+1,T2,C2),
                                    chromaticInterval(C1,C2,D),
                                    part(P+1),
                                    noteOverlap(P,T1,P+1,T2).

error(P,T,err_qci) :- partChromaticInterval(P,P+1,T,D),
		      partChromaticInterval(P,P+1,T+1,D),
		      partChromaticInterval(P,P+1,T+2,D),
		      partChromaticInterval(P,P+1,T+3,D),
                      partTime(P,T+3).


%% Should never have two parts playing the last note of the scale together
#const err_rlns="Repeated last note of scale".
reason(err_rlns).

error(P1,T1,err_rlns) :- choosenChromatic(P1,T1,C1), choosenChromatic(P2,T2,C2),
                        lastChromaticPositionInMode(C1),
                        lastChromaticPositionInMode(C2),
                        P1 < P2, noteOverlap(P1,T1,P2,T2).


% AD - 08/22

% For continuous binary:
%% Last chord of middle bar should be of the dominant chord, so we have an imperfect cadence
#const err_mcni="Middle cadence is not imperfect".
reason(err_mcni).
error(P,TM/2,err_mcni) :- not choosenChromatic(P,TM/2,3), not choosenChromatic(P,TM/2,8), not choosenChromatic(P,TM/2,12), partTimeMax(P,TM), form(binaryCont).

% For continuous binary:
%% Middle imperfect cadence should be a IV-V, II-V or I-V
#const err_pvc="Not a proper V cadence".
reason(err_pvc).
error(P,TM/2-1,err_pvc) :- choosenChromatic(P,TM/2-1,12), partTimeMax(P,TM), form(binaryCont).

% For sectional binary:
%% Last chord of middle bar should be of the tonic
#const err_mcnft="Middle cadence does not finish on tonic".
reason(err_mcnft).
error(P,TM/2,err_mcnft) :- not choosenChromatic(P,TM/2,1), not choosenChromatic(P,TM/2,5), not choosenChromatic(P,TM/2,8), partTimeMax(P,TM), form(binarySec).

% For sectional binary:
%% Last cadence of middle bar should be plagal or perfect
#const err_mcnpp="Middle cadence is not plagal or perfect".
reason(err_mcnpp).
error(P,TM/2-1,err_mcnpp) :- choosenChromatic(P,TM/2-1,3), partTimeMax(P,TM), form(binarySec).


% %% Final cadence should be a perfect cadence if form is binary.
#const err_pcnv="Penultimate chord not a V".
reason(err_pcnv).
error(P,TM-1,err_pcnv) :- not choosenChromatic(P,TM-1,3), not choosenChromatic(P,TM-1,8), not choosenChromatic(P,TM-1,12), partTimeMax(P,TM), not form(standard).

% AD End