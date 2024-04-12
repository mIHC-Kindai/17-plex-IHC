//  Copyright (C) 2016, Takahiro Tsujikawa, ROhan N, Borkar and Vahid Azimi.
//  Copyright (C) 2021, Takahiro Tsujikawa
//
//  This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.

//AEC extraction plus hematoxylin
macro "AEC extraction batch" {
	setBatchMode(true);
	//input should be file path to Registered ROI directory or single R1, R2, R3 folder
	input = getArgument; 
	if(input =="");
	input = getDirectory("Select the folder");

	parent = File.getParent(input);
	output = parent+"/Processed";

	if(!File.exists(output)) {
		File.makeDirectory(output);
	}

	suffix =".tif" ;

	ndir = getFileList(input);
	for (n=1; n<ndir.length+1; n++) {
		Rsave = output+File.separator+"R"+n+"";
			if(!File.exists(Rsave))
			File.makeDirectory(Rsave);
		processRFolder(input+ndir[n-1]);
	}
}

function processRFolder(input) {
	list = getFileList(input);
	for (i = 1; i < list.length+1; i++) {
		if(File.isDirectory(input + list[i-1]))
			processRFolder("" + input + list[i-1]);
			else {
				for (i = 1; i < list.length+1;i++) {
					if(endsWith(list[i-1], suffix)||endsWith(list[i-1], ".tiff")) {
						process_AEC_Q(input, output, list[i-1]);
						
					}
				}
			}
	 }
}


function process_AEC_Q(input, output, filename) {

	//for Nuclei file
		if (startsWith(filename, "NUCLEI_")==1) {
			open(input+filename);
			NucOG = getTitle();
			print("Nuclei image for Q ", NucOG);
			saveAs("Tiff", Rsave+File.separator+filename);
    		print(" Original Nuclei image saved." );
    		Nuc = getTitle();

			
	//if not Nuclei file
	}  else {
			open(input+filename);
			name = getTitle();
	        run("Colour Deconvolution", "vectors=[H AEC] hide");
			print(filename, " :filename");
			
			selectWindow(name+"-(Colour_2)" );
	        img2 = getImageID();

	        selectWindow(name+"-(Colour_3)" );
	        run("Invert");
	        img3 = getImageID();

	        selectWindow(name+"-(Colour_1)");
	        run("Invert");
	        img1 = getImageID();

	        imageCalculator("Add create", img2, img1);
	        new1 = getImageID();
	        newtitle1 = getTitle();

	        selectWindow(newtitle1);
			imageCalculator("Add create",new1, img3);
			final = getTitle();
			print("new image made", final);

			selectWindow(final);


	//saveAs("Tiff", output+title); for Q
			saveAs("Tiff", Rsave+File.separator+"Q_"+filename);
			print(output+final+" Q saved.");
	        selectWindow(newtitle1);
			close();
			selectWindow(filename+"-(Colour_1)");
			close("*-(Colour_1)");
			selectWindow(filename+"-(Colour_3)");
			close("*-(Colour_3)");
			selectWindow(filename+"-(Colour_2)");
			close("*-(Colour_2)");
			selectWindow(filename);
			close();
			close("*ROI1.tif");
	        close("*ROI2.tif");
	        close("*ROI3.tif");
	}	

	//Add Hematoxylin
		open(input+list[0]);
		R2save = output+File.separator+"R"+n+File.separator;
		name = getTitle();
		saveAs("Tiff", R2save+name);
		
}
print("Find all images in "+Rsave);

print("Finished");
showMessage("Finished");
