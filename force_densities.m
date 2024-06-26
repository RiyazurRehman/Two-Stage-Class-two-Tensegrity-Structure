clc; clear
syms x
N=[ -338.1 -667.9 -499.0 -413.0 -713.2 -410.2 -510.7 -673.3 -340.8;
    -5.4    2.1   -299.2  88    -94.1  -259.1  121.0 -170.1 -164.3;
    -165.2 -168.5 -164.5  107.7  116.9  133.2  407.9  420.5  416.0
    ];

C_b_in = [1 5;2 6;3 4;4 8;5 9;6 7];   % This is indicating the bar connection
C_s_in = [ 1 2;2 3;1 3;4 5; 5 6;4 6;7 8;8 9;7 9;
          1 4;2 5;3 6;4 7;5 8;6 9]; % Similarly, this is saying bar 1 connects node 1 to node 2,

q = [x; x; x; x; x; x; 120.1201201; 118.3431953; 114.6131805; 169.4915254; 163.9344262; 158.7301587; 114.9425287; 115.942029;
116.2790698; 161.8122977; 154.7987616; 156.25; 119.4029851; 119.760479; 119.4029851];

Q= diag(q);

n1 = [-338.1; -667.9; -499; -413; -713.2; -410.2; -510.7; -673.3;-340.8];
n2 = [-5.4; 2.1;-299.2;88; -94.1; -259.1; 121.0; -170.1; -164.3];
n3 = [-165.2; -168.5; -164.5;  107.7;  116.9;  133.2;  407.9;  420.5; 416.0];
C =[ 1     0     0     0    -1     0     0     0     0
     0     1     0     0     0    -1     0     0     0
     0     0     1    -1     0     0     0     0     0
     0     0     0     1     0     0     0    -1     0
     0     0     0     0     1     0     0     0    -1
     0     0     0     0     0     1    -1     0     0
     1    -1     0     0     0     0     0     0     0
     0     1    -1     0     0     0     0     0     0
     1     0    -1     0     0     0     0     0     0
     0     0     0     1    -1     0     0     0     0
     0     0     0     0     1    -1     0     0     0
     0     0     0     1     0    -1     0     0     0
     0     0     0     0     0     0     1    -1     0
     0     0     0     0     0     0     0     1    -1
     0     0     0     0     0     0     1     0    -1
     1     0     0    -1     0     0     0     0     0
     0     1     0     0    -1     0     0     0     0
     0     0     1     0     0    -1     0     0     0
     0     0     0     1     0     0    -1     0     0
     0     0     0     0     1     0     0    -1     0
     0     0     0     0     0     1     0     0    -1
     ];
D = (transpose(C)*Q*C);
D_rank = rank(D);
%%

f1 = transpose(C)*Q*C*n1;
simplify(f1);
y=solve(f1==0,x);
w1 =[ (- 24691202202668656997/351843720888320)*(10/3751);
+ (37007905892113981237/703687441776640)*(-10/2577);
         + (8675125672132915171/703687441776640)/(-86);
   (- 17586149119444258233/351843720888320)*(10/3463);
  + (19763820742618691153/175921860444160)*(-2/1495);
      (- 979972871677975013/17592186044416)*(5/1791);
    + (4479614594557136957/351843720888320)*(-2/201);
 + (36916806024974035379/703687441776640)*(-10/2603);
  - (46860732237465139333/703687441776640)*(5/ 1862)]

%%

f2 = transpose(C)*Q*C*n2;
simplify(f2);
y2=solve(f2==0,x);
w2 = [
    (- 12426545256337862667/703687441776640)*(10/887);
  (- 18102129513547933889/351843720888320)*(5/1306);
 (+ 53195802567682098841/703687441776640)*(-5/1936);
   (- 1708775033303992315/17592186044416)*(10/6453);
    (+ 844870972467354187/87960930222080)*(-2/37);
  (+ 7670034468613812977/87960930222080)*(-10/6413);
    (- 4966238037133208491/70368744177664)*(10/3801);
  (+ 1521162208157703995/35184372088832)*(-10/2581);
  (+ 7452947863719995951/351843720888320)*(-5/351)]


%%

f3 = transpose(C)*Q*C*n3;
simplify(f3);
y3=solve(f3==0)

w3=[
 + (30851352540709433253/703687441776640)*(-10/2821);
+ (31700651819329810627/703687441776640)*(-10/3017);
  (4042862297304531043/87960930222080)*(-5/1361);
  (-95239128434841673/35184372088832)*(-5/203) ;
  (-2359983321652252803/351843720888320)*(1/-17);
   (- 6849767799963489253/351843720888320)*(1/27);
   (- 1471350618527189749/43980465111040)*(10/2747);
   (- 26971844540439494469/703687441776640)*(5/1564);
   (-24057163489672644199/703687441776640)*(10/2991)]

%%
q_b = -88;
q_t = q_b;
q_c = q_t;


q_l = sqrt(3)*q_b;
q_s = - q_l;

D2 = [2*q_t     -q_t     -q_t     -q_l     q_l      0       0        0      0
     -q_t     2*q_t     -q_t       0     -q_l     q_l      0        0      0
     -q_t      -q_t    2*q_t      q_l     0      -q_l      0        0      0
     -q_l       0        q_l     2*q_c   -q_c    -q_c     -q_l      q_l    0
      q_l      -q_l       0      -q_c   2*q_c    -q_c      0       -q_l    q_l
      0         q_l     -q_l     -q_c    -q_c   2*q_c      q_l      0     -q_l
      0         0        0       -q_l     0       q_l    2*q_b     -q_b   -q_b
      0         0        0        q_l    -q_l     0       -q_b    2*q_b   -q_b
      0         0        0         0      q_l    -q_l     -q_b     -q_b   2*q_b];

eqn = @(x) D2*x==0;
D2_rank = rank(D2);