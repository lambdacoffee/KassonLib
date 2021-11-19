/*
*
*/


function determineIfFiji() {
	startup_path = getDirectory("startup");
	startup_path_split = split(startup_path, File.separator);
	if (indexOf(startup_path_split[startup_path_split.length-1], "Fiji") != -1)
		{return true;}
	else {return false;}
}

function resetInterface(interface_filepath) {
	imagej_interface_txt = File.openAsString(interface_filepath);
	if (indexOf(imagej_interface_txt, "[L]") == -1) {
		// must restore to original
		interface_txt_head = substring(imagej_interface_txt, 0, indexOf(imagej_interface_txt, "{")-2);
		interface_txt_tail = substring(imagej_interface_txt, indexOf(imagej_interface_txt, "{")-2);
		interface_txt = interface_txt_head + " [L]" + interface_txt_tail;
		interface_file = File.open(interface_filepath);
		print(interface_file, interface_txt);
		File.close(interface_file);
	}
}

function handleImageJ() {
	macrodir = getDirectory("macros");
	startup_macros_path = macrodir + "StartupMacros.txt";
	startup_macros_txt = File.openAsString(startup_macros_path);
	imagej_interface_path = macrodir + "KassonLib" + File.separator + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "imagejinterface.ijm";
	imagej_interface_txt = File.openAsString(imagej_interface_path);
	startup_text_head = substring(startup_macros_txt, 0, indexOf(startup_macros_txt, "macro \"Lipid Viral Analysis Tool"));
	startup_text_tail = substring(startup_macros_txt, indexOf(startup_macros_txt, "macro \"Lipid Viral Analysis Tool"));
	startup_text_tail = substring(startup_text_tail, indexOf(startup_text_tail, "}")+1);
	startup_macros_txt = startup_text_head + "\n" + startup_text_tail;
	new_startup_macros_file = File.open(startup_macros_path);
	print(new_startup_macros_file, startup_macros_txt);
	File.close(new_startup_macros_file);
	resetInterface(imagej_interface_path);
}

function uninstallBox() {
	title = "Startup Lipid Viral Analysis Uninstaller";
	if (determineIfFiji()) {Dialog.createNonBlocking(title);}
	else {Dialog.create(title);}
	message = "Preparing to uninstall Lipid Viral Analysis Tool...";
	message += "\nContinue with uninstallation?";
	Dialog.addMessage(message);
	items = newArray("Yes", "No");
	Dialog.addRadioButtonGroup("Choice", items, 1, 2, items[0]);
	Dialog.show();
	choice = Dialog.getRadioButton();
	return choice;
}

function getKassonLibDir() {
	res_dir = getDirectory("macros") + "KassonLib" + File.separator;	
	if (!File.exists(res_dir)) {
		res_dir = getDirectory("macros") + "KassonLib-master" + File.separator;
		if (!File.exists(res_dir)) {
			kasson_lib_info_path = getDirectory("macros") + "KassonLibInfo.txt";
			if (!File.exists(kasson_lib_info_path)) {
				res_dir = "";
			} else {
				res_dir = File.openAsString(kasson_lib_info_path);
				res_dir = replace(res_dir, "\n", "");
				if (!File.exists(res_dir)) {
					res_dir = "";
				}
			}
		}
	} return res_dir;
}

function getStatus(kasson_lib_dir) {
	// returns true if shortcut needs to be removed, otherwise returns false
	// exits if LVA is not installed so as not to throw error.
	status_filepath = kasson_lib_dir + "LipidViralAnalysis" + File.separator + "log" + File.separator + "status.txt";
	if (File.exists(status_filepath)) {
		status = File.openAsString(status_filepath);
		if (indexOf(status, "uninstalled") != -1)
			{exit("Lipid Viral Analysis Tool is not installed!");}
		if (indexOf(status, "shortcut") != -1) {
			// need to remove shortcut
			return true;
		} return false;
	} else {exit("Status log File missing, unknown state - TERMINATING SEQUENCE, ABORT PROCESS.");}
}

function setStatus(kasson_lib_dir) {
	status_filepath = kasson_lib_dir + "LipidViralAnalysis" + File.separator + "log" + File.separator + "status.txt";
	status_novus = "uninstalled";
	status_file = File.open(status_filepath);
	print(status_file, status_novus);
	File.close(status_file);
}

function main() {
	user_choice = uninstallBox();
	if (user_choice != "Yes") {exit();}
	kasson_lib_directory = getKassonLibDir();
	status = getStatus(kasson_lib_directory);	// true if shortcut is present & needs to be removed
	if (determineIfFiji()) {
		plugins = getDirectory("plugins");
		tool_path = plugins + "Tools" + File.separator + "Lipid_Viral_Analysis_Tool.ijm";
		platform = "Fiji";
		if (File.exists(tool_path)) {deletion = File.delete(tool_path);}		
	} else {
		platform = "ImageJ";
		handleImageJ();
	} if (status) {
		run("Remove Shortcut...", "shortcut=[Lipid Viral Analysis Tool]");
	} setStatus(kasson_lib_directory);
	showMessage("Complete!", "Uninstallation complete.\nRestart " + platform + ".");
	run("Quit");
}


main();
