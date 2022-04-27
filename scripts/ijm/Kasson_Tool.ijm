
function determineIfFiji() {
	/*
 	* This function determines if Fiji is being used.
 	* returns: boolean 
 	* 	- true if Fiji.app, else false (ImageJ)
 	*/
	startup_path = getDirectory("startup");
	startup_path_split = split(startup_path, File.separator);
	if (indexOf(startup_path_split[startup_path_split.length-1], "Fiji") != -1)
		{return true;}
	else {return false;}
}

function createWelcome(help_filepath) {
	help_txt = File.openAsString(help_filepath);
	title = "Welcome!";
	if (determineIfFiji()) {Dialog.createNonBlocking(title);}
	else {Dialog.create(title);}
	message = "This is the Kasson Tool extension plugin for Fiji (Fiji Is Just ImageJ).";
	message += "\nThis plugin utilizes Fiji, MATLAB, & Python for performing semi-automated analysis workflows related to viral fusion.";
	message += "\nPlease ensure that MATLAB is installed & properly licensed.";
	message += "\nPlease ensure that Python is installed.";
	message += "\nClick 'OK' to continue, 'Cancel' to exit anytime, & 'Help' to display the User Guide.";
	Dialog.addMessage(message);
	Dialog.addHelp(help_txt);
	Dialog.show();
	return 0;
}

function sourceCheck(parent_directory) {
	parent_dir_lst = getFileList(parent_directory);
	summary_txt_filepath = parent_directory + File.separator + "summary.txt";
	if (parent_dir_lst.length > 0) {
		if (!File.exists(summary_txt_filepath))
				{err(-2);}
		for (i=0; i<parent_dir_lst.length; i++) {
			filename = parent_dir_lst[i];
			filepath = parent_directory + File.separator + filename;
			if (!File.isDirectory(filepath) && filename != "summary.txt") {
				err(-1);
			}
		} return true;
	} err(-3);
}

function matlabCheck(automation_directory) {
	parent_dir_lst = getFileList(automation_directory);
	if (parent_dir_lst.length > 0) {
		main_file = automation_directory + File.separator + "main.m";
		extraction_default_options_file = automation_directory + File.separator + "SetupOptionsDefault_EXTRACTION.txt";
		file_arr = newArray(main_file, extraction_default_options_file);
		for (i=0; i<file_arr.length; i++) {
			if (!File.exists(file_arr[i])) {return false;}
		} return true;
	} return false;
}

function destinationDirectoryBox() {
	title = "Destination Directory";
	if (determineIfFiji()) {Dialog.createNonBlocking(title);}
	else {Dialog.create(title);}
	message = "Please select desired option for specifying destination directory for data.\n";
	message += "Default selection corresponds to the Fiji/ImageJ directory.\n";
	message += "Custom selection allows User choice of empty directory elsewhere.";
	Dialog.addMessage(message);
	items = newArray("Default", "Custom");
	Dialog.setInsets(5, 50, 0);
	Dialog.addRadioButtonGroup("Selection:", items, 2, 1, items[0]);
	Dialog.show();
	choice = Dialog.getRadioButton();
	return choice;
}

function getDestinationDirectory(source_data_top_directory) {
	user_choice = destinationDirectoryBox();
	if (user_choice == "Default") {
		dst_dir = getDirectory("startup");
		dst_dir = dst_dir + "KassonAnalysis_DataTemp";
		if (File.exists(dst_dir)) {err(-10);}
		File.makeDirectory(dst_dir);
	} else {
		dst_dir = getDirectory("Choose empty destination directory...");
		// a '/' is appended to the end of directory path, must remove
		dst_dir = substring(dst_dir, 0, lengthOf(dst_dir)-1);
	} split_filepath = split(source_data_top_directory, File.separator);
	if (indexOf(dst_dir, split_filepath[split_filepath.length-1]) != -1) {
		err(-9);
	} top_subdir_arr = newArray("SetupOptions", "TraceData", "PotentialTraces", "Intensities", "BinaryMasks", "BackgroundTraces", "TraceAnalysis", "Boxes", "Stats");
	trace_analysis_subdirs = newArray("TraceDrawings", "TraceText", "AnalysisReviewed");
	stats_subdirs = newArray("PropFusedGamma", "PropFused", "Residuals", "LipidMixEvents", "Log");
	createDirs(dst_dir, top_subdir_arr);
	createDirs(dst_dir + File.separator + "TraceAnalysis", trace_analysis_subdirs);
	createDirs(dst_dir + File.separator + "Stats", stats_subdirs);
	return dst_dir;
}

