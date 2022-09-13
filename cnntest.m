function clsval=cnntest(testimagefeat)
filterDim = 8;          % filter dimension
numFilters = 10;         % number of feature maps
numImages = 20;    % number of images
poolDim = 3;          % dimension of pooling region

for di=1:1:20
    
    fname = strcat(int2str(di),'.jpg');
    cd Trsamples    
       inp = imread(fname);
    cd ..
    inp = imresize(inp,[256,256]);

    if size(inp,3)>1
       inp = rgb2gray(inp);
    end
    imag(:,:,di)=uint8(inp);
    images(:,:,di)=double(inp)/255;
end
imageDim = size(images,1);         % image dimension

% Here we load MNIST training images
images1 = reshape(images,imageDim,imageDim,1,numImages);

W = randn(filterDim,filterDim,1,numFilters);
b = rand(numFilters);

%% Use only the first 8 images for testing
convImages = images1(:, :, 1,1:8); 

% NOTE: Implement cnnConvolve in cnnConvolve.m first!
convolvedFeatures = cnnConvolve(convImages, W, b);
for i = 1:20   
    filterNum = randi([1, numFilters]);
    imageNum = randi([1, 8]);
    imageRow = randi([1, imageDim - filterDim + 1]);
    imageCol = randi([1, imageDim - filterDim + 1]);    
   
    patch = convImages(imageRow:imageRow + filterDim - 1, imageCol:imageCol + filterDim - 1,1, imageNum);

    feature = sum(sum(patch.*W(:,:,1,filterNum)))+b(filterNum);
    feature = 1./(1+exp(-feature));
    
    if abs(feature - convolvedFeatures(imageRow, imageCol,filterNum, imageNum)) > 1e-9
    end 
    images11=imag(:,:,i);
    [LL LH HL HH] = dwt2(images11,'db1');  %% HAAR,DB,Bi.ortho
    aa = [LL LH;HL HH];
    % % % % 2nd level decomp
    [LL1 LH1 HL1 HH1] = dwt2(LL,'db1');
    % aa1 = [LL1 LH1;HL1 HH1];
    % % % 3rd level Decomp
    [LL2 LH2 HL2 HH2] = dwt2(LL1,'db1');
    % % % 4th level Decomp
    [LL3 LH3 HL3 HH3] = dwt2(LL2,'db1');

    aa1 = [LL3 LH3;HL3 HH3];

    aa2 = [aa1 LH2;HL2 HH2];

    aa3 = [aa2 LH1;HL1 HH1];

    aa4  = [aa3 LH;HL HH];

    LH3 = uint8(LH3);
    Min_val = min(min(LH3));
    Max_val = max(max(LH3));
    level = round(Max_val - Min_val);
    GLCM = graycomatrix(LH3,'GrayLimits',[Min_val Max_val],'NumLevels',level);
    stat_feature = graycoprops(GLCM);
    Energy_fet1 = stat_feature.Energy;
    Contr_fet1 = stat_feature.Contrast;
    Corrla_fet1 = stat_feature.Correlation;
    Homogen_fet1 = stat_feature.Homogeneity;

    % % % % % Entropy
            R = sum(sum(GLCM));
            Norm_GLCM_region = GLCM/R;

            Ent_int = 0;
            for k = 1:length(GLCM)^2
                if Norm_GLCM_region(k)~=0
                    Ent_int = Ent_int + Norm_GLCM_region(k)*log2(Norm_GLCM_region(k));
                end
            end
            Entropy_fet1 = -Ent_int;

    %%%%%Haralick Features For HL3        
    HL3 = uint8(HL3);
    Min_val = min(min(HL3));
    Max_val = max(max(HL3));
    level = round(Max_val - Min_val);
    GLCM = graycomatrix(HL3,'GrayLimits',[Min_val Max_val],'NumLevels',level);
    stat_feature = graycoprops(GLCM);
    Energy_fet2 = stat_feature.Energy;
    Contr_fet2 = stat_feature.Contrast;
    Corrla_fet2= stat_feature.Correlation;
    Homogen_fet2 = stat_feature.Homogeneity;
    % % % % % Entropy
            R = sum(sum(GLCM));
            Norm_GLCM_region = GLCM/R;

            Ent_int = 0;
            for k = 1:length(GLCM)^2
                if Norm_GLCM_region(k)~=0
                    Ent_int = Ent_int + Norm_GLCM_region(k)*log2(Norm_GLCM_region(k));
                end
            end
    % % % % % % Ent_int = entropy(GLCM);
            Entropy_fet2 = -Ent_int;

    %%%%% Feature Sets

    F1 = [Energy_fet1 Contr_fet1 Corrla_fet1 Homogen_fet1 Entropy_fet1];
    F2 = [Energy_fet2 Contr_fet2 Corrla_fet2 Homogen_fet2 Entropy_fet2];
    dbfeat(i,:) = [F1 F2]';
end
disp('convolution code passed the training.');
pooledFeatures = cnnPool([poolDim poolDim], convolvedFeatures, 'meanpool');

testMatrix = reshape(1:64, 8, 8);
expectedMatrix = [mean(mean(testMatrix(1:4, 1:4))) mean(mean(testMatrix(1:4, 5:8))); ...
                  mean(mean(testMatrix(5:8, 1:4))) mean(mean(testMatrix(5:8, 5:8))); ];
testMatrix = reshape(testMatrix, 8, 8, 1, 1);
clsval=cnnclass(dbfeat,testimagefeat);

pooledFeatures = squeeze(cnnPool([4 4], testMatrix, 'meanpool'));
if ~isequal(pooledFeatures, expectedMatrix)
    disp('Pooling incorrect');
    disp('Expected');
    disp(expectedMatrix);
    disp('Got');
    disp(pooledFeatures);
else
    disp('pooling code passed the training.');
end
end