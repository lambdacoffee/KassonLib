

function dirSearch(parent_directory, tag) {
	sample_list = getFileList(parent_directory);
	for (i=0; i<sample_list.length; i++) {
		// subdirs w/sample names
		file_name = replace(sample_list[i], "/", "");
		file_path = parent_directory + File.separator + file_name;
		if (File.isDirectory(file_path)) {
			dirSearch(file_path, tag);
		} else if (endsWith(file_path, ".tif") && indexOf(file_name, tag) != -1) {
			print(file_path);
		}
	} print("*");
}

function checkOrder(filepaths_array) {
	res_arr = newArray(filepaths_array.length);
	for (i=0; i<filepaths_array.length; i++) {
		filename = File.getName(filepaths_array[i]);
		split_name = split(filename, "_");
		for (j=0; j<split_name.length; j++) {
			if (startsWith(split_name[j], "pos")) {
				order = parseInt(substring(split_name[j], 3));
				res_arr[order-1] = filepaths_array[i];
			} else if (startsWith(split_name[j], "z")) {
				order = d2s(substring(split_name[j], 1), 0);
				res_arr[order-1] = filepaths_array[i];
			}
		}
	} return res_arr;
}

function getColorTag(filepaths_array, color_tags_array) {
	for (i=0; i<color_tags_array.length; i++) {
		sumGood = 0;
		for (j=0; j<filepaths_array.length; j++) {
			filename = File.getName(filepaths_array[j]);
			if (indexOf(filename, color_tags_array[i]) != -1) {
				sumGood ++;
			}
		} if (sumGood == filepaths_array.length) {
			// all filepaths match colors
			return color_tags_array[i];
		} else if (sumGood == 0) {
			// no filepaths match current color, next!
			continue;
		} else {exit();}
	}
}

function createStack(filepaths_array, destination_directory, tag) {
	/*
	 * This function merges the corresponding channels into a composite stack-image.
	 * 
	 * returns: int 0
	 */
	for (i=0; i<filepaths_array.length; i++) {
		open(filepaths_array[i]);
	} stack_name = File.getName(destination_directory) + "_" + tag + "_zStackx";
	if (filepaths_array.length > 1) {
		run("Images to Stack", "name=" + stack_name + " title=[] use");
		selectWindow(stack_name);
	} save_path = destination_directory + File.separator + stack_name + ".tif";
	saveAs("tiff", save_path);
	run("Close All");
	return save_path;
}

function mergeChannels(channel_paths_array, color_tags_array) {
	/*
	 * This function merges the corresponding channels into a composite stack-image.
	 * 
	 * returns: int 0
	 */
	filename_arr = newArray(channel_paths_array.length);
	for (i=0; i<channel_paths_array.length; i++) {
		open(channel_paths_array[i]);
		filename_arr[i] = File.getName(channel_paths_array[i]);
	} arg_str = "";
	for (i=0; i<color_tags_array.length; i++) {
		curr_color_channel = color_tags_array[i];
		for (j=0; j<filename_arr.length; j++) {
			if (indexOf(filename_arr[j], curr_color_channel) != -1) {
				arg_str = arg_str + "c" + d2s(i+1,0) + "=" + filename_arr[j] + " ";
			}
		}
	} arg_str = arg_str + "create";
	run("Merge Channels...", arg_str);
	selectWindow("Composite");
	subdir = File.getParent(channel_paths_array[0]);
	label = File.getName(subdir) + "_Composite";
	save_path = File.getParent(subdir) + File.separator + label + ".tif";
	saveAs("tiff", save_path);
	run("Close All");
	return 0;
}

function handleStackingFilepaths(filepaths_string, color_tags_array) {
	split_text = split(filepaths_string, "\n");
	stack_paths_arr = newArray();
	for (i=0; i<split_text.length; i++) {
		if (split_text[i] != "*") {
			stack_paths_arr = Array.concat(stack_paths_arr, newArray(split_text[i]));
		} else if (split_text[i] == "*" && stack_paths_arr.length > 0) {
			if (i == 0) {continue;}
			if (split_text[i-1] == "*") {
				// stack_paths_arr contains all images to put in stack
				ordered_paths_arr = checkOrder(stack_paths_arr);
				color_tag = getColorTag(ordered_paths_arr, color_tags_array);
				dst_dir = File.getDirectory(File.getDirectory(ordered_paths_arr[0]));
				createStack(ordered_paths_arr, dst_dir, color_tag);
				stack_paths_arr = newArray();
			}
		}
	}
}

function handleMergingFilepaths(filepaths_string, color_tags_array) {
	split_text = split(filepaths_string, "\n");
	channel_paths_arr = newArray();
	for (i=0; i<split_text.length; i++) {
		if (split_text[i] != "*" && channel_paths_arr.length < color_tags_array.length) {
			channel_paths_arr = Array.concat(channel_paths_arr, newArray(split_text[i]));
		} else if (split_text[i] != "*" && channel_paths_arr.length == color_tags_array.length) {
			mergeChannels(channel_paths_arr, color_tags_array);
			channel_paths_arr = newArray(split_text[i]);
		}
	}
}

function main() {
	/*
	 * This is the main function and entry point of this script; will show a successful
	 * message box if completed.
	 * 
	 * {Note} : User must specify the tag_order_array variable below for the data set.
	 * 			This variable is an array of strings and each should correspond to a 
	 * 			specific tag used in each channel filename to be added to composite
	 * 			stack-image IN THE DESIRED CHANNEL ORDER.
	 * 			
	 * 			[e.g.] tag_order_array = newArray("red", "green", "blue"); will attempt
	 * 			to find files that are related to each other and contain either red, green,
	 * 			or blue in the filenames, then combine them into a composite stack-image
	 * 			with the color channels in the order red (1), green (2), blue (3).
	 * 
	 * returns: int 0
	 */
	par_dir = getDirectory("Select parent source directory for images...");
	par_dir = substring(par_dir, 0, lengthOf(par_dir)-1);
	filename_arr = newArray();
	// tag_order_array pseudo-color channel order:
	//		c1 : red, c2 : green, c3 : blue
	tag_order_array = newArray("cyan", "green");	// specify string tags to be found in filenames
	for (i=0; i<tag_order_array.length; i++) {
		dirSearch(par_dir, tag_order_array[i]);
	} filepaths = getInfo("log");
	selectWindow("Log");
	run("Close");
	handleStackingFilepaths(filepaths, tag_order_array);
	dirSearch(par_dir, "zStackx");
	filepaths = getInfo("log");
	selectWindow("Log");
	run("Close");
	handleMergingFilepaths(filepaths, tag_order_array);
	showMessage("Done", "Process completed successfully!");
	return 0;
}

main();
