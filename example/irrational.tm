# A program that generates 101001000100001000001...

# 1. Initialize tape to `1111`
<0, 0, 1, R, 1>
<1, 0, 1, R, 2>
<2, 0, 1, R, 3>
<3, 0, 1, L, 4>

# 2. Go left until two `1`s are found, then make the second `1` turn into `0`, and go left again
<4, 0, 0, L, 4>
<4, 1, 1, L, 5>
<5, 0, 0, L, 5>
<5, 1, 0, L, 6>

# 3. Case `0`: Turn it `1` and go right until two `1`s are found. Write `01` from there and go back to 2.
<6, 0, 1, R, 7>
<7, 0, 0, R, 7>
<7, 1, 1, R, 8>
<8, 0, 0, R, 8>
<8, 1, 0, R, 9>
<9, 0, 1, L, 4>

# 3. Case `1`: Go right until two `1`s are found, and write `0111` from there (last three `1`s are done in step 1.)
<6 , 1, 1, R, 10>
<10, 0, 0, R, 10>
<10, 1, 1, R, 11>
<11, 0, 0, R, 11>
<11, 1, 0, R, 1 >
