
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


%% chord.lp
%%
%% 19/05/09
%%
%% Concepts by John ffitch, jpff@cs.bath.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% Description of chords and chordal progression

%% Let the parser know we are generating chords
chordal(1) :- mode(major).
chordal(1) :- mode(minor).

%% A major chord is (4,3,5) - i.e. C,E,G
%% A minor chord is (3,4,5) - i.e. C,E^{\flat},G
chordOffset(0).
chordOffset(3) :- mode(minor).
chordOffset(4) :- mode(major).
chordOffset(7).

%% There are three triads
triad("tonic").             % Based on the fundamental
triad("dominant").          % Based a 5th / 7 semitones above fundamental
triad("subdominant").       % Based a 5th / 7 semitones below fundamental
#domain triad(TR).


%% Each triad contains three chromatic positions
triadPosition("base").
triadPosition("middle").
triadPosition("top").
#domain triadPosition(TP).

triadMember("tonic","base",1).
triadMember("dominant","base",8).
triadMember("subdominant","base",6).

triadMember(TR,"middle",C+3)      :- triadMember(TR,"base",C), mode(minor), C+3 <= 12.
triadMember(TR,"middle",(C+3)-12) :- triadMember(TR,"base",C), mode(minor), C+3 >  12.
triadMember(TR,"middle",C+4)      :- triadMember(TR,"base",C), mode(major), C+4 <= 12.
triadMember(TR,"middle",(C+4)-12) :- triadMember(TR,"base",C), mode(major), C+4 >  12.

triadMember(TR,"top",C+7)      :- triadMember(TR,"base",C), C+7 <= 12.
triadMember(TR,"top",(C+7)-12) :- triadMember(TR,"base",C), C+7 >  12.


%% Thus in C major there are three triads
%% Tonic         C - E - G  (The main one)
%% Dominant      G - B - D
%% Subdominant   F - A - C

%% Note when a part if playing part of a triad
partPlaysInTriad(PC,P,TR,TP) :- possibleChord(PC), triadMember(TR,TP,C),
			        noteInPossibleChord(P,T,PC), choosenChromatic(P,T,C).

%% A part is playing in the triad if it plays any position
inTriad(PC,P,TR) :- possibleChord(PC), part(P), triad(TR),
		    1 {partPlaysInTriad(PC,P,TR,TPP) : triadPosition(TPP) }.

%% And a position is played if any part plays it
triadPartPlayed(PC,TR,TP) :- possibleChord(PC), triad(TR), triadPosition(TP),
			     1 {partPlaysInTriad(PC,PP,TR,TP) : part(PP)}.

%% If all of the part are playing a given triad and
%% every part of that triad is being played, then we have that chord
chord(PC,TR) :- possibleChord(PC), 
                inTriad(PC,PP,TR) : part(PP),
                triadPartPlayed(PC,TR,TPP) : triadPosition(TPP).


%% Any chord has three positions
%% Lowest note in the chord gives the position
%% 1st note is lowest - base position
%% 2nd note is lowest - first inversion
%% 3rd note is lowest - second inversion

chordPosition(PC,"base") :- chord(PC,TR), lowestPart(LP),
			    partPlaysInTriad(PC,LP,TR,"base").
chordPosition(PC,"first inversion") :- chord(PC,TR), lowestPart(LP),
			    partPlaysInTriad(PC,LP,TR,"middle").
chordPosition(PC,"second inversion") :- chord(PC,TR), lowestPart(LP),
			    partPlaysInTriad(PC,LP,TR,"top").



%% A cadence is a pair of chords successive chord
cadence(PC2,"perfect") :- chord(PC1,"dominant"), chord(PC2,"tonic"),
		          possibleChord(PC1), possibleChord(PC2),
			  nextPossibleChord(PC1,PC2), PC1 < PC2.
cadence(PC2,"plagual") :- chord(PC1,"subdominant"), chord(PC2,"tonic"),
		          possibleChord(PC1), possibleChord(PC2),
			  nextPossibleChord(PC1,PC2), PC1 < PC2.
cadence(PC2,"imperfect") :- chord(PC1,"tonic"), chord(PC2,"dominant"),
		          possibleChord(PC1), possibleChord(PC2),
			  nextPossibleChord(PC1,PC2), PC1 < PC2.


%% Resolution
%% Second inversion is a special case, has to resolve to base position
%%  subdominant -> tonic
%%  tonic -> dominant
#const err_cnr="Chord not resolved".
reason(err_cnr).

error(LP,TM,err_cnr) :- chordPosition(PC1,"second inversion"),
		        not chordPosition(PC2,"base"),
		        possibleChord(PC1), possibleChord(PC2),
		        nextPossibleChord(PC1,PC2), PC1 < PC2,
		        lowestPart(LP), partTimeMax(LP,TM), chordal(1).

error(LP,TM,err_cnr) :- chordPosition(PC1,"second inversion"),
		        chord(PC1,"subdominant"),
                        not chord(PC2,"tonic"),
		        possibleChord(PC1), possibleChord(PC2),
		        nextPossibleChord(PC1,PC2), PC1 < PC2,
		        lowestPart(LP), partTimeMax(LP,TM), chordal(1).

error(LP,TM,err_cnr) :- chordPosition(PC1,"second inversion"),
		        chord(PC1,"tonic"),
                        not chord(PC2,"dominant"),
		        possibleChord(PC1), possibleChord(PC2),
		        nextPossibleChord(PC1,PC2), PC1 < PC2,
		        lowestPart(LP), partTimeMax(LP,TM), chordal(1).


%% Middle note of the triad is strong, so shouldn't be doubled
#const err_mntd="Middle note of triad doubled".
reason(err_mntd).
error(LP,TM,err_mntd) :- 2 { partPlaysInTriad(PC,PP,TR,"middle") : part(PP) },
                        chord(PC,TR), lowestPart(LP), partTimeMax(LP,TM), chordal(1).


%% Final notes must form a tonic chord
#const err_fnntc="Final note not a tonic chord".
reason(err_fnntc).
error(LP,TM,err_fnntc) :- not chord(PC,"tonic"), lastPossibleChord(PC),
		          lowestPart(LP), partTimeMax(LP,TM), chordal(1).


%% And it must be in base position
#const err_fcnbp="Final chord not in base position".
reason(err_fcnbp).
error(LP,TM,err_fcnbp) :- not chordPosition(PC,"base"), lastPossibleChord(PC),
		          lowestPart(LP), partTimeMax(LP,TM), chordal(1).

%% AD 08/22

% For continuous binary:
#const err_hfcnbp="Half V chord not in base position".
reason(err_hfcnbp).
error(LP,TM/2,err_hfcnbp) :- not choosenChromatic(LP,TM/2,8), lowestPart(LP), partTimeMax(LP,TM), form(binaryCont).

% For sectional binary:
#const err_hicnbp="Half I chord not in base position".
reason(err_hicnbp).
error(LP,TM/2,err_hicnbp) :- not choosenChromatic(LP,TM/2,1), lowestPart(LP), partTimeMax(LP,TM), form(binarySec).


% AD End


