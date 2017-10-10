globals [traveller-vision max-traveller-vision bus-vision traveller-speed]
;globals nbusses ntravellers nbusstops secondline?

breed [busses bus]
breed [travellers traveller]
breed [busstops busstop]

busses-own [freeseats speed speed-limit speed-min nearbusstops waitingtravellers]
travellers-own[possible-busstops my-busstop happiness updown on-bus]

;;SETTING UP THE ENVIRONMENT
to setup
  clear-all
  basic-setup
  setup-busses
  setup-travellers
  setup-busstops
  ask patches [setup-road]
  reset-ticks
end


to basic-setup ;this are variables that can be changed, but are not relevant to show to the end user
  set traveller-speed 10
  set max-traveller-vision 10
  set bus-vision 10
end


to setup-busses
  set-default-shape busses "bus"
  create-busses nbusses
  [
    set color yellow
    set size 2.5
    set xcor random-xcor
    if xcor > 10 ;Busses cannot be placed on the end of the road: it will make that they can't look further and the model will keep running forever
    [
      set xcor 10
    ]
    set speed 0.1 + random-float 0.9
    set speed-limit 1
    set speed-min 0
    set heading 90
    set freeseats 30
  ]

  if secondline?
  [
    create-busses nbusses
    [
    set color yellow
    set size 2.5
    set ycor random-ycor
    if ycor < -10 ;Busses cannot be placed on the end of the road: it will make that they can't look further and the model will keep running forever
    [
      set ycor -10
    ]
    set speed 0.1 + random-float 0.9
    set speed-limit 1
    set speed-min 0
    set heading 180
    set freeseats 30
    ]
  ]
end


to setup-travellers
  set-default-shape travellers "person"
  create-travellers ntravellers
  [
   setxy random-xcor random-ycor
   set on-bus 0
  ]
  set traveller-vision random max-traveller-vision
end


to setup-busstops
  set-default-shape busstops "house"
  create-busstops nbusstops
  [
    set xcor random-xcor
    if xcor > 10 ;Busstops cannot be placed on the end of the road: it will make that the busses can't look further and the model will keep running forever
    [
      set xcor 10
    ]
  ]

  if secondline?
  [
    create-busstops nbusstops
    [
       set ycor random-ycor
       if ycor < -10 ;Busstops cannot be placed on the end of the road: it will make that the busses can't look further and the model will keep running forever
       [
          set ycor -10
       ]
    ]
  ]
end


to setup-road ;; patch procedure
  if (pycor < 2) and (pycor > -2) [ set pcolor white ]

  if secondline?
  [
     if (pxcor < 2) and (pxcor > -2) [ set pcolor brown ]
  ]
end



to go
  ask travellers
  [
    travellers-to-bus
  ]

  ask busses
  [
    busses-move
  ]

  tick


 ;if there are busses that are not black, the model should be finished
  if not any? busses with [color != black]
  [
    stop
  ]
end


;;THE TRAVELLERS PART
to travellers-to-bus

  set possible-busstops busstops in-radius bus-vision

  ifelse any? possible-busstops
    [
      find-best-busstop
      move-to min-one-of possible-busstops [distance myself]
    ]
    [
      ;if there are no busstops in vision, move randomly
      rt random-float 360
      fd traveller-speed
    ]
end

to find-best-busstop
  set my-busstop min-one-of possible-busstops [distance myself]
end


;;THE BUSSES PART
to busses-move

  ifelse freeseats > 0
  [
    ;if the bus is not full, it will drive forward and check for a busstop

    fd 2
    check-for-busstop
  ]
  [
    ;if the bus is full, it will become black, it is not relevant anymore
    set color black
  ]

end

to check-for-busstop
  ifelse any? busstops in-cone 50 30
  [
    ;the bus identifies all stop within a radius
    set nearbusstops busstops in-cone 50 30

    ;the bus will move to the closest busstop
    move-to min-one-of nearbusstops [distance myself]

    set waitingtravellers travellers in-radius 2

    if count waitingtravellers > 0
    [
      ;the bus will take the passengers
      take-passengers
    ]


  ]
  [
    ;if there is no busstop in the vision, the bus must have visited all the stops and will become black (it will be irrelevant for the model)
     set color black
  ]
end

