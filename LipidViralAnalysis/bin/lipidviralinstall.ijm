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

function handleImageJ(user_choice) {
	macrodir = getDirectory("macros");
	startup_macros_path = macrodir + "StartupMacros.txt";
	startup_macros_txt = File.openAsString(startup_macros_path);
	imagej_interface_path = macrodir + "KassonLib" + File.separator + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "imagejinterface.ijm";
	imagej_interface_txt = File.openAsString(imagej_interface_path);
	if (!user_choice) {
		key_bind = "";
		imagej_interface_txt_head = substring(imagej_interface_txt, 0, indexOf(imagej_interface_txt, " [L]"));
		imagej_interface_txt_tail = substring(imagej_interface_txt, indexOf(imagej_interface_txt, " [L]")+4);
		imagej_interface_txt = imagej_interface_txt_head + imagej_interface_txt_tail;
		imagej_interface_file = File.open(imagej_interface_path);
		print(imagej_interface_file, imagej_interface_txt);
		File.close(imagej_interface_file);
	} else {key_bind = " [L]";}
	combo_txt = startup_macros_txt + "\n\n" + imagej_interface_txt;
	new_startup_macros_file = File.open(startup_macros_path);
	print(new_startup_macros_file, combo_txt);
	File.close(new_startup_macros_file);
	message = "Installation complete - Lipid Viral Analysis Tool will be available";
	message += "\non the following menu path of the ImageJ toolbar:";
	message += "\nMacros >>> Lipid Viral Analysis Tool" + key_bind;
	showMessage("Completed Installation!", message);
}

function setupBox() {
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
	// returns true if uninstalled	
	if (File.exists(status_filepath)) {
		status = File.openAsString(status_filepath);
		if (indexOf(status, "uninstalled") != -1)
			{return true;}
		else {return false;}
	} else {exit("Status log File missing, unknown state - TERMINATING SEQUENCE, ABORT PROCESS.");}
}

function setStatus(status_filepath, shortcut) {
	status_novus = "installed";
	if (shortcut) {status_novus = status_novus + ",shortcut";}
	status_file = File.open(status_filepath);
	print(status_file, status_novus);
	File.close(status_file);
}

function main() {
	macrodir = getDirectory("macros");
	status_filepath = macrodir + "KassonLib" + File.separator + "LipidViralAnalysis" + File.separator + "log" + File.separator + "status.txt";
	if (!getStatus(status_filepath)) {
		exit("Lipid Viral Analysis already installed!");
	} macro_tool_file_path = macrodir + "KassonLib" + File.separator + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "Lipid_Viral_Analysis_Tool.ijm";
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
		handleImageJ(user_choice);
	} setStatus(status_filepath, shortcut);
}


main();
