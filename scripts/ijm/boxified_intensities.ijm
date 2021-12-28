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
	info_filepath = getArgument();
	src_vid_filepath_arr = getSrcFilepaths(info_filepath);
	vid_label_arr = getVidLables(info_filepath);
	boxes_subdir = File.getParent(info_filepath) + File.separator + "Boxes" + File.separator;
	box_data_subdir =  boxes_subdir + "BoxData" + File.separator;
	box_data_arr = getBoxData(box_data_subdir, vid_label_arr);
	for (i=0; i<src_vid_filepath_arr.length; i++) {
		src_vid_filepath = src_vid_filepath_arr[i];
		box_data_txt_filepath = box_data_arr[i];
		box_data_txt = File.openAsString(box_data_txt_filepath);
		box_data_lines = split(box_data_txt, "\n");
		label_arr = newArray(box_data_lines.length-2);
		isFusion_arr = newArray(label_arr.length);
		fusionCount = 0;
		for (j=2; j<box_data_lines.length; j++) {
			line_split = split(box_data_lines[j], ",");
			label = parseInt(line_split[0]);
			label_arr[j-2] = label;
			designation = line_split[5];
			if (indexOf(designation, "Fuse") != -1) {
				isFusion_arr[j-2] = 1;
				fusionCount ++;
			} else {isFusion_arr[j-2] = 0;}
		} open(src_vid_filepath);
		src_vid_id = getImageID();
		roi_filepath = boxes_subdir + vid_label_arr[i] + ".zip";
		roiManager("open", roi_filepath);
		roiManager("show all without labels");
		num_boxes = label_arr.length;
		x_vals = newArray();
		y_vals = newArray();
		isFusionPixVals = newArray();
		for (j=0; j<num_boxes; j++) {
			roiManager("select", j);
			Roi.getContainedPoints(xpoints, ypoints);
			x_vals = Array.concat(x_vals, xpoints);
			y_vals = Array.concat(y_vals, ypoints);
			sub_fusion_pix_arr = newArray(xpoints.length);
			if (isFusion_arr[j]) {
				Array.fill(sub_fusion_pix_arr, 1);
			} else {Array.fill(sub_fusion_pix_arr, 0);}
			isFusionPixVals = Array.concat(isFusionPixVals, sub_fusion_pix_arr);
		} total_box_intensities = newArray(nSlices);
		fusion_box_intensities = newArray(nSlices);
		frame_nums = newArray(nSlices);
		for (n=1; n<nSlices+1; n++) {
			frame_nums[n-1] = n;
			selectImage(src_vid_id);
			setSlice(n);
			total_roi_summation = 0;
			fusion_roi_summation = 0;
			for (p=0; p<x_vals.length; p++) {
				pix = getPixel(x_vals[p], y_vals[p]);
				total_roi_summation += pix;
				if (isFusionPixVals[p]) {fusion_roi_summation += pix;}
			} total_box_intensities[n-1] = total_roi_summation;
			fusion_box_intensities[n-1] = fusion_roi_summation;
		} Plot.create("Total Box Intensities", "Frame", "Total Intensity Value");
		Plot.add("line", frame_nums, total_box_intensities, "TotalBoxIntensities");
		Plot.show();
		total_box_filepath = boxes_subdir + "TotalBoxIntensities_" + vid_label_arr[i];
		saveAs("tiff", total_box_filepath);
		Plot.create("Fusion Box Intensities", "Frame", "Total Intensity Value");
		Plot.setColor("cyan");
		Plot.setBackgroundColor("gray");
		Plot.add("line", frame_nums, fusion_box_intensities, "FusionBoxIntensities");
		Plot.show();
		fusion_box_filepath = boxes_subdir + "FusionBoxIntensities_" + vid_label_arr[i];
		saveAs("tiff", fusion_box_filepath);
		selectImage(src_vid_id);
		close();
		selectWindow("ROI Manager");
		run("Close");
		run("Close All");
	}
}


main();
