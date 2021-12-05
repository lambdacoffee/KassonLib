/*
 * 
*/
 
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

function main() {
	//trace_drawings_subdir = getArgument();
	trace_drawings_subdir = "C:\\Users\\marcos\\Desktop\\20211201-Marcos_Analysis\\TraceAnalysis\\TraceDrawings\\";
	file_lst = getFileList(trace_drawings_subdir);
	for (i=0; i<file_lst.length; i++) {
		filename = file_lst[i];
		filepath = trace_drawings_subdir + filename;
		open(filepath);
		id = getImageID();
		selectImage(id);
		title = File.nameWithoutExtension;
		// make the new functions available
		// start a new PDF document
		Ext.newPDF(trace_drawings_subdir+title+".pdf");
		for (n=1; n<nSlices+1; n++) {
			setSlice(n);
			// add the sample image with different alignments and scales
			Ext.addImage("center", 1);
			// add a new page
			if (n%3 == 0) {Ext.addPage();}
		} setSlice(nSlices);
		if (nSlices%3 == 0) {Ext.addPage();}
		Ext.addImage("center", 1);
		Ext.closePDF();
		selectImage(id);
		close();
	}
}

isFiji = determineIfFiji();
if (isFiji) {
	plugins_dir = getDirectory("plugins");
	pdf_macro_path = plugins_dir + "pdf_macroext-20130327.jar";
	if (!File.exists(pdf_macro_path)) {
		msg = "FATAL ERROR - pdf_macroext-20130327.jar not found in plugins subdirectory!";
		msg += "\nTERMINATING SEQUENCE - ABORT PROCESS";
		exit(msg);
	} run("pdf macro ext");
	main();
}
