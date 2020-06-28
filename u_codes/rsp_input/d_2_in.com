%chk=d-kynurenine_r_o_o_cap_2.chk
# opt hf/6-311g geom=connectivity iop(6/33=2,6/42=6) pop=mk scf=tight
test

Title Card Required

0 1
 C              
 C                  1            B1
 C                  2            B2    1            A1
 C                  3            B3    2            A2    1            D1    0
 C                  4            B4    3            A3    2            D2    0
 C                  1            B5    2            A4    3            D3    0
 H                  1            B6    6            A5    5            D4    0
 H                  4            B7    3            A6    2            D5    0
 H                  5            B8    4            A7    3            D6    0
 H                  6            B9    1            A8    2            D7    0
 N                  2           B10    1            A9    6            D8    0
 H                 11           B11    2           A10    1            D9    0
 H                 11           B12    2           A11    1           D10    0
 C                  3           B13    2           A12    1           D11    0
 C                 14           B14    3           A13    2           D12    0
 H                 15           B15   14           A14    3           D13    0
 H                 15           B16   14           A15    3           D14    0
 C                 15           B17   14           A16    3           D15    0
 H                 18           B18   15           A17   14           D16    0
 C                 18           B19   15           A18   14           D17    0
 N                 18           B20   15           A19   14           D18    0
 H                 21           B21   18           A20   15           D19    0
 O                 20           B22   18           A21   15           D20    0
 O                 20           B23   18           A22   15           D21    0
 O                 14           B24    3           A23    2           D22    0
 C                 21           B25   18           A24   15           D23    0
 C                 23           B26   20           A25   18           D24    0
 O                 26           B27   21           A26   18           D25    0
 O                 27           B28   23           A27   20           D26    0
 C                 27           B29   23           A28   20           D27    0
 H                 30           B30   27           A29   23           D28    0
 H                 30           B31   27           A30   23           D29    0
 H                 30           B32   27           A31   23           D30    0
 C                 26           B33   21           A32   18           D31    0
 H                 34           B34   26           A33   21           D32    0
 H                 34           B35   26           A34   21           D33    0
 H                 34           B36   26           A35   21           D34    0

   B1             1.40979574
   B2             1.41682791
   B3             1.40519922
   B4             1.37366791
   B5             1.37158549
   B6             1.07346981
   B7             1.07082933
   B8             1.07141686
   B9             1.07347028
   B10            1.35895734
   B11            0.98945092
   B12            0.99157265
   B13            1.47141816
   B14            1.51751538
   B15            1.08443800
   B16            1.08106653
   B17            1.52554394
   B18            1.08200156
   B19            1.51672465
   B20            1.44562377
   B21            0.99546300
   B22            1.35164488
   B23            1.21320431
   B24            1.23291453
   B25            1.47000000
   B26            1.43000000
   B27            1.43000000
   B28            1.43000000
   B29            1.54000000
   B30            1.07000000
   B31            1.07000000
   B32            1.07000000
   B33            1.54000000
   B34            1.07000000
   B35            1.07000000
   B36            1.07000000
   A1           118.40970662
   A2           118.35298458
   A3           122.55892444
   A4           121.35007008
   A5           120.16269957
   A6           119.22890127
   A7           120.67133536
   A8           119.37737174
   A9           118.64652316
   A10          120.02867465
   A11          120.08613958
   A12          121.12604020
   A13          119.88219210
   A14          108.37782438
   A15          110.78221734
   A16          111.44739607
   A17          108.34801122
   A18          110.87061177
   A19          110.46797651
   A20          116.81889169
   A21          112.16386496
   A22          126.57484197
   A23          121.69014160
   A24          116.34831781
   A25          113.66704589
   A26          109.47120255
   A27          109.47120255
   A28          109.47120255
   A29          109.47120255
   A30          109.47120255
   A31          109.47123134
   A32          109.47120255
   A33          109.47120255
   A34          109.47120255
   A35          109.47123134
   D1             1.26750631
   D2            -0.62200626
   D3            -1.01185479
   D4           179.62892331
   D5           178.70654017
   D6           179.67317383
   D7          -179.70399499
   D8           179.30234859
   D9             1.24712594
   D10         -177.50380225
   D11         -179.42060565
   D12          174.86846949
   D13           78.78849718
   D14          -38.14888260
   D15         -159.56621720
   D16           99.02921975
   D17          -17.32000000
   D18         -143.70052499
   D19           63.12690137
   D20         -170.44562847
   D21           11.16341386
   D22           -7.25306626
   D23         -157.99104282
   D24         -178.20319232
   D25          137.79797365
   D26           60.27077440
   D27         -179.72921080
   D28           63.99683208
   D29         -176.00315312
   D30          -56.00316052
   D31         -102.20201155
   D32            0.27995819
   D33          120.27997299
   D34         -119.72003441

 1 2 1.5 6 2.0 7 1.0
 2 3 1.5 11 1.5
 3 4 1.5 14 1.0
 4 5 2.0 8 1.0
 5 6 1.5 9 1.0
 6 10 1.0
 7
 8
 9
 10
 11 12 1.0 13 1.0
 12
 13
 14 15 1.0 25 2.0
 15 16 1.0 17 1.0 18 1.0
 16
 17
 18 19 1.0 20 1.0 21 1.0
 19
 20 23 1.0 24 2.0
 21 22 1.0 26 1.0
 22
 23 27 1.0
 24
 25
 26 28 1.0 34 1.0
 27 29 1.0 30 1.0
 28
 29
 30 31 1.0 32 1.0 33 1.0
 31
 32
 33
 34 35 1.0 36 1.0 37 1.0
 35
 36
 37

