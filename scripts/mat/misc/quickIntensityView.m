
filename_cell_arr = [
    "D:\PhD\Lab\SourceData\20211027-Marcos\Ch1_liposomes-cDNA_TR4-HIV-ps-dDNA_trypsin-100ug\Ch1_green_TR4-HIV-ps-dDNA-trypsin-100ug_LI3_ex150ms_int500ms_1\Ch1_green_TR4-HIV-ps-dDNA-trypsin-100ug_LI3_ex150ms_int500ms_1_MMStack_Default.ome-002.tif", ...
    "D:\PhD\Lab\SourceData\20211027-Marcos\Ch2_green_TR4-HIV-ps-dDNA-trypsin-500ug\Ch2_green_TR4-HIV-ps-dDNA-trypsin-500ug_LI3_ex150ms_int500ms_1\Ch2_green_TR4-HIV-ps-dDNA-trypsin-500ug_LI3_ex150ms_int500ms_1_MMStack_Default.ome-002.tif", ...
    "D:\PhD\Lab\SourceData\20211027-Marcos\Ch3_liposomes-cDNA_TR4-HIV-ps-dDNA_trypsin-1000ug\Ch3_green_TR4-HIV-ps-dDNA-trypsin-1000ug_LI3_ex150ms_int500ms_1\Ch3_green_TR4-HIV-ps-dDNA-trypsin-1000ug_LI3_ex150ms_int500ms_concatenated.tif", ...
    ];
labels = ["100ug/mL", "500ug/mL", "1000ug/mL"];
frames = [0,0,0];
figure;
hold on;

for i=1:length(filename_cell_arr)
    filepath = filename_cell_arr{i};
    num_frames = length(imfinfo(filepath));
    frames(i) = num_frames;
    intensities(length(filename_cell_arr), num_frames) = 0;
end

for i=1:length(filename_cell_arr)
    filepath = filename_cell_arr{i};
    num_frames = frames(i);
    initial_frame = imread(filepath, 1);
    for j=1:num_frames
        curr_frame = imread(filepath, j);
        intensities(i, j) = sum(sum(curr_frame)) - intensities(i,1);
    end
end

for i=1:length(filename_cell_arr)
    plot((2:frames(i)), intensities(i,2:frames(i)));
end

legend(labels);
