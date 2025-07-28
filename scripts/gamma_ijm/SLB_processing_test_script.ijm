function extractTraces(video_filepath) {
	pardir = File.getDirectory(video_filepath);
	open(video_filepath);
	vid_id = getImageID();
	Image.removeScale;
	run("Set Measurements...", "area mean bounding redirect=None decimal=3");
	num_particles = roiManager("count");
	particle_idx_array = newArray(num_particles);
	for (i=0; i<particle_idx_array.length; i++) {
	      particle_idx_array[i] = i;
	} roiManager("Select", particle_idx_array);
	roiManager("Multi Measure");
	saveAs("Results", pardir + File.separator + "InitialIntensityResults.csv");
	particle_str_array = newArray(num_particles * 2);
	for (n=1; n<num_particles; n++) {
		area = parseInt(getResultString("Area(" + d2s(n, 0) + ")", n));
		time_series_array = newArray(nResults);
		for (t=0; t<nResults; t++) {
			mean_intensity = getResultString("Mean(" + d2s(n, 0) + ")", t);
			time_series_array[t] = parseFloat(mean_intensity);
		} for (i=0; i<time_series_array.length; i++) {
			time_series_array[i] = time_series_array[i] * area;
		} raw_trace = String.join(time_series_array);
		print("@" + d2s(n, 0));
		print(raw_trace);
	} saveAs("text", pardir + File.separator + "RawIntensityTraces.txt");
}

extractTraces("C:\\Users\\marcos\\Desktop\\SLB_fusion_test\\video\\drifted-1_Well-1_green_virus_20min-pretrypsin-100ug_ex150ms_LI4_1_MMStack_Pos0.ome.tif");
