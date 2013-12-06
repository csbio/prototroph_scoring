% Splits images of two plates into two images of one plate each

% files.dat which is in the pwd contains a list of files in the
% directory inputPrefix/theFile (line read from files.dat)
% that must be split. 

inputPrefix='/home/syed/WinDesktop/090708_proto_con/';
outputPrefix = './split/';
fid = fopen('files.dat','r');
fidErr = fopen('errorFiles-test.dat','a');
fprintf(fidErr,'---- Start Processing ------\n');
while true
    theFile = fgetl(fid);
    if ~ischar(theFile), break, end
    inputFile = strcat(inputPrefix,theFile,'.jpg');
    fprintf(1,'Processing %s ....\n',inputFile);
    rawImage = imread(inputFile);
    [plates, numPlates] = getPlates(rawImage);
    if(numPlates < 2)
        fprintf(fidErr,'Error processing file : %s \n',inputFile);
    end
    for i = 1:numPlates
        outputFile = sprintf('%s%s-plate%d.tiff',outputPrefix,theFile,i);
        fprintf(1,'Output : %s\n',outputFile);
        imwrite(plates{i},outputFile,'TIFF');
    end
end
fclose(fid);
fclose(fidErr);
% rawImage = imread('time0_135.jpg');
% [plates, numPlates] = getPlates(rawImage);