function createDirs(top_directory, subdir_array) {
	for (i=0; i<subdir_array.length; i++) {
		subdir_path = top_directory + File.separator + subdir_array[i];
		File.makeDirectory(subdir_path);
	} 
}

function err(error_code) {
	if (error_code == -1) {
		message = "FATAL ERROR: Unsupported File Type!";
	} else if (error_code == -2) {
		message = "FATAL ERROR: Cannot locate summary.txt file!";
	} else if (error_code == -3) {
		message = "FATAL ERROR: Empty directory for source data...!";
	} else if (error_code == -4) {
		message = "FATAL ERROR - ALTERED CORE CONTENTS: Missing MATLAB file!";
	} else if (error_code == -5) {
		message = "FATAL ERROR - ALTERED CORE CONTENTS: Missing interface file!";
	} else if (error_code == -6) {
		message = "FATAL ERROR - ALTERED CORE CONTENTS: Missing interface file!";
	} else if (error_code == -7) {
		message = "FATAL ERROR - Misconfigured summary.txt file - HEADER NOT FOUND";
	} else if (error_code == -8) {
		message = "FATAL ERROR - Broken correlation between media type and representing color...";
	} else if (error_code == -9) {
		message = "FATAL ERROR - FLow pathing conflict - destination folder cannot be a subdirectory of source folder!";
		message += "\nPlease check source directory before attempting processing again.";
	} else if (error_code == -10) {
		message = "FATAL ERROR - DESTINATION 'TEMP' DIRECTORY ALREADY EXISTS!";
		message += "\nPlease rename or move the current destination directory from";
		message += "\nthe Fiji.app directory.";
	} message += "\nTERMINATING SEQUENCE - abort process...";
	exit(message);
}

function setMATLABbinpath() {
	os_name = getInfo("os.name");
	if (indexOf(os_name, "indows") != -1) {
		matlab_filename = "matlab.exe";
	} else {matlab_filename = "matlab";}
	title = "Set MATLAB Path";
	if (determineIfFiji()) {Dialog.createNonBlocking(title);}
	else {Dialog.create(title);}
	message = "Please navigate to the parent directory of the MATLAB binary/executable file.";
	message += "\nIt should be located somewhere along the following path:\n";
	message += ".." + File.separator + "MATLAB" + File.separator + "R2YYYx" + File.separator + "bin" + File.separator + matlab_filename;
	message += "\nOr, alternatively: " + ".." + File.separator + "MATLAB" + File.separator + "bin" + File.separator + matlab_filename;
	Dialog.addMessage(message);
	Dialog.show();
	matlab_bin_dir = getDirectory("Select the directory where " + matlab_filename + " is located.");
	matlab_bin_dir = substring(matlab_bin_dir, 0, lengthOf(matlab_bin_dir)-1);
	matlab_full_path = matlab_bin_dir + File.separator + matlab_filename;
	if (!File.exists(matlab_full_path))
		{setMATLABbinpath();}
	return matlab_full_path;
}

function checkMATLABbinpath(text_filepath) {
	if (File.exists(text_filepath)) {
		matlab_path = File.openAsString(text_filepath);
		if (!File.exists(replace(matlab_path, "\n", ""))) {
			matlab_full_path = setMATLABbinpath();
		} else {return true;}
	} else {
		matlab_full_path = setMATLABbinpath();
	} txt_file = File.open(text_filepath);
	print(txt_file, replace(matlab_full_path, "\n", ""));
	File.close(txt_file);
}

function interface(kasson_lib_directory) {
	bin_subdir = kasson_lib_directory + "bin" + File.separator;
	os_name = getInfo("os.name");
	if (indexOf(os_name, "indows") != -1) {
		// windows machine
		matlab_interface_path = bin_subdir + "bat" + File.separator + "ijmat.bat";
		if (!File.exists(matlab_interface_path)) {err(-5);}
		exec("cmd", "/c", "start " + matlab_interface_path, kasson_lib_directory);
	} else {
		matlab_interface_path = bin_subdir + "sh" + File.separator + "ijmat.sh";
		if (!File.exists(matlab_interface_path)) {err(-5);}
		exec("sh", matlab_interface_path);
	}
}

