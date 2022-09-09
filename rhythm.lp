
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


%% rhythm.lp
%%
%% Martin Brain
%% mjb@cs.bath.ac.uk
%% 20/05/09
%% 
%% Concepts by Georg Boenn, gboenn@glam.ac.uk
%% Encoding by Martin Brain, mjb@cs.bath.ac.uk
%%
%% The encoding of rhythm is based on the concept of Farey trees
%% This encoding creates Farey trees and then creates a mapping to note positions
%% Note the duration is not computed here as the tree nodes are
%% effectively in the 'middle' of the note.

% We are using rhythm
rhythm(1).

%% There are several possible Farey Trees
%#const f=2.
%fareyTree(1..f).
fareyTree(P).
#domain fareyTree(F).

%% Parts map to Farey trees
%partToFareyTree(P,1).
partToFareyTree(P,P).

%% Each Farey tree has a given depth
depth(F,MD + BD + DD) :- measureDepth(MD), meterDepth(F,BD), durationDepth(F,DD).
level(F,1..DE) :- depth(F,DE).



%% Each Farey tree is divided into three layers (top to bottom)
%% Measure, meter and note duration
%% (bars, time signature and note value)
%% Each of which has it's own rules

durationDepth(F,2).

durationLevel(F,FL) :- depth(F,DE), durationDepth(F,DD), level(F,FL), FL > (DE - DD).
durationLeafLevel(F,DE) :- depth(F,DE).

meterLevel(F,FL) :- depth(F,DE), durationDepth(F,DD), meterDepth(F,BD), 
                   level(F,FL), FL <= (DE - DD), FL > (DE - (DD + BD)).
meterLeafLevel(F,DE - DD) :- depth(F,DE), durationDepth(F,DD).

measureLevel(F,FL) :- depth(F,DE), durationDepth(F,DD), meterDepth(F,BD), 
                      level(F,FL), FL <= DE - (DD + BD).
measureLeafLevel(F,DE - (DD + BD)) :- depth(F,DE), durationDepth(F,DD), meterDepth(F,BD).







%% At each level of expansion there are at most N times
%% the number of nodes of the previous one
%% (At the moment 5 way expansion is not used)
maxExpansion(F,3).
nodeLimit(F,1,1).
nodeLimit(F,FL,ME**(FL-1)) :- level(F,FL), FL > 1, maxExpansion(F,ME).

% Each level of the tree then has at that many possible nodes.
node(F,FL,0..NL-1) :- nodeLimit(F,FL,NL).

%% The descendants of a node are the (maxExpansion) nodes on the level below
descendantOffset(F,0..ME-1) :- maxExpansion(F,ME).
descendant(F,D,FL,ND,FL+1,(ME * ND) + D) :- node(F,FL,ND), level(F,FL+1),
                                            descendantOffset(F,D), maxExpansion(F,ME).

%% The root node is always present
present(F,1,0).

%% Every present, non-leaf node expands up to 1,2,3 or 5 ways
possibleExpansion(F,1).
possibleExpansion(F,2) :- 2 <= ME, maxExpansion(F,ME).
possibleExpansion(F,3) :- 3 <= ME, maxExpansion(F,ME).
possibleExpansion(F,5) :- 5 <= ME, maxExpansion(F,ME).

1 { expand(F,FL,ND,E) : possibleExpansion(F,E) } 1 :- present(F,FL,ND), not depth(F,FL).

%% Only descendants less than the expansion are present
present(F,FL2,ND2) :- expand(F,FL1,ND1,E), descendant(F,D,FL1,ND1,FL2,ND2),
                      D < E, possibleExpansion(F,E).




%% Map from nodes to time positions
%% Mapping increments each time a node is present
nodeStep(F,0,1).
nodeStep(F,ND,T) :- not present(F,DLL,ND), nodeStep(F,ND-1,T),
                        node(F,DLL,ND), durationLeafLevel(F,DLL), ND > 0,
                        partToFareyTree(P,F), partTime(P,T).
nodeStep(F,ND,T+1) :-   present(F,DLL,ND), nodeStep(F,ND-1,T),
                        node(F,DLL,ND), durationLeafLevel(F,DLL), ND > 0,
                        partToFareyTree(P,F), partTime(P,T).

