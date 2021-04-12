function main() {
	trace_drawings_subdir = getArgument();
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
			if (n%2 == 0) {Ext.addPage();}
		} Ext.closePDF();
		selectImage(id);
		close();
	}
}

run("pdf macro ext");
main();
run("Quit");