function getOptions(options_filepath) {
	// returns array of the default option pair names & values
	script_text = File.openAsString(options_filepath);
	lines = split(script_text, "\n");
	options_arr = newArray();
	option_vals_arr = newArray();
	for (i=0; i<lines.length; i++) {
		single_line = lines[i];
		if (indexOf(single_line, "Options.") != -1 && indexOf(single_line, "=") != -1
			&& endsWith(single_line, ";") != -1 && indexOf(single_line, "%") == -1)
		{
			option = substring(single_line, indexOf(single_line, ".")+1, indexOf(single_line, "="));
			option_val = substring(single_line, indexOf(single_line, "=")+1, indexOf(single_line, ";"));
			option = replace(option, " ", "");
			option_val = replace(option_val, " ", "");
			options_arr = Array.concat(options_arr, newArray(option));
			option_vals_arr = Array.concat(option_vals_arr, newArray(option_val));
		}
	} res_arr = newArray(options_arr.length);
	for (i=0; i<res_arr.length; i++) {
		res_arr[i] = options_arr[i] + "=" + option_vals_arr[i];
	} return res_arr;
}

function convertYesNo(user_validated_array) {
	for (i=0; i<user_validated_array.length; i++) {
		user_validated_item = user_validated_array[i];
		split_item_arr = split(user_validated_item, ",");
		if (split_item_arr[split_item_arr.length-1] == "No") {
			comma_ind = indexOf(user_validated_item, ",");
			option = substring(user_validated_item, 0, comma_ind);
			replacement = replace(substring(user_validated_item, comma_ind), "No", "n");
			user_validated_array[i] =  option + replacement;
		} else if (split_item_arr[split_item_arr.length-1] == "Yes") {
			user_validated_array[i] = replace(user_validated_array[i], "Yes", "y'");
		} else {continue;}
	} return user_validated_array;
}

function validateUserOption(user_entered_value, configuration) {
	if (configuration == "numFields") {
		if (isNaN(parseInt(user_entered_value))) {
			// value is not integer
			if (isNaN(parseFloat(user_entered_value))) {
				// value is not float
				return false;
			}
		} return true;
	} else if (configuration == "radio") {
		if (user_entered_value != "No" && user_entered_value != "Yes") {
			return false;
		} return true;
	} else
		{return true;}
}

function buildBox(title, src_data_filename, options_pair_array, configuration) {
	title = "Flow Parameters";
	if (determineIfFiji()) {Dialog.createNonBlocking(title);}
	else {Dialog.create(title);}
	message = "Please enter the corresponding setup option values for:\n";
	message += src_data_filename;
	Dialog.addMessage(message);
	count = 0;
	option_arr = newArray();
	left_margin = 40;
	for (i=0; i<options_pair_array.length; i++) {
		option_pair = options_pair_array[i];
		option = substring(option_pair, 0, indexOf(option_pair, "="));
		option_val = substring(option_pair, indexOf(option_pair, "=")+1);
		if (configuration == "numFields") {
			if (indexOf(option_val, "\'") != -1 || option_val == "[]" || option_val == "NaN")
			{continue;}
			else {
				if (count%3 != 0) {Dialog.addToSameRow();}
				Dialog.addNumber(option, option_val);
				option_arr = Array.concat(option_arr, newArray(option));
				count ++;
			}
		} else if (configuration == "checkbox") {
			if (option_val == "\'Y\'" || option_val == "\'y\'" || option_val == "\'N\'" || option_val == "\'n\'")
				{
				if (count == 0) {Dialog.setInsets(15,left_margin,0);}
				else {Dialog.setInsets(0,left_margin,0);}
				Dialog.addCheckbox(option, false);
				option_arr = Array.concat(option_arr, newArray(option));
				count ++;
				}
		} else if (configuration == "other") {
			if (indexOf(option_val, "\'") != -1 || option_val == "NaN" || option_val == "[]") {
				if (option_val == "\'Y\'" || option_val == "\'y\'" || option_val == "\'N\'" || option_val == "\'n\'")
					{continue;}
				else {
					option_val = replace(option_val, "\'", "");
					if (count == 0) {Dialog.setInsets(15,left_margin,0);}
					else {Dialog.setInsets(0,left_margin,0);}
					Dialog.addString(option, option_val);
					option_arr = Array.concat(option_arr, newArray(option));
					count ++;
				}
			}
		}
	} res_arr = newArray(count);
	while (true) {
		Dialog.show();
		for (i=0; i<count; i++) {
			if (configuration == "numFields") {
				user_val = Dialog.getNumber();
			} else if (configuration == "checkbox") {
				user_val = Dialog.getCheckbox();
				if (user_val) {user_val = "Yes";}
				else {user_val = "No";}
			} else if (configuration == "other") {
				user_val = Dialog.getString();
			} if (!validateUserOption(user_val, configuration)) {
				validation = false;
				break;
			} validation = true;
			res_arr[i] = option_arr[i] + "," + user_val;
		} if (validation) {break;}
	} return res_arr;
}