%% From this we derive a unique mapping from node to time step
timeToNode(P,1,0).
timeToNode(P,T,ND) :- present(F,DLL,ND), nodeStep(F,ND-1,T-1),
                      node(F,DLL,ND), durationLeafLevel(F,DLL), ND > 0,
                      partToFareyTree(P,F), partTime(P,T).

#show nodeStep(F,ND,T).

%% To make sure the mapping is 1 to 1 between present nodes and time steps
#const err_mtstn="More time steps than leaves on the Farey tree".
reason(err_mtstn).
error(1,1,err_mtstn) :- {timeToNode(P,T,ND) : node(F,DLL,ND)} 0,
                        durationLeafLevel(F,DLL),
                        partToFareyTree(P,F), partTime(P,T).

#const err_ftstn="Fewer time steps than leaves on the Farey tree".
reason(err_ftstn).
error(1,1,err_ftstn) :- nodeStep(F,ND,TM+1), partToFareyTree(P,F),
                        partTimeMax(P,TM).









%% All leaves of the measure layer must be the same length
#const err_mlnsl="Measure layer has divisions that are not of the same length".
reason(err_mlnsl).
error(1,1,err_mlnsl) :- measureLevel(F,FL), measureLevel(F,FL+1),
                         expand(F,FL,ND1,E1), expand(F,FL,ND2,E2),
                         ND1 < ND2, E1 != E2.

%% All parts must have the same measure section
#const err_mldddft="Measure layer depth different in different Farey trees".
reason(err_mldddft).
error(1,1,err_mldddft) :- measureLevel(F1,FL), not measureLevel(F2,FL),
                           fareyTree(F1), fareyTree(F2), F1 != F2.

#const err_mlncbft="Measure layer not consistant between Farey trees".
reason(err_mlncbft).
error(1,1,err_mlncbft) :- measureLevel(F1,FL), measureLevel(F1,FL+1),
                         measureLevel(F2,FL), measureLevel(F2,FL+1),
                         expand(F1,FL,ND,E1), expand(F2,FL,ND,E2), E1 != E2,
                         F1 != F2.

%% Assert an ordering on the measure level to remove symmetries
#const err_dnml="Denormalised measure level".
reason(err_dnml).
error(1,1,err_dnml) :- measureLevel(F,FL), measureLevel(F,FL+1), measureLevel(F,FL+2),
                       descendant(F,D,FL,ND1,FL+1,ND2),
                       expand(F,FL,ND1,E1), expand(F,FL,ND2,E2), E1 > E2.

%% TODO - given previous rules we could probably simplify the two previous rules


%% Constraint to the requested number of measures
#const err_tfm="Too few measures".
reason(err_tfm).
error(1,1,err_tfm) :- 0 { present(F,MLL,ND) : node(F,MLL,ND) } ML - 1,
                      measureLimit(ML), measureLeafLevel(F,MLL). 

#const err_tmm="Too many measures".
reason(err_tmm).
error(1,1,err_tmm) :- ML + 1 { present(F,MLL,ND) : node(F,MLL,ND) },
                      measureLimit(ML), measureLeafLevel(F,MLL). 





%% Within one measure all meters must have the same duration
%% (Note the -1 to cover the branching from measure to meter layer)
%% The weird division constraint is making sure both are children of the same
%% node in the measure layer, given the known expansion rate
#const err_blim="Irregular meter".
reason(err_blim).
error(1,1,err_blim) :- meterLevel(F,FL), ND1 < ND2, E1 != E2,
                       expand(F,FL-1,ND1,E1), expand(F,FL-1,ND2,E2),
                       measureLeafLevel(F,MLL), maxExpansion(F,ME),
                       (ND1 / (ME**(FL - MLL))) == (ND2 / (ME**(FL - MLL))),
                       regularMeter(F).

%% In many cases we want the meter to be the same for every measure for a given tree
#const err_bmm="Mixed meter".
reason(err_bmm).
error(1,1,err_bmm) :- meterLevel(F,FL), ND1 < ND2, E1 != E2,
                      expand(F,FL-1,ND1,E1), expand(F,FL-1,ND2,E2),
                      uniformMeter(F).

%% In many cases we want the meter to be the same for every Farey tree.
#const err_bldddft="Meter layer depth different in different Farey trees".
reason (err_bldddft).
error(1,1,err_bnsfrt) :- meterLevel(F1,FL), not meterLevel(F2,FL),
                         fareyTree(F1), fareyTree(F2), F1 != F2,
                         sameMeter(F1,F2).

