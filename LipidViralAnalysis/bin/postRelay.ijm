/*
 * 
 */


function main() {
	parent_directory = getArgument();
	if (!endsWith(parent_directory, File.separator)) {
		parent_directory = parent_directory + File.separator;
	} info_filepath = parent_directory + "info.txt";
	trace_drawings_subdirectory = parent_directory + "TraceAnalysis" + File.separator + "TraceDrawings" + File.separator;

	bin_dir = File.getDefaultDir;
	boxification_macro_path = bin_dir + "boxification.ijm";
	tiff_pdf_macro_path = bin_dir + "tiff_to_pdf.ijm";
	boxified_intensities_macro_path = bin_dir + "boxified_intensities.ijm";

	boxy_arg = info_filepath + "," + "0";
	runMacro(boxification_macro_path, boxy_arg);
	runMacro(tiff_pdf_macro_path, trace_drawings_subdirectory);
	runMacro(boxified_intensities_macro_path, info_filepath);
}


main();
run("Quit");