function getExperimentTypeBox() {
	title = "Determine Experiment Type";
	if (determineIfFiji()) {Dialog.createNonBlocking(title);}
	else {Dialog.create(title);}
	message = "Which type of experiment is this?";
	Dialog.addMessage(message);
	items = newArray("Tethered Vesicle", "SLB Self Quench");
	Dialog.addRadioButtonGroup("Option:", items, 1, 2, items[0]);
	Dialog.show();
	choice = Dialog.getRadioButton();
	choice = replace(choice, " ", "");
	return choice;
}

function optionsBox(configuration, options_pair_array, src_data_filename) {
	config_arr = newArray("other", "numFields", "checkbox");
	user_verified_options_arr = newArray();
	for (n=0; n<config_arr.length; n++) {
		title = "Setup Options -" + configuration + "- GUI {";
		title += d2s(n+1,0) + "/" + d2s(config_arr.length,0) + "}";
		usr_verified_tmp_arr = buildBox(title, src_data_filename, options_pair_array, config_arr[n]);
		user_verified_options_arr = Array.concat(user_verified_options_arr, usr_verified_tmp_arr);
	} return user_verified_options_arr;
}

function setUserOptions(validated_user_options_pair_array, setup_options_filepath) {
	text_file = File.open(setup_options_filepath);
	for (i=0; i<validated_user_options_pair_array.length; i++) {
		option_pair = validated_user_options_pair_array[i];
		line = replace(option_pair, "=", ",");
		print(text_file, line + "\n");
	} File.close(text_file);
}

function getSummaryInfo(summary_text_filepath) {
	summary_text = File.openAsString(summary_text_filepath);
	summary_arr = split(summary_text, "%%%");
	return summary_arr;
}

function getColorCorrelation(summary_info_array) {
	// returns array of len=2, [img:cyan, vid:green]
	res_arr = newArray(2);
	img_color = "";
	vid_color = "";
	for (i=0; i<summary_info_array.length; i++) {
		summary_block = summary_info_array[i];
		split_summary_block = split(summary_block, "\n");
		if (split_summary_block[0] == "~ HEADER ~") {
			for (j=1; j<split_summary_block.length; j++) {
				line = split_summary_block[j];
				if (startsWith(line, "img:")) {
					img_color = substring(line, indexOf(line, ": ")+2);
				} if (startsWith(line, "vid:")) {
					vid_color = substring(line, indexOf(line, ": ")+2);
				}
			} res_arr[0] = "img:" + img_color;
			res_arr[1] = "vid:" + vid_color;
			return res_arr;
		}
	} err(-7);
}

function getVidColor(summary_info_array) {
	color_correlation_arr = getColorCorrelation(summary_info_arr);
	if (startsWith(color_correlation_arr[1], "vid")) {
		res = substring(color_correlation_arr[1], indexOf(color_correlation_arr[1], ":")+1);
		return res;
	} else {err(-8);}
}

function filterFilepaths(filenames_array, num_channels, video_tag) {
	/*
	 * This function properly orders the filenames based on the specified order
	 * in the tag_order_array variable (see function main()).
	 * 
	 * returns: array of filenames as strings, in the corresponding order of
	 * 			tag_order_array variable
	 */
	res_arr = newArray(num_channels);
	idx = 0;
	for (j=0; j<filenames_array.length; j++) {
		filename_split = split(filenames_array[j], "_");
		for (k=0; k<filename_split.length; k++) {
			if (filename_split[k] == video_tag) {
				res_arr[idx] = filenames_array[j];
				idx ++;
				break;
			}
		} if (idx >= res_arr.length) {break;}
	} return res_arr;
}