#const err_bnsfrt="Meter layer not consistant between Farey trees".
reason(err_bnsfrt).
error(1,1,err_bnsfrt) :- meterLevel(F1,FL), meterLevel(F2,FL),
                         expand(F1,FL-1,ND,E1), expand(F2,FL-1,ND,E2), E1 != E2,
                         F1 != F2, sameMeter(F1,F2).

%% TODO - same comment about simplification as before

%% Expansion by 1 is a little suspect in the meter layer
%% It is used for things like 3/4 and 6/8 but otherwise not
%% Thus we want any division by one to be done at the top of the meter layer
%% Minus one is to that the expansion from measure to meter is covered as well
#const err_blebo="Meter layer contains denormalised expansion by one".
reason(err_blebo).
error(1,1,err_blebo) :- meterLevel(F,FL), meterLevel(F,FL+1),
                        expand(F,FL-1,ND,E1), expand(F,FL,ND,1), E1 > 1.




%% Time signatures are effectively sets of options for the meter level.
#const err_mdnmts="Meter does not match time signature".
reason(err_mdnmts).

%% They can be set per tree and will apply to all meters
regularMetric(F) :- treeTimeSignature(F,TS).
uniformMetric(F) :- treeTimeSignature(F,TS).


%% meterDepthConfig(F,TS) is only needed due to an algorithmic glitch
%% in GrinGo's domain predicate inference.  It should be possible to 
%% to use just treeTimeSignature(F,TS), but for domain predicate inference
%% to work, it's necessary to separate the predcates that infer meterDepth
%% and those that constrain the tree.

%% 2/2 (X X)
timeSignature("2/2").
%meterDepth(F,1) :- treeTimeSignature(F,"2/2").
meterDepth(F,1) :- meterDepthConfig(F,"2/2").
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"2/2"), expand(F,MLL,ND,E), E != 2. 




%% Generic two layer time signature
meterDepth(F,2) :- meterDepthConfig(F,"2-layer").
1 { chosenTimeSignature("4/4"),
    chosenTimeSignature("3/4") } 1 :- wildcardTimeSignature("2-layer").
treeTimeSignature(F,TS) :- chosenTimeSignature(TS).

%% 4/4 ((X X) (X X)) 
timeSignature("4/4").
%meterDepth(F,2) :- treeTimeSignature(F,"4/4").
meterDepth(F,2) :- meterDepthConfig(F,"4/4").
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"4/4"), expand(F,MLL,ND,E), E != 2. 
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"4/4"), expand(F,MLL+1,ND,E), E != 2. 
%% 3/4 ((X X X))
timeSignature("3/4").
%meterDepth(F,2) :- treeTimeSignature(F,"3/4").
meterDepth(F,2) :- meterDepthConfig(F,"3/4").
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"3/4"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"3/4"), expand(F,MLL+1,ND,E), E != 3.



 
%% Generic three layer time signature
meterDepth(F,3) :- meterDepthConfig(F,"3-layer").
1 { chosenTimeSignature("3/8"),
    chosenTimeSignature("6/8"),
    chosenTimeSignature("9/8"),
    chosenTimeSignature("12/8") } 1 :- wildcardTimeSignature("3-layer").
treeTimeSignature(F,TS) :- chosenTimeSignature(TS).


%% 3/8 (((X X X)))
timeSignature("3/8").
%meterDepth(F,3) :- treeTimeSignature(F,"3/8").
meterDepth(F,3) :- meterDepthConfig(F,"3/8").
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"3/8"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"3/8"), expand(F,MLL+1,ND,E), E != 1.
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"3/8"), expand(F,MLL+2,ND,E), E != 3.

%% 6/8 (((X X X) (X X X)))
timeSignature("6/8").
%meterDepth(F,3) :- treeTimeSignature(F,"6/8").
meterDepth(F,3) :- meterDepthConfig(F,"6/8").
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"6/8"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"6/8"), expand(F,MLL+1,ND,E), E != 2.
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"6/8"), expand(F,MLL+2,ND,E), E != 3.


