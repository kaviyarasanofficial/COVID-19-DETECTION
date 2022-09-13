function NSegment(inp)

segI= double(inp);

[r1 c1]   = size(segI);
Length  = r1*c1; 

%%%%%%% 2D into 1D image
data = reshape(segI,[Length,1]);

%%%%%% Let the number of cluster be taken as,
Cluster = 4;
dims = [r1 c1];

[data_n in_n]= size(data);

% Consider the parameters for clustering process   
expo = 2;		% exponent for the partition matrix U
max_iter = 100;		% max. number of iteration
min_impro = 1e-5;		% min. amount of improvement
display = 0;		% info display during iteration 
nwin =5; spw =1; mfw =1;

obj_fcn = zeros(max_iter, 1);	% Array for objective function

% Initial fuzzy partition
U = rand(Cluster, data_n);
col_sum = sum(U);
U = U./col_sum(ones(Cluster, 1), :);
			
lba = waitbar(0,'Please Wait...Processing');

for i = 1:max_iter,

% MF matrix after exponential modification	
mf = U.^expo;       
center = mf*data./((ones(size(data, 2), 1)*sum(mf'))'); % new center

% fill the distance matrix

dist = zeros(size(center, 1), size(data, 1));

% fill the output matrix

if size(center, 2) > 1,
    for k = 1:size(center, 1),
	dist(k, :) = sqrt(sum(((data-ones(size(data, 1), 1)*center(k, :)).^2)'));
    end
else	% 1-D data
    for k = 1:size(center, 1),
	dist(k, :) = abs(center(k)-data)';
    end
end

obj_fcn(i) = sum(sum((dist.^2).*mf));  % objective function
tmp = dist.^(-2/(expo-1));     
U_new = tmp./(ones(Cluster, 1)*sum(tmp));

tempwin=ones(nwin);
mfwin=zeros(size(U_new));
 
for j=1:size(U_new,1)
    tempmf=reshape(U_new(j,:), dims);
    tempmf=imfilter(tempmf,tempwin,'conv');
    mfwin(j,:)=reshape(tempmf,1,size(U_new,2));
end
 
mfwin=mfwin.^spw;
U_new=U_new.^mfw;
   
tmp=mfwin.*U_new;
U_new=tmp./(ones(Cluster, 1)*sum(tmp));
U = U_new;    

if display, 
    fprintf('Iteration count = %d, obj. fcn = %f\n', i, obj_fcn(i));
end
% check termination condition
    if i > 1,
		if abs(obj_fcn(i) - obj_fcn(i-1)) < min_impro, break; end,
    end
    waitbar(i/max_iter,lba);
end
close(lba);
iter_n = i;	% Actual number of iterations 
obj_fcn(iter_n+1:max_iter) = [];

figure('Name','Segmented Results');
for i=1:Cluster
    rimg=reshape(U(i,:,:),size(inp,1),size(inp,2));
    subplot(2,2,i); imshow(rimg,[])
    title(['Cluster: ' int2str(i)])
    nfile = strcat(int2str(i),'.bmp');
    cd Clusim
    imwrite(rimg,nfile);
    cd ..
end

return;
