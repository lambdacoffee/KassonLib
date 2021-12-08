/*
 * 
 */


function main() {
	parent_directory = getArgument();
	if (!endsWith(parent_directory, File.separator)) {
		parent_directory = parent_directory + File.separator;
	} info_filepath = parent_directory + "info.txt";
	trace_drawings_subdirectory = parent_directory + "TraceAnalysis" + File.separator + "TraceDrawings" + File.separator;

	macros_dir = getDirectory("macros");
	kasson_lib_info_filepath = macros_dir + "KassonLibInfo.txt";
	kasson_lib_dir = File.openAsString(kasson_lib_info_filepath);
	kasson_lib_dir = substring(kasson_lib_dir, 0, lengthOf(kasson_lib_dir)-1);
	bin_dir = kasson_lib_dir + "LipidViralAnalysis" + File.separator + "bin" + File.separator;
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