%% 9/8 (((X X X) (X X X) (X X X)))
timeSignature("9/8").
%meterDepth(F,3) :- treeTimeSignature(F,"9/8").
meterDepth(F,3) :- meterDepthConfig(F,"9/8").
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"9/8"), expand(F,MLL,ND,E), E != 1. 
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"9/8"), expand(F,MLL+1,ND,E), E != 3.
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"9/8"), expand(F,MLL+2,ND,E), E != 3.

%% 12/8 (((X X X) (X X X)) ((X X X) (X X X)))
timeSignature("12/8").
%meterDepth(F,12) :- treeTimeSignature(F,"12/8").
meterDepth(F,12) :- meterDepthConfig(F,"12/8").
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL,ND),
                         treeTimeSignature(F,"12/8"), expand(F,MLL,ND,E), E != 2. 
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+1,ND),
                         treeTimeSignature(F,"12/8"), expand(F,MLL+1,ND,E), E != 2.
error(1,1,err_mdnmts) :- measureLeafLevel(F,MLL), node(F,MLL+2,ND),
                         treeTimeSignature(F,"12/8"), expand(F,MLL+2,ND,E), E != 3.






%% Work out meter strength
%% For leaves of the duration layer this is the number of first children
%% in the meter layer it is a descendant of.  This is then inherited by the
%% firstChildren in the duration layer.
meterStrengthMax(F,BD) :- meterDepth(F,BD).
meterStrength(F,0..BSM) :- meterStrengthMax(F,BSM).

%% Meter strength is created at the first level of the meter layer ...
nodeMeterStrength(F,MLL+1,ND2,1) :- measureLeafLevel(F,MLL), node(F,MLL,ND1),
                                   descendant(F,0,MLL,ND1,MLL+1,ND2).
nodeMeterStrength(F,MLL+1,ND2,0) :- measureLeafLevel(F,MLL), node(F,MLL,ND1),
                                   descendant(F,D,MLL,ND1,MLL+1,ND2), D != 0.


%% ... strengthened and passed to a first descendant in the layer ...
nodeMeterStrength(F,FL+1,ND2,BS+1) :- meterLevel(F,FL), meterLevel(F,FL+1), node(F,FL,ND1),
                                     descendant(F,0,FL,ND1,FL+1,ND2),
                                     nodeMeterStrength(F,FL,ND1,BS), meterStrength(F,BS).

%% ... but not to the others ...
nodeMeterStrength(F,FL+1,ND2,0) :- meterLevel(F,FL), meterLevel(F,FL+1), node(F,FL,ND1),
                                  descendant(F,D,FL,ND1,FL+1,ND2), D != 0,
                                  nodeMeterStrength(F,FL,ND1,BS), meterStrength(F,BS).


%% ... and transmitted to the first descendants in the duration layer ...
nodeMeterStrength(F,BLL+1,ND2,BS) :- meterLeafLevel(F,BLL), node(F,BLL,ND1),
                                    descendant(F,0,BLL,ND1,BLL+1,ND2), BS > 0,
                                    nodeMeterStrength(F,BLL,ND1,BS), meterStrength(F,BS).


%% ... and so on down through the first descendants.
nodeMeterStrength(F,FL+1,ND2,BS) :- durationLevel(F,FL), durationLevel(F,FL+1), node(F,FL,ND1),
                                   descendant(F,0,FL,ND1,FL+1,ND2), BS > 0,
                                   nodeMeterStrength(F,FL,ND1,BS), meterStrength(F,BS).






%% Duration level

%% Work out duration length - this is given by the number of time the parents
%% expand by one
durationStepMax(F,DD) :- durationDepth(F,DD).
durationStep(F,0..DS) :- durationStepMax(F,DS).

%% Duration step is created by the division by more than one at the meter level
nodeDurationStep(F,BLL+1,ND2,0) :-  meterLeafLevel(F,BLL), node(F,BLL,ND1),
                                    expand(F,BLL,ND1,1),
                                    descendant(F,D,BLL,ND1,BLL+1,ND2).

nodeDurationStep(F,BLL+1,ND2,1) :-  meterLeafLevel(F,BLL), node(F,BLL,ND1),
                                    expand(F,BLL,ND1,E), E > 1,
                                    descendant(F,D,BLL,ND1,BLL+1,ND2).

