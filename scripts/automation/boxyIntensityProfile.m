mat_files = ["", ...
    "", ...
    "" ...
    ];
vid_files = ["", ...
    "", ...
    "" ...
    ];
labels = ["100ug/mL", "500ug/mL", "1000ug/mL"];
frames = [0,0,0];
figure;
hold on;

for i=1:length(vid_files)
    vid_filepath = vid_files{i};
    num_frames = length(imfinfo(vid_filepath));
    frames(i) = num_frames;
    intensities(length(vid_files), num_frames) = 0;
end

for i=1:length(vid_files)
    vid_filepath = filename_cell_arr{i};
    num_frames = frames(i);
    initial_frame = imread(vid_filepath, 1);
    mat_filepath = mat_files{i};
    dat = load(mat_filepath);
    len = length(dat.DataToSave.CombinedAnalyzedTraceData);
    for j=1:len
        curr_trace = dat.DataToSave.CombinedAnalyzedTraceData(j);
        if strcmp(curr_trace.Designation, 'Fuse')
            
        end
    end
    for j=1:length(filename_cell_arr)
    filepath = filename_cell_arr{i};
    num_frames = frames(i);
    initial_frame = imread(filepath, 1);
    
        for k=1:num_frames
            curr_frame = imread(filepath, j);
            intensities(i, j) = sum(sum(curr_frame)) - intensities(i,1);
        end
    end
end