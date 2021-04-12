/*

*/

function getSrcFilepaths(info_filepath) {
	txt = File.openAsString(info_filepath);
	lines = split(txt, "\n");
	filepath_arr = newArray(lines.length-1);
	for (i=1; i<lines.length; i++) {
		curr_line = lines[i];
		split_line = split(curr_line, ",");
		filepath_arr[i-1] = split_line[1];
	} return filepath_arr;
}

function getVidLables(info_filepath) {
	txt = File.openAsString(info_filepath);
	lines = split(txt, "\n");
	label_arr = newArray(lines.length-1);
	for (i=1; i<lines.length; i++) {
		curr_line = lines[i];
		split_line = split(curr_line, ",");
		label_arr[i-1] = split_line[0];
	} return label_arr;
}

function getBoxData(box_data_directory, vid_label_array) {
	file_lst = getFileList(box_data_directory);
	data_filepath_arr = newArray(vid_label_array.length);
	for (i=0; i<vid_label_array.length; i++) {
		vid_label = vid_label_array[i];
		for (j=0; j<file_lst.length; j++) {
			box_data_filename = file_lst[j];
			if (indexOf(box_data_filename, vid_label) != -1) {
				// found the matching box data file to its vid label
				data_filepath_arr[i] = box_data_directory + box_data_filename;
				break;
			}
		}
	} return data_filepath_arr;
}

function main() {
	arg = getArgument();
	arg_split = split(arg, ",");
	info_filepath = arg_split[0];
	process = arg_split[1];	// either Originals or RXD
	src_vid_filepath_arr = getSrcFilepaths(info_filepath);
	vid_label_arr = getVidLables(info_filepath);
	boxy_vids_subdir = File.getParent(info_filepath) + File.separator + "BoxyVideos" + File.separator;
	box_data_subdir =  boxy_vids_subdir + process + File.separator + "BoxData" + File.separator;
	box_data_arr = getBoxData(box_data_subdir, vid_label_arr);
	for (i=0; i<src_vid_filepath_arr.length; i++) {
		src_vid_filepath = src_vid_filepath_arr[i];
		box_data_txt_filepath = box_data_arr[i];
		box_data_txt = File.openAsString(box_data_txt_filepath);
		box_data_lines = split(box_data_txt, "\n");
		left_arr = newArray(box_data_lines.length-2);
		top_arr = newArray(box_data_lines.length-2);
		width_arr = newArray(box_data_lines.length-2);
		height_arr = newArray(box_data_lines.length-2);
		label_arr = newArray(box_data_lines.length-2);
		grp_nums_arr = newArray(box_data_lines.length-2);
		grp_colors = newArray("cyan", "yellow", "red");
		num_grps = grp_colors.length;
		grp_sizes = newArray(num_grps);
		for (j=2; j<box_data_lines.length; j++) {
			line_split = split(box_data_lines[j], ",");
			label = parseInt(line_split[0]);
			left = parseInt(line_split[1]);
			top = parseInt(line_split[2]);
			right = parseInt(line_split[3]);
			bottom = parseInt(line_split[4]);
			label_arr[j-2] = label;
			left_arr[j-2] = left;
			top_arr[j-2] = top;
			width_arr[j-2] = right-left;
			height_arr[j-2] = bottom-top;
			designation = line_split[5];
			if (indexOf(designation, "Fuse") != -1) {grp_num = 1;}
			else if (designation == "No Fusion") {grp_num = 2;}
			else {grp_num = 3;}	// slow/other/anamolous
			grp_nums_arr[j-2] = grp_num;
			grp_sizes[grp_num-1]+=1;
		} label_x_arr = newArray(left_arr.length);
		label_y_arr = newArray(left_arr.length);
		for (j=0; j<left_arr.length; j++) {
			label = label_arr[j];
			label_x = left_arr[j];
			if (top_arr[j] <= 10) {
				label_y = top_arr[j]+height_arr[j]+10;
			} else {label_y = top_arr[j] - 10;}
			label_x_arr[j] = label_x;
			label_y_arr[j] = label_y;
		} open(src_vid_filepath);
		src_vid_id = getImageID();
		run("ROI Manager...");
		run("Labels...", "color=yellow font=12 show");
		for (j=0; j<left_arr.length; j++) {
			makeRectangle(left_arr[j], top_arr[j], width_arr[j], height_arr[j]);
			roiManager("Add");
			Roi.setGroup(grp_nums_arr[j]);
		} for (j=1; j<num_grps+1; j++) {
			curr_grp = j;
			selection_arr = newArray(grp_sizes[curr_grp-1]);
			selection_arr_ind = 0;
			for (k=0; k<grp_nums_arr.length; k++) {
				label_grp = grp_nums_arr[k];
				if (label_grp == curr_grp) {
					selection_arr[selection_arr_ind] = k;
					selection_arr_ind+=1;
				} else {continue;}
			} if (selection_arr.length == 0) {continue;}
			roiManager("Select", selection_arr);
			roiManager("Set Color", grp_colors[j-1]);
			Roi.setStrokeColor(grp_colors[j-1]);
			roiManager("Set Line Width", 0);
		} roiManager("Show All with labels");
		roiManager("Associate", "false");
		vid_dst_filepath = boxy_vids_subdir + process + File.separator + vid_label_arr[i];
		selectWindow("ROI Manager");
		run("Close");
		selectImage(src_vid_id);
		saveAs("tiff", vid_dst_filepath);
		close();
	}
}


main();
run("Quit");