%% And propagated down the tree in a similar fashion
nodeDurationStep(F,FL+1,ND2,DS) :-  durationLevel(F,FL), durationLevel(F,FL+1),
                                    expand(F,FL,ND1,1), node(F,FL,ND1),
                                    descendant(F,D,FL,ND1,FL+1,ND2),
                                    nodeDurationStep(F,FL,ND1,DS),
                                    durationStep(F,DS).
                                    
nodeDurationStep(F,FL+1,ND2,DS+1) :-  durationLevel(F,FL), durationLevel(F,FL+1),
                                      expand(F,FL,ND1,E), E > 1, node(F,FL,ND1),
                                      descendant(F,D,FL,ND1,FL+1,ND2),
                                      nodeDurationStep(F,FL,ND1,DS),
                                      durationStep(F,DS).
                                    

%% Use these to infer note duration
timeStepDuration(P,T,DS) :- timeToNode(P,T,ND), partToFareyTree(P,F),
                            depth(F,DE), nodeDurationStep(F,DE,ND,DS).







%%% Style info


regularMeter(F) :- fareyTree(F).
uniformMeter(F) :- fareyTree(F).
sameMeter(F1,F2) :- fareyTree(F1), fareyTree(F2), F1 != F2.


%% Division by greater than two should only be used at
%% the lowest level of note division
%% Minus one to catch the expansion from meter to duration
topLevelEvenDurationDivision(1).
#const err_demt2="Expansion by more than two at non-leaf duration level".
reason(err_demt2).
error(1,1,err_demt2) :- durationLevel(F,FL), not durationLeafLevel(F,FL),
                        expand(F,FL-1,ND,E), E > 2, topLevelEvenDurationDivision(1).

%% Neighbouring divisions can only increase / decrease duration length by 1
#const err_sscid="Sudden significant change in duration".
reason(err_sscid).
error(P,T,err_sscid) :- timeStepDuration(P,T,DS1), timeStepDuration(P,T+1,DS2),
                        abs(DS1 - DS2) > 1.

%% Just for fun, a few rules linking note duration and melodic effects

%% No fast leaps
#const err_nfl="No fast leaps".
reason(err_nfl).
error(P,T,err_nfl) :- leapAt(P,T), timeStepDuration(P,T,DS), DS > 1.

%% Lowest and highest notes must also be slower
#const err_hnbs= "Highest note must be slow".
#const err_lnbs="Lowest note must be slow".
reason(err_hnbs).
reason(err_lnbs).

playsHeighestNote(P,T) :- choosenNote(P,T,N), lowestNote(P,N).
playsLowestNote(P,T) :- choosenNote(P,T,N), lowestNote(P,N).
error(P,T,err_hnbs) :- playsHeighestNote(P,T), timeStepDuration(P,T,DS), DS > 1.
error(P,T,err_lnbs) :- playsLowestNote(P,T), timeStepDuration(P,T,DS), DS > 1.

%% Shouldn't finish on a fast note
#const err_snffn="Should not finish on a fast note".
reason(err_snffn).
error(P,TM-1,err_snffn) :- timeStepDuration(P,TM-1,DS), DS > 1, partTimeMax(P,TM).
error(P,TM,err_snffn) :- timeStepDuration(P,TM,DS), DS > 0, partTimeMax(P,TM).










%% Hack overlapping rules
hackOverlap(F1,F2) :- sameMeter(F1,F2), topLevelEvenDurationDivision(1),
                      durationDepth(F1,2), durationDepth(F2,2).

%% First we do the top level, each tree can either divide by one or divide by two
same(F1,ND2,F2,ND2) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
		       meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                       expand(F1,BLL,ND1,E), expand(F2,BLL,ND1,E),
                       descendant(F1,D,BLL,ND1,BLL+1,ND2), D < E,
                       descendant(F2,D,BLL,ND1,BLL+1,ND2),
                       hackOverlap(F1,F2), F1 < F2.

%% First node is first half of second node
firstFirstHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                         meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                 expand(F1,BLL,ND1,2), expand(F2,BLL,ND1,1),
                                 descendant(F1,0,BLL,ND1,BLL+1,ND2),
                                 descendant(F2,0,BLL,ND1,BLL+1,ND3),
                                 hackOverlap(F1,F2), F1 < F2.

%% First node is second half of second node
firstSecondHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                          meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                  expand(F1,BLL,ND1,2), expand(F2,BLL,ND1,1),
                                  descendant(F1,1,BLL,ND1,BLL+1,ND2),
                                  descendant(F2,0,BLL,ND1,BLL+1,ND3),
                                  hackOverlap(F1,F2), F1 < F2.