to take-passengers

  set waitingtravellers travellers in-radius 2

  ;it will see if all traveleers waiting at the stop can fit in the bus
  ifelse (count waitingtravellers) < freeseats
  [
    ;if everyone fits, the bus will take them on board
    set freeseats freeseats - count waitingtravellers
    set color green

    ;and the travellers are not relevant for the model anymore, they die
    ask waitingtravellers
    [
      set on-bus 1
      die
    ]

  ]
  [
    ;if, however, the bus can take only a part of them
    ; there will be a random selection (the number of freeseats available)
    ask n-of freeseats waitingtravellers [set on-bus 1 die]
    set freeseats 0
    set color black
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
236
13
675
473
16
16
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
31
41
94
74
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
116
42
179
75
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
116
192
149
nbusses
nbusses
1
10
3
1
1
NIL
HORIZONTAL

SLIDER
20
164
192
197
ntravellers
ntravellers
1
100
50
1
1
NIL
HORIZONTAL

SLIDER
21
212
193
245
nbusstops
nbusstops
1
5
3
1
1
NIL
HORIZONTAL

MONITOR
21
344
194
389
Travellers that were not served
count travellers with [on-bus = 0]
17
1
11

MONITOR
20
397
195
442
Travellers that were  served
ntravellers - count travellers with [on-bus = 0]
17
1
11

SWITCH
22
257
193
290
secondline?
secondline?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This model shows how travellers take their busses. This can be used in city planning in order to decide on the number of busstops and/or busses, depending on the number of travellers and with as core question whether or not adding a new line will work better then just adding more busses and/or more busstops.
The model monitors the number of people that have been able to transport themselves by bus, which could be used by city planners as an indicaton of the goodness of their planning and willingness of daily commuters to go by bus. In this model, every traveller is moving towards a busstop, so if it not possible for them to get on the bus, this should be interpreted as somebody that would not take the bus in real-life.

## HOW IT WORKS

Travellers are located in a random place in the world.

Busstops are located on a random xcoordinate on the road, to spread-out geographical locations of busstops.

Busses are located on a random xcoordinate on the road, to simulate spread-out departure times

Travellers look in a circle around them, in order to find the nearest busstop. When they find a busstiop in their vision, they will go there. Else they will make a random move, and check again if there is a busstop in their vision.

Busses will start moving to the right. Traffic for busses is simulated by calculating the speed of a bus, using a random factor. Each time a bus comes sees a busstop, it will go there. The world does not wrap horizontally, in order to simulate that a bus has visited all the stops. The bus will then become black (to simulate invisible): it is no longer important for the model.

The optional second bus line works the same, only from up to down.

## HOW TO USE IT

Sliders:
nbusses: the number of busses in the simulation (between 1 and 10)
ntravellers: the number of travellers in the simulation (between 1 and 100)
nbusstops: the number of busstops (between 1 and 5)

World:
The road is a lane of white patches going from left to right.
Travellers have the shape "person" and a random color.
Busstops have the shape "house" and a random color.
Busses have the shape "bus" and a color depending on their state: yellow when empty, green when having people, black when they are full or have finished the route.

Monitors:
Travellers that were served: number of travellers that has found a place in a bus.
Travellers that were not served: number of travellers that has not found a place in a bus (and is therefore waiting until eternity).

Switches:
secondline?: switching on the secondline includes a second busline in the model.


## THINGS TO NOTICE

From the model it seams that having many busses and many busstops gives a slight improvement to the number of served passengers, but it even more suggests that just adding busstops and busses on a line is likely to be not the most efficient solution. It would often be better for cityplanners to investigate the benefits of adding a new busline, because in the one-line system, the reason for many travellers to not be on a bus, is that they live to far away from a busstop to make it there before the bus leaves.

## THINGS TO TRY

Try to put ntravellers low and nbusses and nbusstops high. Then compare with ntravellers high and nbusses and nbusstops low. It can be noticed that many travellers will just not be able to use the bus, because they live too far from any busstop to make it on time.

Now try doing this with the secondline? switched on.

## EXTENDING THE MODEL

The model could be extended by:
- including buslines that are not of the Express type, i.e. busses in which a traveller can also go out at any stop they want.
- including clustered location of travellers: they probably will all live in clusters of cities or neighborhoods
- including traveller happiness, by measuring the distance they have to walk and the total travel time
- wrapping the word horizontally, but emptying the bus as soon as it goes from the right to the left side. In this way, you can simulate a new bus. You would also need to create new travellers in this case.
- including the costs of a bus and the price a person pays, to simulate if a busline would be profitable.
- including traffic aspects: e.g. a traveller that has no busstop in its vision will take the car, thereby adding traffic and a longer travel time for everybody.
- including costs that would be generated from all people going by car and the needs for road works / building bigger roads.

## NETLOGO FEATURES

## RELATED MODELS

Model library:
- Flocking: has related features for vision
- Traffic basic: has comparable way of simulating traffic

## CREDITS AND REFERENCES

Made by Joos Korstanje in January 2017.
Contact: joos.korstanje@edu.dsti.institute
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 false 60 135 60 165
Line -7500403 false 60 120 60 165
Line -7500403 false 90 120 90 165
Line -7500403 false 120 120 120 165
Line -7500403 false 150 120 150 165
Line -7500403 false 180 120 180 165
Line -7500403 false 210 120 210 165
Line -7500403 false 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 false 257 120 257 207

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
