startup_dir = getDirectory("startup");
install_filepath = startup_dir + "macros" + File.separator + "KassonLib" + File.separator + "LipidViralAnalysis" + File.separator + "bin" + File.separator + "lipidviralinstall.ijm";
run("Install...", "install=" + install_filepath);
run("lipidviralinstall");
