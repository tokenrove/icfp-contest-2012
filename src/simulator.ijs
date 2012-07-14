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
leftAndUpLeft =: left * (1 1 & shift)
rightAndUpRight =: right * (1 _1 & shift)

walls =: '#'&=
lambdas =: '\'&=
earth =: '.'&=
rocks =: '*'&=
robot =: 'R'&=
lift =: 'L'&=
empty =: ' '&=
lambdaCount =: +/ @: , @: lambdas

NB. 1. R and up(E) => down(R), E!
NB. 2. R and up(R) and left(E) and upleft(E) => downright(R), E!
NB. 3. R and up(R) and right(E) and upright(E) => downleft(R), E!
NB. 4. R and up(λ) and left(E) and upleft(E) => downright(R), E!
NB. 5. R => R
NB. R' = R & ~(1 | 2 | 3 | 4) | (1 & down(R)) | ((2|4) & downright(R)) | (3 & downleft(R))
NB. E' = E & R' | (1 | 2 | 3 | 4)
updaterocks =: 3 : 0
  updateRule1 =. rocks * (above @: empty)
  updateRule2 =. rocks * (above @: rocks) * (leftAndUpLeft @: empty)
  updateRule3 =. rocks * (above @: rocks) * (rightAndUpRight @: empty)
  updateRule4 =. rocks * (above @: lambdas) * (leftAndUpLeft @: empty)
  q =. updateRule1 y [ u =. updateRule2 y [ v =. updateRule3 y [ w =. updateRule4 y
  r =. rocks y
  (r * (-. (q + u + v + w))) + (below r * q) + (right @: below r * (u+w)) + (left @: below r * v)
)

am2d =: 1 : '([: $ ]) $ [ (I. , u)} [: , ]'

main =: 0:0
  input =. splitByLines (snarfStdin '')
  board =. ({.~ ({. @: squashInitial @: blankLines)) input
  board =. ('*' (updaterocks board) am2d (' ' (rocks board) am2d board))
  emit board
  exit 0
)

try. 0!:111 main catch. exit 1. end