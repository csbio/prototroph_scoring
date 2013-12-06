#!/soft/ruby/1.9.1/ubuntuamd1/bin/ruby

require 'exifr'
#

def getImageExifTime(time, fileNum)
	imageFile = 'H:/ImageProcessing/1 - rawimages/090707_wildisolate-plate18/time'<<time.to_s<<'_'<<fileNum.to_s<<'.jpg'
	return File.stat(imageFile).mtime.to_f
#	return EXIFR::JPEG.new(imageFile).date_time
end	

def deInterlacePlates(spotIndex)
	rowIndex = 15-spotIndex/24;
	colIndex = 23-spotIndex%24;
	print("ERROR : invalid spot Index\n") if(rowIndex >= 16)
	delsetIndex = colIndex%2 + (rowIndex%2)*2;
	return [ delsetIndex, rowIndex/2, colIndex/2, rowIndex, colIndex];	
end

def read384PlateFileNameMap(plateFileNameMap)
	platenumMap = Hash.new;
	fileNameMap = File.open(plateFileNameMap);
	fileNameMap.each do |line|
		lineParts = line.chop.split("\t");
		plateNum = lineParts[0].to_i;
		condition1 = lineParts[1];
		condition2 = lineParts[2];
		time00FileNum = lineParts[3];
		time00TrayNum = lineParts[4];
		time05FileNum = lineParts[5];
		time05TrayNum = lineParts[6];
		time10FileNum = lineParts[7];
		time10TrayNum = lineParts[8];
		time24FileNum = lineParts[9];
		time24TrayNum = lineParts[10];
		time48FileNum = lineParts[11];
		time48TrayNum = lineParts[12];
		plateCondition = [plateNum, condition1, condition2];
		fileName00 = '0_'+time00FileNum + '_' + time00TrayNum;
		fileName05 = '5_'+time05FileNum + '_' + time05TrayNum;
		fileName10 = '10_'+time10FileNum + '_' + time10TrayNum;
		fileName24 = '24_'+time24FileNum + '_' + time24TrayNum;
		fileName48 = '48_'+time48FileNum + '_' + time48TrayNum;
		platenumMap[fileName00] = plateCondition;
		platenumMap[fileName05] = plateCondition;
		platenumMap[fileName10] = plateCondition;
		platenumMap[fileName24] = plateCondition;
		platenumMap[fileName48] = plateCondition;
	end
	fileNameMap.close();
	return platenumMap;
end

def readDelSetNumbers(delsetPlateMap)
	delSetPlateMap = Hash.new;
	delSetMap = File.open(delsetPlateMap)
	delSetMap.each do |line|
		lineParts = line.gsub(/delset/,'').split("\t");
		plateNum = lineParts[0].to_i;
		delsetList = lineParts[1..4].collect{|i| i.to_i}
		delSetPlateMap[plateNum] = delsetList;
	end
	delSetMap.close();
	return delSetPlateMap;
end

def readORFplateMaps(orfPlateMapFile)
	orfPlateMap = Hash.new;
	orfMapFile = File.open(orfPlateMapFile)
	orfMapFile.each do |line|
		lineParts = line.chop.split("\t");
		plateNum = lineParts[0];
		rowNum = lineParts[1].tr('A-H','0-8');
		colNum = lineParts[2].to_i - 1;
		orf = lineParts[3];
		orfPlateMap[[plateNum,rowNum,colNum].join("_")] = orf
	end
	return orfPlateMap;
end

#def getBadFileList(fileListName)
#	badFiles = Hash.new;
#	badFileList = File.open(fileListName)
#	badFileList.each do |line|
#		badFileName = line.split('/')[-1]
#		badFiles[badFileName.split('.')[0]] = true if(line[0] != '#');
#	end
#	return badFiles;
#end


begin
	if ARGV.length < 1
		$stderr.print("Usage : ",$0," csvfile [cvfile ...]\n");
		exit 1;
	end


	filePlateMap = read384PlateFileNameMap('wildIsolate.csv');
	plateDelSetMap = readDelSetNumbers('isolate delset map.csv');
	orfPlateMap = readORFplateMaps('isolate ORF map.csv');
#	badFileList = getBadFileList('prob-images.txt');
	ARGV.each do |file|
		pathParts = file.split('/');
		csvFile = pathParts[-1];
		csvFilePath = pathParts[0..-2].join('/');
		tempParts = csvFile.split('-',2);
		trayNum = tempParts[1][/[1-2]/];
		tempParts = tempParts[0].split('_');
		fileNum = tempParts[1];
		time = tempParts[0][/[0-9]{1,2}/];
#		badFile = badFileList[csvFile.split('.')[0]];
#		badFile = false if(badFile == nil);
		plateNumCondition = filePlateMap[[time,fileNum,trayNum].join('_')];
		deletionSets = plateDelSetMap[plateNumCondition[0]];
		$stdout.print(' Decoding file : ',csvFile,"\n");
		$stdout.print(' Tray Number   : ',trayNum,"\n");	
		$stdout.print(' File Number   : ',fileNum,"\n");
		$stdout.print(' Time          : ',time,"\n");
		$stdout.print(' Plate Number  : ',plateNumCondition[0],"\n");
		$stdout.print(' Conditions    : ',plateNumCondition[1..2].join(','),"\n");
		$stdout.print(' Deletion Sets : ',deletionSets.join(','),"\n");
		metricFile = File.open(file);
		line = metricFile.readline;
		outfile = [csvFilePath,'decodedcsv',csvFile.split('.',2)[0]<<'-decoded.csv'].join('/');
		fid=File.open(outfile,'w');
		fid.print("ORF\tCondition1\tCondition2\tfile num\tplate num\ttray num\ttime\tepoch time\trow index\tcol index\t",line.split("\t",2)[1]);
		metricFile.each do |line|
			tempParts=line.split("\t",2);
			index = tempParts[0].to_i;
#			if(badFile)
#				spotMetrics = "NaN\tNaN\tNaN\tNaN\tNaN\n";
#			else
				spotMetrics = tempParts[1];
#			end
			deInterlacedIndex = deInterlacePlates(index);
			delset = deletionSets[deInterlacedIndex[0]];
			orfKey = [delset,deInterlacedIndex[1..2]].join('_');
			delOrf = orfPlateMap[orfKey];
			epochTime = getImageExifTime(time, fileNum)
			fid.print([delOrf,plateNumCondition[1..2],fileNum,plateNumCondition[0],trayNum,time,epochTime,deInterlacedIndex[3..4],spotMetrics].join("\t"));
		end
		fid.close();
	end
end