%% Second node is first half of first node
secondFirstHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                          meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                  expand(F1,BLL,ND1,1), expand(F2,BLL,ND1,2),
                                  descendant(F1,0,BLL,ND1,BLL+1,ND2),
                                  descendant(F2,0,BLL,ND1,BLL+1,ND3),
                                  hackOverlap(F1,F2), F1 < F2.

%% Second node is second half of first node
secondSecondHalf(F1,ND2,F2,ND3) :- meterLeafLevel(F1,BLL), present(F1,BLL,ND1),
	                           meterLeafLevel(F2,BLL), present(F2,BLL,ND1),
                                   expand(F1,BLL,ND1,1), expand(F2,BLL,ND1,2),
                                   descendant(F1,0,BLL,ND1,BLL+1,ND2),
                                   descendant(F2,1,BLL,ND1,BLL+1,ND3),
                                   hackOverlap(F1,F2), F1 < F2.



%% Now the second layer

%% First if they are the same
%% Same and same expand gives
nodeOverlap(F1,ND2,F2,ND2) :- same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,E), expand(F2,BLL+1,ND1,E),
                              descendant(F1,D,BLL+1,ND1,BLL+2,ND2), D < E,
                              descendant(F2,D,BLL+1,ND1,BLL+2,ND2),
                              hackOverlap(F1,F2), F1 < F2.

nodeOverlap(F1,ND2,F2,ND3) :- same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND1,E), E != 1,
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND2), D < E,
                              descendant(F2,D,BLL+1,ND1,BLL+2,ND3),
                              hackOverlap(F1,F2), F1 < F2.

nodeOverlap(F1,ND2,F2,ND3) :- same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,E), expand(F2,BLL+1,ND1,1), E != 1,
                              descendant(F1,D,BLL+1,ND1,BLL+2,ND2), D < E,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND3),
                              hackOverlap(F1,F2), F1 < F2.

nodeOverlap(F1,ND2,F2,ND3) :- same(F1,ND1,F2,ND1),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND1),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND1,E2),
                              E1 != 1, E2 != 1, E1 != E2,
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND2), D1 < E1,
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND3), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.


%% Now for the divisions by two
%% First node if first half of second
%% Expand the second by one overlaps all
%% Likewise expanding the second by two overlaps all descendants with the first descendants
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,E2), E2 <= 2,
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < E1,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by one and three gives overlaps with first two
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two and three gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,2,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.


%% The rest are similar but with slight permutations

%% Expand by one
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,1),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < E1,
                              descendant(F2,0,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,2),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < E1,
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by one and three gives overlaps with last two
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), 0 < D2, D2 <= 2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two and three gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,2,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- firstSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), 0 < D1, D1 < 3,
                              descendant(F2,2,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.




%% Similar for the inverse relations
%% Except the expand and descendant lines are switched
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,E1), expand(F2,BLL+1,ND2,E2), E1 <= 2,
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and one gives overlaps with first two
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,1),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), D1 < 2,
                              descendant(F2,0,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and two gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND1,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondFirstHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,2,BLL+1,ND1,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.


%% The rest are similar but with slight permutations

%% Expand by one
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,1), expand(F2,BLL+1,ND2,E2),
                              descendant(F1,0,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,2), expand(F2,BLL+1,ND2,E2),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), D2 < E2,
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and one gives overlaps with last two
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,1),
                              descendant(F1,D1,BLL+1,ND1,BLL+2,ND3), 0 < D1, D1 <= 2,
                              descendant(F2,0,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by two and three gives overlaps 
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), D2 < 2,
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,2),
                              descendant(F1,2,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,1,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.

%% Expand by three and three
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,1,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,0,BLL+1,ND2,BLL+2,ND4),
                              hackOverlap(F1,F2), F1 < F2.
nodeOverlap(F1,ND3,F2,ND4) :- secondSecondHalf(F1,ND1,F2,ND2),
                              meterLeafLevel(F1,BLL), present(F1,BLL+1,ND1),
	                      meterLeafLevel(F2,BLL), present(F2,BLL+1,ND2),
                              expand(F1,BLL+1,ND1,3), expand(F2,BLL+1,ND2,3),
                              descendant(F1,2,BLL+1,ND1,BLL+2,ND3),
                              descendant(F2,D2,BLL+1,ND2,BLL+2,ND4), 0 < D2, D2 < 3,
                              hackOverlap(F1,F2), F1 < F2.






