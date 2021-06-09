

function determineIfFiji() {
	startup_path = getDirectory("startup");
	startup_path_split = split(startup_path, File.separator);
	if (indexOf(startup_path_split[startup_path_split.length-1], "Fiji") != -1)
		{return true;}
	else {return false;}
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

function getOptionsFlow() {
	title = "Flow Parameters";
	if (determineIfFiji()) {Dialog.createNonBlocking(title);}
	else {Dialog.create(title);}
	message = "Use the same options for all data?";
	Dialog.addMessage(message);
	items = newArray("Yes", "No");
	Dialog.addRadioButtonGroup("Choice", items, 1, 2, items[0]);
	Dialog.show();
	choice = Dialog.getRadioButton();
	if (choice == "Yes") {return true;}
	else {return false;}
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

function setUserOptions(validated_user_options_pair_array, setup_options_filepath) {
	text_file = File.open(setup_options_filepath);
	for (i=0; i<validated_user_options_pair_array.length; i++) {
		option_pair = validated_user_options_pair_array[i];
		line = replace(option_pair, "=", ",");
		print(text_file, line + "\n");
	} File.close(text_file);
}

function createReviewPathFile(user_review_directory, destination_directory, trace_filepath_array) {
	filepath_text_file = user_review_directory + File.separator + "filepaths.txt";
	text_file = File.open(filepath_text_file);
	print(text_file, destination_directory + "\n");
	for (i=0; i<trace_filepath_array.length; i++) {
		print(text_file, trace_filepath_array[i] + "\n");
	} File.close(text_file);
}

function updateCorrelationFile(destination_directory, trace_lst, options_arr) {
	text_filepath = destination_directory + File.separator + "info.txt";
	txt = File.openAsString(text_filepath);
	lines = split(txt, "\n");
	header = lines[0];
	header += ",ReviewOptions"; 
	for (i=0; i<lines.length; i++) {
		single_line = lines[i+1];
		single_line += "," + trace_lst[i] + "," + options_arr[i];
	} text_file = File.open(text_filepath);
	for (i=0; i<lines.length; i++) {
		print(text_file, lines[i] + "\n");
	} File.close(text_file);
}

function main(dst_dir) {
	macrodir = getDirectory("macros");
	kasson_matlab_directory = macrodir + "KassonLib" + File.separator + "scripts" + File.separator;
	user_review_directory = kasson_matlab_directory + "User_Review_Traces" + File.separator;
	user_review_options_dflt_filepath = user_review_directory + "UserReviewOptionsDefault.txt";

	trace_analysis_subdir = dst_dir + File.separator + "TraceAnalysis" + File.separator;
	trace_lst = getFileList(trace_analysis_subdir);
	options_arr = newArray(trace_lst.length);
	createReviewPathFile(user_review_directory, dst_dir, trace_lst);
	process_flow = false;
	validated_user_options_arr = newArray();
	
	for (i=0; i<trace_lst.length; i++) {
		trace_filepath = trace_analysis_subdir + trace_lst[i];
		abbreviated_filename = substring(trace_lst[i], 0, indexOf(trace_lst[i], "Traces")-1);
		options_file_path = dst_dir + File.separator + "SetupOptions" + File.separator + "SetupOptions_REVEIW_" + abbreviated_filename + ".txt";
		options_arr[i] = options_file_path;
		if (process_flow) {
			setUserOptions(validated_user_options_arr, options_file_path);
		} else {
			options_pair_arr = getOptions(user_review_options_dflt_filepath);
			validated_user_options_arr = optionsBox("User Review", options_pair_arr, trace_filepath);
			validated_user_options_arr = convertYesNo(validated_user_options_arr);
			setUserOptions(validated_user_options_arr, options_file_path);
			if (i == 0) {process_flow = getOptionsFlow();}
		}
	} updateCorrelationFile(dst_dir, trace_lst, options_arr);
	//interface(lva_subdir);

}

dst = "D:\\ThirdPartyPrograms\\FIJI\\Fiji.app\\LipidViralAnalysis_DataTemp";
main(dst);
