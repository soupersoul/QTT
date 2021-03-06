function lt1=udiag(lt)
%UDIAG  inner layer diag operation of lt 
%
%  LT1=UDIAG(LT)  LT1(i,j)=diag(LT1(i,j))
%
%  Example:
%    lt=layer_tensor(rand(2,4,4,5));
%    lt1=udiag(lt);
%    
%
%  see also layer_tensor, 

%  JSong,20-Jul-2015
%  Last Revision: 11-Aug-2015.
%  Github:http://github.com/gasongjian/QTT/
%  gasongjian@126.com 


r=lt.size;
subsize=lt.subsize;subsize=subsize(:);
l=numel(subsize);
lt=lt.dat;
lt=reshape(lt,[r(1),numel(lt)/r(1)]);
ind1=ones(1,r(1));ind2=prod(subsize)*ones(1,r(2));
lt=mat2cell(lt,ind1,ind2);
if l==1
   lt=cellfun(@(x)diag(x),lt,'UniformOutput',false);
   lt=cellfun(@(x)(x(:))',lt,'UniformOutput',false);
   lt=cell2mat(lt);
   subsize=[subsize;subsize];
elseif l==2
    lt=cellfun(@(x)reshape(x,subsize'),lt,'UniformOutput',false);
   lt=cellfun(@(x)(diag(x))',lt,'UniformOutput',false);
   lt=cell2mat(lt);
   subsize=min(subsize);
else
    disp('numel(subsize)>2')
end
lt1=layer_tensor;
lt1.size=r;
lt1.dat=lt(:);
lt1.subsize=subsize;

    

    
