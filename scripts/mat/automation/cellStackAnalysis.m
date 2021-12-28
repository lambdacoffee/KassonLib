

filename_cell_mat = [
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_BHK\Cell-1\Cell-1_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_BHK\Cell-2\Cell-2_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_BHK\Cell-3\Cell-3_red_zStackx.tif";
    
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_NA-1U\Cell-1\Cell-1_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_NA-1U\Cell-2\Cell-2_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_NA-1U\Cell-3\Cell-3_red_zStackx.tif";
    
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_NA-high-neg-ctrl\Cell-1\Cell-1_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_NA-high-neg-ctrl\Cell-2\Cell-2_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_NA-high-neg-ctrl\Cell-3\Cell-3_red_zStackx.tif";
    
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_T2-cDNA-BHK\Cell-1\Cell-1_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_T2-cDNA-BHK\Cell-2\Cell-2_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_T2-cDNA-BHK\Cell-3\Cell-3_red_zStackx.tif";
    
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_T2-cDNA-BHK_NA-1U\Cell-1\Cell-1_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_T2-cDNA-BHK_NA-1U\Cell-2\Cell-2_red_zStackx.tif", ...
    "D:\PhD\Lab\SourceData\20210901-Marcos_Cells_RG\TR6-flu_T2-cDNA-BHK_NA-1U\Cell-3\Cell-3_red_zStackx.tif";
    ];
labels = ["PosCtrl", "Flu+NA", "NegCtrl", "Flu+cDNA", "Flu+cDNA+NA"];
figure;
hold on;

sz = size(filename_cell_mat);
intensities = zeros(sz(1), sz(2));
frames = zeros(sz(1), sz(2));

for i=1:sz(1)
    for j=1:sz(2)
        filepath = filename_cell_mat{i, j};
        num_frames = length(imfinfo(filepath));
        frames(i, j) = num_frames;
    end
end

for i=1:sz(1)
    for j=1:sz(2)
        filepath = filename_cell_mat{i, j};
        num_frames = frames(i, j);
        summation_frame = zeros(1, num_frames);
        for k=1:num_frames
            curr_frame = imread(filepath, k);
            summation_frame(1, k) = sum(sum(curr_frame));
        end
        intensities(i, j) = sum(summation_frame);
    end
end

x = (1:sz(2));
colors = ["g", "k", "r", "m", "b"];
for i=1:length(labels)
    scatter(x, intensities(i, :), colors(i), 's', 'LineWidth', 1);
end

legend(labels);