%% Finally, infer note overlap
%noteOverlap(P1,T1,P2,T2) :- timeToNode(P1,T1,ND1), partToFareyTree(P1,F1),
%                            timeToNode(P2,T2,ND2), partToFareyTree(P2,F2),
%                            nodeOverlap(F1,ND1,F2,ND2), P1 < P2, F1 != F2.
%% Should 'just work' with dotted notes

%% An alternative mapping - requires more atoms but less rules
timeToNodeOverlap(P1,T1,F2,ND2) :- timeToNode(P1,T1,ND1), partToFareyTree(P1,F1),
				   nodeOverlap(F1,ND1,F2,ND2), F1 < F2.
noteOverlap(P1,T1,P2,T2) :- timeToNodeOverlap(P1,T1,F2,ND2), timeToNode(P2,T2,ND2),
			    partToFareyTree(P2,F2), P1 < P2.


noteOverlap(P1,T,P2,T) :-  partToFareyTree(P1,F), partToFareyTree(P2,F),
		           partTime(P1,T), partTime(P2,T), P1 < P2.



%% Chording with rhythm assumes that all Farey trees have the same meter
hackChords(1) :- sameMeter(F1,F2) : fareyTree(F1) : fareyTree(F2) : F1 != F2, chordal(1).


%% Each meter leaf node corresponds to a possible chord
possibleChord(PC) :- present(F,BLL,PC), meterLeafLevel(F,BLL), hackChords(1).

% Hack to help the grounder
possibleChordDomain(PC) :- node(F,BLL,PC), meterLeafLevel(F,BLL), hackChords(1).


nextPossibleChord(PC1,PC2) :- possibleChord(PC1), possibleChord(PC2), PC1 < PC2,
			      not possibleChord(PC3) : possibleChordDomain(PC3)
			      	  		     : PC1 < PC3 : PC3 < PC2.
			      	                     
lastPossibleChord(PC1) :- possibleChord(PC1),
		          not possibleChord(PC2) : possibleChordDomain(PC2)
			      			 : PC1 < PC2.


%% The first note of each beat is in the possible chord
nodeInPossibleChord(F,BLL+1,ND,PC) :- present(F,BLL,PC), meterLeafLevel(F,BLL),
				      possibleChord(PC),
				      descendant(F,0,BLL,PC,BLL+1,ND), hackChords(1).

nodeInPossibleChord(F,FL+1,ND2,PC) :- present(F,FL,ND1), durationLevel(F,FL), 
				      possibleChord(PC),
				      nodeInPossibleChord(F,FL,ND1,PC),
				      descendant(F,0,FL,ND1,FL+1,ND2), hackChords(1).

%% Notes are in a chord if they correspond
noteInPossibleChord(P,T,PC) :- timeToNode(P,T,ND), partToFareyTree(P,F),
			       nodeInPossibleChord(F,DLL,ND,PC), possibleChord(PC),
			       durationLeafLevel(F,DLL), hackChords(1).



% Move to the relevant task
#hide.
#show rhythm(B).
#show fareyTree(F).
#show depth(F,D).
#show maxExpansion(F,E).
#show present(F,FL,ND).
#show expand(F,FL,ND,E).

#show partToFareyTree(P,F).
#show timeToNode(P,T,ND).

#show measureLimit(ML).
#show durationLevel(F,L).
#show durationLeafLevel(F,L).
#show meterLevel(F,L).
#show meterLeafLevel(F,L).
#show measureLevel(F,L).
#show measureLeafLevel(F,L).

#show meterStrengthMax(F,BS).
#show meterStrength(F,BS).
#show nodeMeterStrength(F,FL,ND,BS).

#show durationStepMax(F,DS).
#show durationStep(F,DS).
#show nodeDurationStep(F,FL,ND,DS).

#show nodeOverlap(F1,ND1,F2,ND2).
#show noteOverlap(P1,T1,P2,T2).

#show treeTimeSignature(F,TS).
#show meterDepthConfig(F,TS).
#show measureDepth(D).

#show possibleChord(ND).
#show noteInPossibleChord(P,T,PC).


