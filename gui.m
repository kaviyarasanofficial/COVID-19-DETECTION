function varargout = gui(varargin)
% GUI M-file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 16-Feb-2015 17:08:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;
a = ones(256,256);
axes(handles.axes1);
imshow(a);
axes(handles.axes2);
imshow(a);
axes(handles.axes4);
imshow(a);
set(handles.text1,'string','');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Browse_im.
function Browse_im_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cd timages
   [file,path] = uigetfile('*.jpg;*.bmp;*.gif;*.png', 'Pick an Image File');  %% Image selection process
   im = imread(file); 
cd ..       
   im=imresize(im,[256 256]);
 
   if size(im,3)>1
      im = rgb2gray(im);
   end
   figure;
   imshow(im);
   title('Input Image');
   
   mfima=medfilt2(im,[3 3]);
   
   axes(handles.axes1);
   imshow(mfima);
   title('Medianfilter  Image');
handles.im = im;
handles.mfima =mfima;

% Update handles structure
guidata(hObject, handles);
% helpdlg('Test Image Selected');

% --- Executes on button press in database_load.
function database_load_Callback(hObject, eventdata, handles)
% hObject    handle to database_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load qfeat qfeat;
cout=cnntest(qfeat);
save cout cout
helpdlg('Training and classification completed');

  
% --- Executes on button press in classify_im.
function classify_im_Callback(hObject, eventdata, handles)
% hObject    handle to classify_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%Importing the trained network parameters
load cout cout
if isequal(cout,1)
    
   set(handles.text6,'String','Stage :'); 
   set(handles.text1,'String','[Normal]');
   
elseif isequal(cout,2)
    
  set(handles.text6,'String','Stage :'); 
  set(handles.text1,'String','[COVID]');
   

else
    
   helpdlg('Db updation required');

end    
    
 handles.result = cout;
 guidata(hObject,handles);
 
    
% --- Executes on button press in transform.
function transform_Callback(hObject, eventdata, handles)
% hObject    handle to transform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

im = handles.im;

[LL LH HL HH] = dwt2(im,'db1');  %% HAAR,DB,Bi.ortho

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

axes(handles.axes2);
imshow(aa2,[]);
title('Discrete Wavelet Transform Image');

% % % Select the wavelet coefficients LH3 and HL3
% % % Haralick features for LH3

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

qfeat = [F1 F2]';
save qfeat qfeat;

disp('Query Features: ');
disp(qfeat);


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete *.mat;
close all;

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
set(handles.text1,'string','');
set(handles.text6,'string','');
set(handles.text7,'string','');
set(handles.text8,'string','');
set(handles.text9,'string','');

a = ones(256,256);
axes(handles.axes1);
imshow(a);
axes(handles.axes2);
imshow(a);

clear all;


% --- Executes on button press in validate.
function validate_Callback(hObject, eventdata, handles)
% hObject    handle to validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  
%%%%Parameters Evaluation %%%%%%total number of test samples 9
   Tp = 3; Fn = 2;  %%%%%%%after classification
   Fp = 2; Tn = 3;  %%%%%Tp --> Abnormality correctly classified as abnormal
                    %%%%%Fn --> Abnormality incorrectly classified as normal
                    %%%%%Fp --> Normal incorrectly classified as abnormal
                    %%%%%Tn --> Normal correctly classified as normal
                      
Sensitivity = (Tp./(Tp+Fn)).*100;
Specificity = (Tn./(Tn+Fp)).*100;

Accuracy = ((Tp+Tn)./(Tp+Tn+Fp+Fn)).*100;

figure('Name','Performance Metrics','MenuBar','none'); 
bar3(1,Sensitivity,0.3,'m');
hold on;
bar3(2,Specificity,0.3,'r');
hold on;
bar3(3,Accuracy,0.3,'g');
hold off;

xlabel('Parametrics--->');
zlabel('Value--->');
legend('Sensitivity','Specificity','Accuracy');

disp('Sensitivity: '); disp(Sensitivity);
disp('Specificity: '); disp(Specificity);
disp('Accuracy:'); disp(Accuracy);


% --- Executes on button press in segment.
function segment_Callback(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

result =handles.result;

%% In CLassification Condition we got result for cout=1/2/3...
%%Depend upon this result our input image is Stage 1 or 2 or 3

inp = handles.im;

if result ==1
    
    warndlg (' NO Tumor');
         
elseif result ==2
    
   [segout,tarea] = BSegment(inp); 
   
   boundary = bwboundaries(im2bw(segout));
   axes(handles.axes1); 
   imshow(inp); title('Tumor Area Localization');
   hold on;
   for ii=1:1:length(boundary)
       btemp = boundary{ii};
       plot(btemp(:,2),btemp(:,1),'r','LineWidth',4);
   end
   hold off;
   
   axes(handles.axes4);
   imshow(segout);
   title('Segmented Image');
   
   set(handles.text7,'String','Area :');
   set(handles.text8,'String',tarea);
   set(handles.text9,'String','mm.^2');
   
   handles.area = tarea;
   guidata(hObject,handles);
   
elseif result ==3 
    
   [segout,tarea] = MSegment(inp); 
   
   boundary = bwboundaries(im2bw(segout));
   axes(handles.axes1);
   imshow(inp); title('Tumor Area Localization');
   hold on;
   for ii=1:1:length(boundary)
       btemp = boundary{ii};
       plot(btemp(:,2),btemp(:,1),'r','LineWidth',4);
   end
   hold off;
   
   axes(handles.axes4);
   imshow(segout);
   title('Brain Segmented Image');
   
   set(handles.text7,'String','Area :');
   set(handles.text8,'String',tarea);
   set(handles.text9,'String','mm.^2');   
   
   handles.area = tarea;
   guidata(hObject,handles);
   
end    
    
