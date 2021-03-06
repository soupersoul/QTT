function lt1=lktimes(lt1,lt2,type)
%LKTIMES  layer general product of layer_tensor
%   outer layer use kronecker produce
%   inner layer produce use general product
%
%  Example:
%       a=layer_tensor(floor(10*rand(2,2,2,2)));
%       b=layer_tensor(floor(10*rand(2,2,2,2)));
%       c=layer_tensor(floor(10*rand(2,2,2,2)));
%       d=layer_tensor(floor(10*rand(2,2,2,2)));
%       e1=lktimes(lkron(a,b),lkron(c,d),[2;1]);
%       e2=lkron(lktimes(a,c,[2;1]),lktimes(b,d,[2;1]));
%       isequal(e1,e2)
%
%  see also lkron

%  JSong,20-Jul-2015
%  Last Revision: 11-Aug-2015.
%  Github:http://github.com/gasongjian/QTT/
%  gasongjian@126.com 

r1=lt1.size;s1=lt1.subsize;lt1=lt1.dat;
r2=lt2.size;s2=lt2.subsize;lt2=lt2.dat;
if (nargin==2)&&(s1(end)==s2(1))
    type=[numel(s1);1];
end

if ~isequal(s1(type(1,:)),s2(type(2,:)))
    disp('Invalid type ');
    return
end

%% get new subsize
s11=s1;s11(type(1,:))=[];ns1=length(s11);
s22=s2;s22(type(2,:))=[];ns2=length(s22);
s=[s11;s22];
if isempty(s),s=1;end
%% get new size
r=r1.*r2;

%%
lt1=reshape(lt1,[r1(1),s1',r1(2)]);
lt2=reshape(lt2,[r2(1),s2',r2(2)]);
type=type+1;
lt1=gtimes(lt1,lt2,type);
%matlab 最后一维是1是有bug,所以这里要加以区分
if (r1(2)==1)&&(r2(2)==1)
    ind=[ns1+2,1,2:ns1+1,ns1+3:ns1+ns2+2];
elseif (r1(2)==1)&&(r2(2)>1)
    ind=[ns1+2,1,2:ns1+1,ns1+3:ns1+ns2+2,ns1+ns2+3];
elseif (r1(2)>1)&&(r2(2)==1)
    ind=[ns1+3,1,2:ns1+1,ns1+4:ns1+ns2+3,ns1+2];
else
    ind=[ns1+3,1,2:ns1+1,ns1+4:ns1+ns2+3,ns1+ns2+4,ns1+2];
end
lt1=permute(lt1,ind);
lt1=layer_tensor(lt1,r,s);

end

function B=gtimes(A1,A2,type)
% general tensor product


if isequal(type,[2;1])&&ismatrix(A1)&& ismatrix(A2) && size(A1,2)==size(A2,1)
    B=A1*A2;
    return
end

s1=size(A1);s2=size(A2);s11=s1;s22=s2;
s11(type(1,:))=[];s22(type(2,:))=[];
s=[s11(:);s22(:)];
if isempty(s)
    s=1;
end


ind1=[1:numel(s1)];ind1(type(1,:))=[];
ind1=[ind1,type(1,:)];
A1=permute(A1,ind1);
A1=reshape(A1,[prod(s11),numel(A1)/prod(s11)]);

ind2=[1:numel(s2)];ind2(type(2,:))=[];
ind2=[type(2,:),ind2];
A2=permute(A2,ind2);
A2=reshape(A2,[numel(A2)/prod(s22),prod(s22)]);
B=A1*A2;
if numel(s)>1
B=reshape(B,s');
else
    B=B(:);
end
end





    