function getAllFilepaths(directory, fmt) {
	/*
	 * This is a recursively searching function that will find the .tif files.
	 * 
	 * returns: string, "" or filename of found image
	 */
	lst = getFileList(directory);
	filepath_arr = newArray(0);
	for (i=0; i<lst.length; i++) {
		filename = lst[i];
		if (endsWith(filename, "/")) {
			filename = substring(filename, 0, lengthOf(filename)-1);
		} filepath = directory + filename;
		if (File.isDirectory(filepath)) {
			filepath += File.separator;
			found_filepath = getAllFilepaths(filepath, fmt);
			filepath_arr = Array.concat(filepath_arr, found_filepath);
		} else {
			if (endsWith(filename, fmt)) {
				return filepath;
			}
		}
	} return filepath_arr;
}

function createExtractionPathFile(automation_directory, data_source_directory, destination_directory, source_video_filepath_array, kasson_lib_directory) {
	filepath_text_file = automation_directory + "filepaths.txt";
	text_file = File.open(filepath_text_file);
	print(text_file, data_source_directory + "\n");
	print(text_file, destination_directory + "\n");
	ij_dir = getDirectory("startup");
	ij_dir_lst = getFileList(ij_dir);
	for (i=0; i<ij_dir_lst.length; i++) {
		if (startsWith(ij_dir_lst[i], "ImageJ")) {
			print(text_file, ij_dir + ij_dir_lst[i] + "\n");
			break;
		}
	} print(text_file, kasson_lib_directory + "\n");
	for (i=0; i<source_video_filepath_array.length; i++) {
		print(text_file, source_video_filepath_array[i] + "\n");
	} File.close(text_file);
}

function createCorrelationFile(destination_directory, video_filepath_array, options_arr) {
	header = "Label,Filepath,ExtractionOptions\n";
	text_filepath = destination_directory + "info.txt";
	text_file = File.open(text_filepath);
	print(text_file, header);
	for (i=0; i<video_filepath_array.length; i++) {
		print(text_file, "Datum-" + d2s(i+1,0) + "," + video_filepath_array[i] + "," + options_arr[i] + "\n");
	} File.close(text_file);
	return text_filepath;
}

function createModalityFile(modality, automation_directory) {
	text_filepath = automation_directory + "modality.txt";
	text_file = File.open(text_filepath);
	print(text_file, modality);
	File.close(text_file);
}

function getModalityBox() {
	title = "Determine Processing Modality";
	Dialog.create(title);
	msg = "Please specify the modality for data processing.";
	msg += "\nBob Style will execute Lipid Mixing Trace Analysis process in MATLAB.";
	msg += "\nLambda Style will skip Lipid Mixing Trace Analysis process & proceed";
	msg += "\ndirectly to FusionTraceReview in Python.";
	Dialog.addMessage(msg);
	choice_1 = "Bob Style - LipidMixingAnalysis";
	choice_2 = "Lambda Style - ManualRescoring";
	items = newArray(choice_1, choice_2);
	Dialog.addRadioButtonGroup("Option:", items, 2, 1, items[0]);
	Dialog.show();
	user_choice = Dialog.getRadioButton();
	res = false;
	if (user_choice == choice_1) {res = true;}
	return res;
}

function specifyKassonLibDir() {
	showMessage("KassonLib Location", "Please specify the location of the KassonLib directory!");
	dir_path = getDirectory("Location of KassonLib...");
	return dir_path;
}

function getKassonLibDir() {
	res_dir = getDirectory("macros") + "KassonLib" + File.separator;	
	if (!File.exists(res_dir)) {
		res_dir = getDirectory("macros") + "KassonLib-master" + File.separator;
		if (!File.exists(res_dir)) {
			kasson_lib_info_path = getDirectory("macros") + "KassonLibInfo.txt";
			if (!File.exists(kasson_lib_info_path)) {
				res_dir = specifyKassonLibDir();
				txt_file = File.open(kasson_lib_info_path);
				print(txt_file, res_dir);
				File.close(txt_file);
			} else {
				res_dir = File.openAsString(kasson_lib_info_path);
				res_dir = replace(res_dir, "\n", "");
				if (!File.exists(res_dir)) {
					File.delete(kasson_lib_info_path);
					res_dir = getKassonLibDir();
				}
			}
		}
	} return res_dir;
}

