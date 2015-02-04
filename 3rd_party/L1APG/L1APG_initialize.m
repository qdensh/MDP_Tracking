function [model, para] = L1APG_initialize(img, x1, y1, x2, y2)

init_pos = [y1, y2, y1; x1 x1 x2];
sz_T = [12 15];

% parameters setting for tracking
para.lambda = [0.2,0.001,10]; % lambda 1, lambda 2 for a_T and a_I respectively, lambda 3 for the L2 norm parameter
% set para.lambda = [a,a,0]; then this the old model
para.angle_threshold = 40;
para.Lip	= 8;
para.Maxit	= 5;
para.nT		= 10; % number of templates for the sparse representation
para.rel_std_afnv = [0.03,0.0005,0.0005,0.03,1,1]; % diviation of the sampling of particle filter
para.n_sample	= 600;		% number of particles
para.sz_T		= sz_T;
para.init_pos	= init_pos;
para.bDebug		= 0;		% debugging indicator

% generate the initial templates for the 1st frame
if(size(img,3) == 3)
    img = rgb2gray(img);
end
[T, T_norm, T_mean, T_std] = InitTemplates(sz_T, para.nT, img, init_pos);
norms = T_norm .* T_std; % template norms

% get affine transformation parameters from the corner points in the first frame
aff_obj = corners2affine(init_pos, sz_T);
map_aff = aff_obj.afnv;

dim_T	= size(T,1);	% number of elements in one template, sz_T(1)*sz_T(2)=12x15 = 180
A		= [T eye(dim_T)]; % data matrix is composed of T, positive trivial T.
fixT = T(:,1)/para.nT; % first template is used as a fixed template
%Temaplate Matrix
Temp = [A fixT];
Dict = Temp'*Temp;
Temp1 = [T,fixT]*pinv([T,fixT]);

% build model
model.T = T;
model.T_mean = T_mean;
model.norms = norms;
model.occlusionNf = 0;
model.map_aff = map_aff;
model.A = A;
model.fixT = fixT;
model.Temp = Temp;
model.Dict = Dict;
model.Temp1 = Temp1;
model.Lambda = para.lambda;