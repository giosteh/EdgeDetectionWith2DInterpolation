
img1 = imread('cameraman.tif');
img1_edg = EdgeDetection(img1);

% definisco i valori di prova per h e thresh
h = 0.1:0.1:2;
thresh = 0.5:0.00875:0.6;
num_trials_for_h = length(h);
num_trials_for_thresh = length(thresh);

% test con l'immagine `cameraman.tif` e interpolante lineare.

grads = cell(1, num_trials_for_h);
for i = 1:num_trials_for_h
    grads{i} = uint8(img1_edg.gradient('linear', '#2', h(i)));
end

% figure();
% montage(grads);
% scelgo h pari a 1.8
grad = img1_edg.gradient('linear', '#2', 1.8);

bins = cell(1, num_trials_for_thresh);
for i = 1:num_trials_for_thresh
    bins{i} = img1_edg.binarize(grad, thresh(i));
end

% figure();
% montage(bins);
% scelgo thresh pari a 0.52625
final_linear = img1_edg.binarize(grad, 0.52625);


% test con l'immagine `cameraman.tif` e interpolante cubica makima.

grads = cell(1, num_trials_for_h);
for i = 1:num_trials_for_h
    grads{i} = uint8(img1_edg.gradient('makima', '#2', h(i)));
end

% figure();
% montage(grads);
% scelgo h pari a 1.9
grad = img1_edg.gradient('makima', '#2', 1.9);

bins = cell(1, num_trials_for_thresh);
for i = 1:num_trials_for_thresh
    bins{i} = img1_edg.binarize(grad, thresh(i));
end

% figure();
% montage(bins);
% scelgo thresh pari a 0.5175
final_makima = img1_edg.binarize(grad, 0.5175);


% test con l'immagine `cameraman.tif` e interpolante quadratica (lagrange).

grads = cell(1, num_trials_for_h);
for i = 1:num_trials_for_h
    grads{i} = uint8(img1_edg.gradient('lagrange', '#2', h(i)));
end

% figure();
% montage(grads);
% scelgo h pari a 2.0
grad = img1_edg.gradient('lagrange', '#2', 2.0);

bins = cell(1, num_trials_for_thresh);
for i = 1:num_trials_for_thresh
    bins{i} = img1_edg.binarize(grad, thresh(i));
end

% figure();
% montage(bins);
% scelgo thresh pari a 0.5175
final_lagrange = img1_edg.binarize(grad, 0.5175);



% mostro i risultati finali
figure();
montage({uint8(img1), final_linear, final_makima, final_lagrange});
title('Edge detected with linear, makima and lagrange interpolation');


