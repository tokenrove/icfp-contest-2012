#!/usr/bin/env jconsole

exit =: 2!:55
snarfStdin =: 1!:1 @ 3:
emit =: (1!:2) & 2

LF =: 10{a.
splitByLines =: ,;._2 @: ,&LF
squashInitial =: }.~ (0 i.~ (= i.&#))
blankLines =: I. @: (*/"1) @: (' '&=)

NB. (y x) shift map
shift =: |.!.0
above =: 1 0 & shift
below =: _1 0 & shift
left =: (0 1 & shift)
right =: (0 _1 & shift)
leftAndUpLeft =: left *. (1 1 & shift)
rightAndUpRight =: right *. (1 _1 & shift)

walls =: '#'&=
lambdas =: '\'&=
earth =: '.'&=
rocks =: '*'&=
robot =: 'R'&=
beards =: 'W'&=
razors =: '!'&=
NB. missing trampolines (A-G) and targets (1-9)
lift =: 'O'&= +. 'L'&=
empty =: ' '&=
lambdaCount =: +/ @: , @: lambdas
noLambdasRemain =: 0 = lambdaCount
movable =: empty +. earth

NB. 1. R and up(E) => down(R), E!
NB. 2. R and up(R) and left(E) and upleft(E) => downright(R), E!
NB. 3. R and up(R) and right(E) and upright(E) => downleft(R), E!
NB. 4. R and up(λ) and left(E) and upleft(E) => downright(R), E!
NB. 5. R => R
NB. R' = R & ~(1 | 2 | 3 | 4) | (1 & down(R)) | ((2|4) & downright(R)) | (3 & downleft(R))
NB. E' = E & R' | (1 | 2 | 3 | 4)
updaterocks =: 3 : 0
NB. XXX should probably calculate rocks once but i like these trains so much...
  a =. (rocks *. (above @: empty)) y
  b =. (rocks *. (above @: rocks) *. (leftAndUpLeft @: empty)) y
  c =. (rocks *. (above @: rocks) *. (rightAndUpRight @: empty)) y
  d =. (rocks *. (above @: lambdas) *. (leftAndUpLeft @: empty)) y
  r =. rocks y
  (r *. (-. (a +. b +. c +. d))) +. (below r *. a) +. (right @: below r *. (b+.d)) +. (left @: below r *. c)
)

am2d =: 1 : '([: $ ]) $ [ (I. (, u))} [: , ]'
mdLookup =: ([ >@#~ (_1 |. (= <)))
validMoves =: 'LRDU'
isIn =: ([: # ]) > i.~

NB. mutable state throughout simulation:
board =: ''                             NB. set in main
maxLambdas =: 0                         NB. set in main
nMoves =: 0
flooding =: 0
waterLevel =: 0
waterproof =: 10
saturation =: 0                         NB. how long has the robot been underwater?
nRazors =: 0
state =: <'mining'

simulateStep =: 3 : 0
  NB. preconditions: make sure the map has a robot and a lift
NB. .assert (1 = +/ ,lift board)
NB. .assert (1 = +/ ,robot board)

  NB. Phase 1: robot moves
  NB. If move is A, abort immediately, do not update number of moves.
if. -. state = <'mining' do.
elseif. 'A' = y do.
  state =: <'abort'
elseif. y isIn validMoves do.                  NB. move
  NB. check for ordinary move, lambda pickup, razor pickup, rock move, or trampoline usage.
  move =. (4 2 $ 0 1 0 _1 _1 0 1 0) {~ validMoves i. y
  r =. move shift (robot board)
  a =. r *. (movable board)              NB. normal move
  b =. r *. (lambdas board)              NB. lambda pickup
  c =. (y = 'R') *. (r *. (rocks board) *. (left empty board))
  d =. (y = 'L') *. (r *. (rocks board) *. (right empty board))
  e =. (noLambdasRemain board) *. (r *. lift board) NB. escape!
  z =. (robot board) *. (-. (a *. b *. c *. d *. e)) NB. no move succeeded
  z =. a +. b +. c +. d +. e
  z =. z +. ((robot board) *~ (-. +./ ,z))
  board =: ' ' (robot board) am2d board
  board =: 'R' z am2d board
  board =: '*' ((left d) +. (right c)) am2d board
  board =: 'O' ((noLambdasRemain board) *. (lift board)) am2d board
end.                                    NB. anything else is treated as wait

  NB. Phase 2: update the board
  oldrocks =. rocks board
if. state = <'mining' do.
  board =: ('*' (updaterocks board) am2d (' ' (rocks board) am2d board))
  nMoves =: nMoves + 1
end.
  NB. the lift disappears only if the robot is on the open lift
  done =. (-. +/ ,lift board)
  NB. return condition
if. done do. state =: <'escaped'
elseif. +./ ,((robot board) *. (below rocks board) *. (-. below oldrocks)) do. state =: <'crushed'
end.
  state
)

removeTrailingBlanks =: (#~ (+./\.)@:~:&' ')

main =: 0:0
  input =. splitByLines (snarfStdin '')
  NB. take the non-metadata portion of the board
  metadataSeparator =. {. @: squashInitial @: blankLines input
  board =: removeTrailingBlanks"1 (metadataSeparator {. input)
  maxLambdas =: +/ ,lambdas board
  metadata =: ;: @ , (metadataSeparator }. input)
  route =: metadata mdLookup 'Route'
  NB. simulateStep until condition output
  simulateStep"0 route
  emit board                            NB. emit final board state
  emit ''
  emit 'Number of moves: ',(":nMoves)
  lambdasCollected =. maxLambdas - (lambdaCount board)
  emit 'Lambdas collected: ',(":lambdasCollected)
  emit 'Final state: ',(,>state)
  NB. emit points
  p =. (25 * lambdasCollected)
  points =. p + ((-. state = <'crushed') * p) + ((state = <'escaped') * p) - nMoves
  emit 'Points: ',(":points)
  exit 0
)

try. 0!:111 main catch. exit 1. end