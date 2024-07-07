S = 1
Ac = 2
A = 3
C = 4
a = 5
c = 6

g_1_rules = [
    (S, Ac, Ac),  #0 
    (Ac, Ac, Ac), #1
    (Ac, A, C),   #2
    (A, a, 0),   #3
    (C, c, 0),   #4
    (S, A, C),  #5
]; 
