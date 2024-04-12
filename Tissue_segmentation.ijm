//  Copyright (C) 2016, Takahiro Tsujikawa, ROhan N, Borkar and Vahid Azimi.
//  Copyright (C) 2021, Kohsuke Isomoto
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

//Drag and drop panCK image (after AEC extraction) to define input directory.
//Then press Run

//Inputdirectory
inputdirectory = getInfo("image.directory");

//Outputdirectory
outputdirectory = inputdirectory+"Segmentation"+"/";
File.makeDirectory(outputdirectory);

//noblank, tumornest, stroma folder creation
outputdirectory2 = inputdirectory+"01_noblank"+"/";
File.makeDirectory(outputdirectory2);

outputdirectory3 = inputdirectory+"02_tumornest"+"/";
File.makeDirectory(outputdirectory3);

outputdirectory4 = inputdirectory+"03_stroma"+"/";
File.makeDirectory(outputdirectory4);

//Closing
setMinAndMax(0, 200);
run("Apply LUT");
run("Make Binary");
run("Options...", "iterations=18 count=1 black do=Dilate");
run("Options...", "iterations=15 count=1 black do=Erode");

	newname = "tumornest.tif";
	saveAs("Tiff", outputdirectory+newname);

//fetch Hematoxylin image
list = getFileList(inputdirectory)
open(inputdirectory + list[3]);

//PanCK binary image(tumornest.tif)→hematoxylin
//0002:hematoxylin
run("Images to Stack", "name=Stack title=[]");
run("Stack to Images");
selectWindow("Stack-0001");
run("Invert");

imageCalculator("OR create", "Stack-0001","Stack-0002");

selectWindow("Stack-0001");
close();

selectWindow("Stack-0002");
close();

selectWindow("Result of Stack-0001");
	newname = "02_tumornest_Hematoxylin.tif";
	saveAs("Tiff", outputdirectory+newname);

list = getFileList(inputdirectory)
open(inputdirectory + list[4]);
	newname = getTitle();
	close();
	
selectWindow("02_tumornest_Hematoxylin.tif");
	saveAs("Tiff", outputdirectory3+newname);
	close();
	
//Blank
list = getFileList(inputdirectory)
open(inputdirectory + list[3]);
setOption("BlackBackground", true);
run("Make Binary");
run("Options...", "iterations=15 count=1 black do=Dilate");
run("Options...", "iterations=18 count=1 black do=Erode");
run("Invert");
	newname = "blank.tif";
	saveAs("Tiff", outputdirectory+newname);

list = getFileList(inputdirectory)
open(inputdirectory + list[3]);
run("Images to Stack", "name=Stack title=[]");
run("Stack to Images");
imageCalculator("OR create", "Stack-0001","Stack-0002");

selectWindow("Stack-0002");
close();
selectWindow("Stack-0001");
close();

selectWindow("Result of Stack-0001");
	newname = "01_noblank_Hematoxylin.tif";
	saveAs("Tiff", outputdirectory+newname);

list = getFileList(inputdirectory)
	open(inputdirectory + list[4]);
	newname = getTitle();
	close();
	
	selectWindow("01_noblank_Hematoxylin.tif");
	saveAs("Tiff", outputdirectory2+newname);
	close();

//Stroma
open(outputdirectory + "tumornest.tif");
selectWindow("tumornest.tif");
open(outputdirectory + "blank.tif");
selectWindow("blank.tif");
imageCalculator("OR create", "blank.tif","tumornest.tif");

selectWindow("tumornest.tif");
close();
selectWindow("blank.tif");
close();

selectWindow("Result of blank.tif");
	newname = "tumornest_blank.tif";
	saveAs("Tiff", outputdirectory+newname);
	
list = getFileList(inputdirectory)
open(inputdirectory + list[3]);
run("Images to Stack", "name=Stack title=[]");
run("Stack to Images");
imageCalculator("OR create", "Stack-0001","Stack-0002");

selectWindow("Stack-0002");
close();
selectWindow("Stack-0001");
close();

selectWindow("Result of Stack-0001");
	newname = "03_stroma_Hematoxylin.tif";
	saveAs("Tiff", outputdirectory+newname);

list = getFileList(inputdirectory)
	open(inputdirectory + list[4]);
	newname = getTitle();
	close();
	
	selectWindow("03_stroma_Hematoxylin.tif");
	saveAs("Tiff", outputdirectory4+newname);
	close();
	
//mesure binary data
list = getFileList(inputdirectory)
open(inputdirectory + list[3]);
	name = getTitle();
	sub = substring(name,0,12);
	close();
	
a = split(inputdirectory, File.separator);
b = a[a.length-1]

open(outputdirectory + "blank.tif");
selectWindow("blank.tif");
run("Invert");
	newname = "noblank.tif";
	saveAs("Tiff", outputdirectory+newname);
	newname = "noblank_" + sub + "_" + b;
	rename(newname);
	run("Measure");
	close();

open(outputdirectory + "tumornest.tif");
selectWindow("tumornest.tif");
	newname = "tumornest_" + sub + "_" + b;
	rename(newname);
	run("Measure");
	close();

open(outputdirectory + "tumornest_blank.tif");
selectWindow("tumornest_blank.tif");
run("Invert");
	newname = "stroma.tif";
	saveAs("Tiff", outputdirectory+newname);
	newname = "stroma_" + sub + "_" + b;
	rename(newname);
	run("Measure");
	close();

//copy Round2 to Round17
list = getFileList(inputdirectory);

for (i=5; i<21; i++){
	
	open(inputdirectory+list[i]);
	
	name = getTitle();

	saveAs("Tiff", outputdirectory2 + name);
	saveAs("Tiff", outputdirectory3 + name);
	saveAs("Tiff", outputdirectory4 + name);
	close();
}

open(inputdirectory+list[19]);
setMinAndMax(0, 200);
run("Apply LUT");
name = getTitle();
	saveAs("Tiff", outputdirectory2 + name);
	saveAs("Tiff", outputdirectory3 + name);
	saveAs("Tiff", outputdirectory4 + name);
	close();

showMessage("Finished");