function main() {
	kasson_lib_dir = getKassonLibDir();
	matlab_scrips_dir = kasson_lib_dir + "scripts" + File.separator + "mat" + File.separator;
	automation_dir = matlab_scrips_dir + File.separator + "automation" + File.separator;
	binmatlab_path = kasson_lib_dir + "log" + File.separator + "binmatlabpath.txt";
	checkMATLABbinpath(binmatlab_path);
	
	help_filepath = kasson_lib_dir + "log" + File.separator + "help.txt";
	createWelcome(help_filepath);
	if (!matlabCheck(automation_dir))
		{err(-4);}
	src_data_top_dir = getDirectory("Select directory where source data is located...");
	if (indexOf(getInfo("os.name"), "indows") != -1) {
		src_data_top_dir = replace(src_data_top_dir, "/", "");
	} sourceCheck(src_data_top_dir);
	
	dst_dir = getDestinationDirectory(src_data_top_dir);
	dst_dir = dst_dir + File.separator;
	summary_info_arr = getSummaryInfo(src_data_top_dir + "summary.txt");
	vid_color = getVidColor(summary_info_arr);
	all_tif_filepaths = getAllFilepaths(src_data_top_dir, ".tif");
	vid_path_arr = filterFilepaths(all_tif_filepaths, summary_info_arr.length-1, vid_color);

	modality = getModalityBox();
	createModalityFile(modality, automation_dir);
	gui_config_arr = newArray("EXTRACTION");
	extraction_default_options_file = automation_dir + "SetupOptionsDefault_mode-0.txt";
	if (modality) {
		extraction_default_options_file = automation_dir + "SetupOptionsDefault_EXTRACTION.txt";
		gui_config_arr = Array.concat(gui_config_arr, newArray("ANALYSIS"));
	} option_filepaths_arr = newArray(vid_path_arr.length);
	for (i=0; i<option_filepaths_arr.length; i++)
		{option_filepaths_arr[i] = "";}
	experiment_type = "";
	for (i=0; i<gui_config_arr.length; i++) {
		curr_option_filepaths_arr = newArray(vid_path_arr.length);
		//process_flow = false;
		curr_config = gui_config_arr[i];
		validated_user_options_arr = newArray();
		for (j=0; j<vid_path_arr.length; j++) {
			options_file_path = dst_dir + "SetupOptions" + File.separator + "SetupOptions_" + curr_config + "_Datum-" + d2s(j+1,0) + ".txt";
			curr_option_filepaths_arr[j] = options_file_path;
			/*if (process_flow) {
				setUserOptions(validated_user_options_arr, options_file_path);
			} else {*/
				vid_filepath_split = split(vid_path_arr[j], File.separator);
				if (curr_config == "EXTRACTION")
					{options_pair_arr = getOptions(extraction_default_options_file);}
				else if (curr_config == "ANALYSIS") {
					if (j == 0) {experiment_type = getExperimentTypeBox();}
					if (experiment_type == "TetheredVesicle") {
						analysis_default_options_file = automation_dir + "SetupOptionsDefaultTetheredVesicle.txt";
					} else if (experiment_type == "SLBSelfQuench") {
						analysis_default_options_file = automation_dir + "SetupOptionsDefaultSLBSelfQuench.txt";
					} options_pair_arr = getOptions(analysis_default_options_file);
				} validated_user_options_arr = optionsBox(curr_config, options_pair_arr, vid_filepath_split[vid_filepath_split.length-1]);
				validated_user_options_arr = convertYesNo(validated_user_options_arr);
				if (curr_config == "ANALYSIS") {
					validated_user_options_arr = Array.concat(newArray("TypeofFusionData=" + experiment_type), validated_user_options_arr);
				} setUserOptions(validated_user_options_arr, options_file_path);
				//if (j == 0) {process_flow = getOptionsFlow();}
			//}
		} if (curr_config == "EXTRACTION") {
			createExtractionPathFile(automation_dir, src_data_top_dir, dst_dir, vid_path_arr, kasson_lib_dir);
		} for (j=0; j<curr_option_filepaths_arr.length; j++) {
			if (option_filepaths_arr[j] != "") {
				option_filepaths_arr[j] = option_filepaths_arr[j] + ",";
			} option_filepaths_arr[j] = option_filepaths_arr[j] + curr_option_filepaths_arr[j];
		}
	} correlation_filepath = createCorrelationFile(dst_dir, vid_path_arr, option_filepaths_arr);
	interface(kasson_lib_dir);
}

main();
run("Quit");
