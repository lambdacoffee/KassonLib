/*
* This is the installer script for the KassonLib package.
* This is ran by the batch or bash script upon first initiation of the program.
* 
* Created by: Marcos Cervantes
*/


function determineIfFiji() {
	/*
	* This determines whether Fiji is being run or ImageJ.
	* 
	* returns - bool:true if Fiji, bool:false if ImageJ
	*/
	startup_path = getDirectory("startup");
	startup_path_split = split(startup_path, File.separator);
	if (indexOf(startup_path_split[startup_path_split.length-1], "Fiji") != -1)
		{return true;}
	else {return false;}
}

function handleImageJ(user_choice, kasson_lib_directory) {
	/*
	* This handles the interface of ImageJ if it is determined
	* that ImageJ is being used. Edits the StartupMacros.txt file 
	* to include the shortcut if user selected to do so.
	* Shows message box if completed.
	* 
	* returns - 0
	*/
	macrodir = getDirectory("macros");
	startup_macros_path = macrodir + "StartupMacros.txt";
	imagej_interface_path = kasson_lib_directory + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "imagejinterface.ijm";
	imagej_interface_txt = File.openAsString(imagej_interface_path);
	macro_path = kasson_lib_directory + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "Lipid_Viral_Analysis_Tool.ijm";
	imagej_interface_txt = replace(imagej_interface_txt, "@@@", macro_path);
	if (!user_choice) {
		key_bind = "";
		imagej_interface_txt_head = substring(imagej_interface_txt, 0, indexOf(imagej_interface_txt, " [L]"));
		imagej_interface_txt_tail = substring(imagej_interface_txt, indexOf(imagej_interface_txt, " [L]")+4);
		imagej_interface_txt = imagej_interface_txt_head + imagej_interface_txt_tail;
		imagej_interface_file = File.open(imagej_interface_path);
		print(imagej_interface_file, imagej_interface_txt);
		File.close(imagej_interface_file);
	} else {key_bind = " [L]";}
	File.append("\n\n" + imagej_interface_txt, startup_macros_path);
	message = "Installation complete - Lipid Viral Analysis Tool will be available";
	message += "\non the following menu path of the ImageJ toolbar:";
	message += "\nMacros >>> Lipid Viral Analysis Tool" + key_bind;
	showMessage("Completed Installation!", message);
	return 0;
}

function setupBox() {
	/*
	* This forms & shows the setup box that will inform the
	* user what this installer will do as well as give the
	* option to create a shortcut key-bind.
	* 
	* returns - bool:true | bool:false depending on user choice
	* 			for key binding
	*/
	title = "Startup Lipid Viral Analysis Installer";
	if (determineIfFiji()) {
		Dialog.createNonBlocking(title);
		platform = "Fiji";
		key_bind = "F3";
	} else {
		Dialog.create(title);
		platform = "ImageJ";
		key_bind = "L";
	} message = "Preparing to install Lipid Viral Analysis Tool for " + platform + "...\n";
	message += "Bind 'Lipid Viral Analysis Tool' to shortcut?\n";
	message += "This will allow hotkey access upon startup via the [" + key_bind + "] key.\n";
	message += "The Lipid Viral Analysis Tool will still be accessible on the" + platform + " toolbar, located at:\n";
	message += "Plugins >>> {scroll all the way down} >>> Tools >>> Lipid Viral Analysis Tool";
	Dialog.addMessage(message);
	Dialog.setInsets(15, 40, 0);
	Dialog.addCheckbox("Create & map shortcut to '" + key_bind + "'", false);
	Dialog.show();
	choice = Dialog.getCheckbox();
	return choice;
}

function getStatus(status_filepath) {
	/*
	* This determines the current status of the package by reading
	* the status.txt file.
	* 
	* returns - bool:true if package is uninstalled, bool:false if it is
	*/	
	if (File.exists(status_filepath)) {
		status = File.openAsString(status_filepath);
		if (indexOf(status, "uninstalled") != -1)
			{return true;}
		else {return false;}
	} else {exit("Status log File missing, unknown state - TERMINATING SEQUENCE, ABORT PROCESS.");}
}

function setStatus(status_filepath, shortcut) {
	/*
	* This sets the status of the package by editing the status.txt file.
	* 
	* returns - 0
	*/
	status_novus = "installed";
	if (shortcut) {status_novus = status_novus + ",shortcut";}
	status_file = File.open(status_filepath);
	print(status_file, status_novus);
	File.close(status_file);
	return 0;
}

function specifyKassonLibDir() {
	/*
	* This allows the user to specify the location of the
	* KassonLib directory if it is not present in the macros
	* subdirectory of Fiji.app or ImageJ folder.
	* 
	* returns - string:dir_path directory path for KassonLib (with trailing file sep)
	*/
	showMessage("KassonLib Location", "Please specify the location of the KassonLib directory!");
	dir_path = getDirectory("Location of KassonLib...");
	return dir_path;
}

function getKassonLibDir() {
	/*
	* This determines where the KassonLib directory is located.
	* 
	* returns - string:res_dir result directory path of KassonLib
	*/
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
	status_filepath = kasson_lib_dir + "LipidViralAnalysis" + File.separator + "log" + File.separator + "status.txt";
	if (!getStatus(status_filepath)) {
		exit("Lipid Viral Analysis already installed!");
	} macro_tool_file_path = kasson_lib_dir + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "Lipid_Viral_Analysis_Tool.ijm";
	user_choice = setupBox();
	shortcut = false;
	if (determineIfFiji()) {
		key_bind = "F3";
		if (user_choice) {
			// create shortcut, shortcut MUST come after installation, if applicable...
			shortcut = true;
			run("Install... ", "install=" + macro_tool_file_path);
			run("Add Shortcut... ", "shortcut=" + key_bind + " command=[Lipid Viral Analysis Tool]");
		} else {run("Install... ", "install=" + macro_tool_file_path);}
	} else {
		if (user_choice) {shortcut = true;}
		handleImageJ(user_choice, kasson_lib_dir);
	} setStatus(status_filepath, shortcut);
}


main();
