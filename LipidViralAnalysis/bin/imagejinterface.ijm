macro "Lipid Viral Analysis Tool [L]" {
	macrodir = getDirectory("macros");
	macro_path = macrodir + "KassonLib" + File.separator + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "Lipid_Viral_Analysis_Tool.ijm";
	runMacro(macro_path);
}
