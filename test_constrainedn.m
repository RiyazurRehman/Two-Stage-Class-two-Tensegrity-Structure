%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%An double layer tensegrity tower with simplex%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% /* This Source Code Form is subject to the terms of the Mozilla Public
% * License, v. 2.0. If a copy of the MPL was not distributed with this
% * file, You can obtain one at http://mozilla.org/MPL/2.0/.
%
% [1] structure design(calculate equilibrium matrix,
% group matrix,prestress mode, minimal mass design)
% [2] modal analysis(calculate tangent stiffness matrix, material
% stiffness, geometry stiffness, generalized eigenvalue analysis)
% [3] dynamic simulation

%%
%EXAMPLE
clc;clear;close all;
% Global variable
[consti_data,Eb,Es,sigmab,sigmas,rho_b,rho_s]=material_lib('Steel_Q345','Steel_string');
material{1}='linear_elastic'; % index for material properties: linear_elastic, multielastic, plastic.
material{2}=1; % index for considering slack of string (1) for yes,(0) for no (for comparision with ANSYS)

% cross section design cofficient
thick=6e-3;        % thickness of hollow bar
hollow_solid=0;          % use hollow bar or solid bar in minimal mass design (1)hollow (0)solid
c_b=0.1;           % coefficient of safty of bars 0.5
c_s=0.1;           % coefficient of safty of strings 0.3

% dynamic analysis set
amplitude=50;            % amplitude of external force of ground motion
period=0.5;             % period of seismic signal

dt=0.001;               % time step in dynamic simulation
auto_dt=0;              % use(1 or 0) auto time step, converengency is guaranteed if used
tf=2;                   % final time of dynamic simulation
out_dt=0.02;            % output data interval(approximately, not exatly)
lumped=0;               % use lumped matrix 1-yes,0-no
saveimg=0;              % save image or not (1) yes (0)no
savedata=0;             % save data or not (1) yes (0)no
savevideo=1;            % make video(1) or not(0)
gravity=0;              % consider gravity 1 for yes, 0 for no
% move_ground=0;          % for earthquake, use pinned nodes motion(1) or add inertia force in free node(0)
savePath=fullfile(fileparts(mfilename('fullpath')),'data_temp'); %Save files in same folder as this code

%% N C of the structure
% Manually specify node positions of double layer prism.
R=10; h=30; p=3;        % radius; height; number of edge
beta=180*(0.5-1/p); 	% rotation angle

N=[ -338.1 -667.9 -499.0 -413.0 -713.2 -410.2 -510.7 -673.3 -340.8;
    -5.4    2.1   -299.2  88    -94.1  -259.1  121.0 -170.1 -164.3;
    -165.2 -168.5 -164.5  107.7  116.9  133.2  407.9  420.5  416.0
    ];

% Manually specify connectivity indices.
C_b_in = [1 5;2 6;3 4;4 8;5 9;6 7];   % This is indicating the bar connection
C_s_in = [1 2;2 3;1 3; 4 5; 5 6;4 6;7 8;8 9;7 9;
          1 4;2 5;3 6;4 7;5 8;6 9]; % Similarly, this is saying bar 1 connects node 1 to node 2,

% % Manually specify connectivity indices.
% C_s_in = [4 5;5 6;6 4;7 8;8 9;9 7;1 4;2 5;3 6;4 7;5 8;6 9];  % This is indicating that string connection
% C_b_in = [1 5;2 6;3 4;5 9;6 7;4 8];  % Similarly, this is saying bar 1 connects node 1 to node 2,

% Convert the above matrices into full connectivity matrices.
C_b = tenseg_ind2C(C_b_in,N);%%
C_s = tenseg_ind2C(C_s_in,N);
C=[C_b;C_s];
[ne,nn]=size(C);        % ne:No.of element;nn:No.of node

% Plot the structure to make sure it looks right
tenseg_plot(N,C_b,C_s);
title('Double layer prism');

%% Boundary constraints
pinned_X=(1:3)'; pinned_Y=(1:3)'; pinned_Z=(1:3)';
[Ia,Ib,a,b]=tenseg_boundary(pinned_X,pinned_Y,pinned_Z,nn);

%% Group information
%generate group index
gr={(1:3);(4:6);(7:9);(10:12);(13:15);(16:18);(19:21)};     % number of elements in one group
% gr=[];                     %if no group is used
Gp=tenseg_str_gp(gr,C);    %generate group matrix

%% self-stress design
%Calculate equilibrium matrix and member length
[A_1a,A_1ag,A_2a,A_2ag,l,l_gp]=tenseg_equilibrium_matrix1(N,C,Gp,Ia);

%SVD of equilibrium matrix
[U1,U2,V1,V2,S1]=tenseg_svd(A_1ag);

%external force in equilibrium design
w0=zeros(numel(N),1); w0a=Ia'*w0;

%prestress design
index_gp=[1,2];                 % number of groups with designed force
fd=-0*ones(2,1);                 % force in bar is given as -1000
[q_gp,t_gp,q,t]=tenseg_prestress_designn(Gp,l,l_gp,A_1ag,V2,w0a,index_gp,fd);    %prestress design

%% cross sectional design
index_b=find(t<0);              % index of bar in compression
index_s=setdiff(1:ne,index_b);	% index of strings
[A_b,A_s,A_gp,A,r_b,r_s,r_gp,radius,E,l0,rho,mass]=tenseg_minimass(t,l,Gp,sigmas,sigmab,Eb,Es,index_b,index_s,c_b,c_s,rho_b,rho_s,thick,hollow_solid);

r_s = 0.00079375*ones(15,1);
r_b = 0.003175*ones(6,1);
A_b = pi*(r_b.^2);
A_s = pi*(r_s.^2);

% Plot the structure with radius
R3Ddata.Bradius=interp1([min(radius),max(radius)],[0.3,1],r_b);
R3Ddata.Sradius=interp1([min(radius),max(radius)],[0.3,1],r_s);
R3Ddata.Nradius=ones(nn,1);
tenseg_plot(N,C_b,C_s,[],[],[],'Double layer prism',R3Ddata);

%% input file of ANSYS
ansys_input_gp(N,C,A_gp,t_gp,b,Eb,Es,rho_b,rho_s,Gp,index_s,find(t_gp>0),'test_c');

%% mass matrix and damping matrix
M=tenseg_mass_matrix(mass,C,lumped); % generate mass matrix
% damping matrix
d=0;     %damping coefficient
D=d*2*max(sqrt(mass.*E.*A./l0))*eye(3*nn);    %critical damping

%% free vibration mode analysis
num_plt=10:13;        % number of modes to plot
[V_mode,omega]=tenseg_mode(Ia,C,C_b,C_s,N(:),E,A,l0,M,num_plt,saveimg,100);