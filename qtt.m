function tto=qtt(A,varargin)
%QTT  QTT Decomposition Function
%
%  -----------------------------------------------------------------------
%  tto=QTT(A,scale,chop_value,exmethod)
%  A: multidimensional array contain vector and matrix.
%  scale: scale matrix, the subscale of all QTT core. If it dose not match 
%  the scale of lt,lt will be extended by extype. If scale=q,then
%  n^i_j=q, for i>=2. 
%                ----------------------------
%                    1      2   ...    l
%                1   n^1_1  .   ...   n^1_l
%                2   n^2_1  .   ...   n^2_l
%                .   ...
%                .   ...
%                d   n^d_1  .   ...   n^d_l
%               ----------------------------
%  
%
%  chop_value�� chop calue.
%   If chop by QTT-rank��then  chop_value = r, and length(r)=d+1
%   If chop by norm, then chop_value=epss,and ||A-tto||\leq epss*||A||.
%
%  exmethod��extend method
%   only support 'sym'.
%
%  tto: struct,use qtt2ltcore,it will be converted into ltcore. In fact,
%  qtt+qtt2core =gqtt,for array.
%  -----------------------------------------------------------------------
%  Example:    
%    A=mat2gray(imread(I));
%    t=qtt(A);
%
%  see alse gqtt,qtt2ltcore

%  JSong,12-Jul-2015
%  Last Revision: 11-Aug-2015.
%  Github:http://github.com/gasongjian/QTT/
%  gasongjian@126.com

if nargin==1
   scale=2;
    chop_value=1e-14;
    exmethod='sym';
elseif nargin==2
    scale=varargin{1};
    chop_value=1e-14;
    exmethod='sym';
elseif nargin==3
    scale=varargin{1};
    chop_value=varargin{2};
    exmethod='sym';
elseif nargin==4
        scale=varargin{1};
    chop_value=varargin{2};
    exmethod=varargin{3};
end
    

% basic info
ndim=ndims(A);
oldsize=size(A);
if isvector(A)
    A=A(:);
    ndim=1;
    oldsize=size(A,1);
end

if any(oldsize==1)
    error('Please check the array.');
end

%% scale 
if length(scale)<=1
    if isempty(scale)
        q=2;
    else
        q=scale;
    end
    
    d=min(floor(log(oldsize)*(1+eps)/log(q)));
    last_size=fix(oldsize*(1-eps)/q^(d-1))+1;last_size=last_size(:);
    scale=[last_size';q*ones(d-1,ndim)];
elseif (size(scale,2)==ndim)&&(size(scale,1)>1)&&(all(prod(scale)>=oldsize))
    d=size(scale,1);
    %last_size=scale(1,:);
else
    error('scale');
end


%% chop value
if (length(chop_value)==1)&&(chop_value<1)
    cut_method='epss';
    epss=chop_value;
    ep=epss/sqrt(d-1);
elseif (length(chop_value)==d+1)
    cut_method='r';
    cut_r=chop_value(end:-1:1);
elseif isempty(chop_value)
    cut_method='epss';
    epss=1e-14;
    ep=epss/sqrt(d-1);
else
    error('cut_value');
end




%% extend
newsize=prod(scale);
extension=0;
if ~isequal(oldsize,newsize)
    extension=1;
    switch exmethod
        case 'sym'
            index=cell(ndim,1);
            for j=1:ndim
                temp=1:oldsize(j);
                temp=[temp temp(end:-1:2*end-newsize(j)+1)];
                index{j}=temp;
            end
            temp=sprintf('index{%d},',[1:ndim]);
            temp(end)=[];
            temp=['A=A(',temp,');'];
            eval(temp)
            
    end
end


%% Fold/Unfold
scale=scale(end:-1:1,:);
n=prod(scale,2); 
A = reshape(A, (scale(:))'); % converted into tensor of ndim*d
if ndim>1
    prm=1:ndim*d; prm=reshape(prm,[d,ndim]); prm=prm';
    prm=prm(:); % Transposed permutation
    A=permute(A,prm);
    A=reshape(A,n');
end



%% SVD Fold

% from tt_svd alg
% A: input tensor
% n: scale of A 
% core: all TT core, be stored as vector and the ith QTT core 
% :=core(ps(i):ps(i+1)-1)


d = numel(n);
r = ones(d+1,1);
core=[];
c=A;clear A
%%==============�� modification��======================================

for i=1:d-1
    % m=n(i)*r(i); c=reshape(c,[m,numel(c)/m]);
    % ===============��part one��=====================
    m=n(i)*r(i); c=reshape(c,[r(i),n(i),numel(c)/m]);
    c=permute(c,[2 1 3]);
    c=reshape(c,[m,numel(c)/m]);
    %=================================================
    [u,s,v]=svd(c,'econ');
    %[u,s,v]=psvd(c);
    s=diag(s);
    switch cut_method
        case {'epss'}
            r1=my_chop2(s,ep*norm(s));
        case {'r'}
            r1=min(length(s),cut_r(i+1));
    end
    u=u(:,1:r1); s=s(1:r1);
    r(i+1)=r1;
    
    u=reshape(u,[n(i),r(i),r1]);
    u=permute(u,[3,1,2]);
    core=[u(:);core];
    % ================================================
    %core(pos:pos+r(i)*n(i)*r(i+1)-1)=u(:);
    v=v(:,1:r1);
    v=v*diag(s); c=v';
    %pos=pos+r(i)*n(i)*r(i+1);
end
%%==================��end  modification��================================
c=reshape(c,[r(d),n(d),1]);
c=permute(c,[3,2,1]);
core=[c(:);core];
r=r(end:-1:1);n=n(end:-1:1);
ps=cumsum([1;n.*r(1:d).*r(2:d+1)]);
tto=struct; 
tto.d=d;
tto.n=n;
tto.r=r;
tto.ps=ps;
tto.core=core;
tto.oldsize=oldsize;
tto.scale=scale(end:-1:1,:);
tto.ndim=ndim;
tto.isextension=extension;
tto.ex_method=exmethod;


end




function [r] = my_chop2(sv,eps)
% from TT-toolbox

if (norm(sv)==0)
    r = 1;
    return;
end;
% Check for zero tolerance
if ( eps <= 0 )
    r = numel(sv);
    return
end

sv0=cumsum(sv(end:-1:1).^2);
ff=find(sv0<eps.^2);
if (isempty(ff) )
    r=numel(sv);
else
    r=numel(sv)-ff(end);
end
return
end









