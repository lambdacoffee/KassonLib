/*
 * This is a FijiMacro script to be used for automated creation of multi-channel composite
 * stack-images of single-framed fileds of view.
 * 
 * Instructions:
 * 		- User should specify the tag_order_array variable (see function main())
 * 		- User must select the parent directory of the directory structure where images
 * 		  are located
 * 		- Composite stack-images will be generated and saved within subdirectories of parent
 * 
 * {Creator} : Marcos Cervantes - for the Kasson Lab.
 */

function search(dir) {
	/*
	 * This is a recursively searching function that will find the .tif files.
	 * 
	 * returns: string, "" or filename of found image
	 */
	lst = getFileList(dir);
	for (i=0; i<lst.length; i++) {
		filename = lst[i];
		filename = replace(filename, "/", "");
		filepath = dir + File.separator + filename;
		if (File.isDirectory(filepath)) {
			found_file = search(filepath);
			if (lengthOf(found_file) != 0) {
				if (filename_arr.length == 0) {filename_arr = newArray(found_file);}
				else {
					filename_arr = Array.concat(filename_arr,newArray(found_file));
				} if (filename_arr.length == num_channels) {
					filepath_arr = buildPaths(dir, lst, filename_arr);
					filename_arr = orderFiles(filename_arr);
					mergeChannels(filepath_arr, filename_arr, dir);
				}
			}
		} else {
			if (endsWith(filename, ".tif")) {
				return filename;
			}
		}
	} return ""
}

function buildPaths(parent_directory, subdir_list, filenames_array) {
	/*
	 * This function creates the paths from the found images.
	 * 
	 * returns: array of filepaths as strings
	 */
	res_arr = newArray(filenames_array.length);
	for (i=0; i<filenames_array.length; i++) {
		res_arr[i] = parent_directory + File.separator + replace(subdir_list[i],"/",File.separator) + filenames_array[i];
	} return res_arr;
}

function orderFiles(filenames_array) {
	/*
	 * This function properly orders the filenames based on the specified order
	 * in the tag_order_array variable (see function main()).
	 * 
	 * returns: array of filenames as strings, in the corresponding order of
	 * 			tag_order_array variable
	 */
	res_arr = newArray(tag_order_array.length);
	for (i=0; i<tag_order_array.length; i++) {
		for (j=0; j<filenames_array.length; j++) {
			filename_split = split(filenames_array[j], "_");
			for (k=0; k<filename_split.length; k++) {
				if (filename_split[k] == tag_order_array[i]) {
					res_arr[i] = filenames_array[j];
					break;
				}
			}
		}
	} return res_arr;
}

function mergeChannels(filepaths_array, filenames_array, directory) {
	/*
	 * This function merges the corresponding channels into a composite stack-image.
	 * 
	 * returns: int 0
	 */
	for (i=0; i<filepaths_array.length; i++) {
		open(filepaths_array[i]);
	} arg_str = "";
	for (i=0; i<filenames_array.length; i++) {
		filename = filenames_array[i];
		arg_str = arg_str + "c" + d2s(i+1,0) + "=" + filename + " ";
	} arg_str = arg_str + "create";
	run("Merge Channels...", arg_str);
	selectWindow("Composite");
	save_path = File.getParent(directory) + File.separator + "Composite_" + File.getName(directory) + ".tif";
	saveAs("tiff", save_path);
	run("Close All");
	return 0;
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
	 * 			User must also specify num_channels variable below.
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
	tag_order_array = newArray("green", "red");	// specify string tags to be found in filenames
	num_channels = 3;
	search(par_dir);
	showMessage("Done", "Process completed successfully!");
	return 0;
}

main();
