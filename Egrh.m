function Rfeat = Egrh(QQ)
load DbFeat DbFeat
Dfeatures=DbFeat;
ProjectedTestImage = QQ;
ProjectedImages = Dfeatures;

nn = isnan(ProjectedTestImage);
for kk = 1:1:length(QQ)    
   if nn(kk) ==1      
      ProjectedTestImage(kk,:) = 0;
   end   
end    

dnn = isnan(ProjectedImages);
for dk = 1:size(Dfeatures,1)
   for dk1 = 1:size(Dfeatures,2)
       if dnn(dk,dk1) ==1
          ProjectedImages(dk,dk1) = 0;
       end   
   end 
end

QQ = ProjectedTestImage;
DD = ProjectedImages;
Edist = [];

cnt  = size(DD,2);
Euc_dist = [];
for i = 1 : cnt
    q = DD(:,i);
    temp = sqrt(sum(( QQ - q ).^2));
    Edist = [Edist temp];
end

%%%%%%%%%%% Error between the input and database Images
ER = sort(Edist,'descend');
[M,ind] = min(Edist);
Rfeat = DD(:,ind);

% figure('MenuBar','None');
% plot(ER);
% xlabel('Iterations');
% ylabel('Error values');
% title('Performance Graph');


