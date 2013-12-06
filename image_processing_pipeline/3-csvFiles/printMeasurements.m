% For each run of CellProfiler, the output MAT file generated is stored
% and has all of the image data. The list of MAT files that are to be 
% processed is passed into this program in a file named 'FileList'

% For each output file that is generated for each batch processed in
% CellProfiler, it goes through the files processed and creates CSV
% files with the output for each one. As a result, each plate's data
% is stored in a separate CSV file with the file name information
% still being stored for mapping to ORF and condition information at
% a later step in the pipeline.

fileList = importdata('FileList');
for k=1:length(fileList)   % Go through each batch MAT file
    fprintf(1,'Processing %s ....\n',fileList{k});
    load(fileList{k});
    fileNameList = handles.Measurements.Image.FileNames;    % All of the files in the batch
    objectAttrList = handles.Measurements.Spots.AreaShape;  % Info about the shape of each detected colony in the grid
    objectCoordList = handles.Measurements.Spots.Location;  % Info about the location of each detected colony in the grid
    % Information about the pixel location of each colony on the plates
    gridObjCoordList = handles.Measurements.GriddedSpots.Location;  % Information from each grid

    for i=1:length(fileNameList)        % Go through each file - i.e each plate
        thisFile = fileNameList{i};     % and create new CSV file to store measurements
        fileName = strtok(thisFile,'.');
        fid=fopen(char(strcat('csvFiles/',fileName,'.csv')),'w');
        fprintf(fid,'Index\tx Coord\ty Coord\tArea\tEccentricity\tPerimeter\n');
        
        % Get information for the current plate being looked at
        thisObjAttrList = objectAttrList{i};
        thisObjCoordList = objectCoordList{i};
        thisGridCoords = gridObjCoordList{i};   % x and y coordinates
        indeces = (1:length(thisObjCoordList));
        
        for j=1:length(thisGridCoords)
            % These statements check whether CellProfiler actually detected
            % a colony in the grid. If it didn't, it simply prints zeroes
            % in those places. Else, it prints the data.
            xCoord = thisGridCoords(j,1);
            yCoord = thisGridCoords(j,2);
            spotXlist = find(thisObjCoordList(:,1) == xCoord);
            spotXyIndex = find(thisObjCoordList(spotXlist,2)==yCoord);
           
            objectIndex = indeces(spotXlist(spotXyIndex));
            
            if(~isempty(objectIndex))
                fprintf(fid,'%d\t%f\t%f\t%f\t%f\t%f\n', ...
                    j-1, ...            % Index of colony in image file
                    xCoord, ...         % x-coord based on gridding
                    yCoord, ...         % y-coord based on gridding
                    thisObjAttrList(objectIndex,1), ... % Area
                    thisObjAttrList(objectIndex,2),...  % Eccentricity
                    thisObjAttrList(objectIndex,6));    % Perimeter
             else
                fprintf(fid,'%d\t%f\t%f\t%f\t%f\t%f\n',j-1,xCoord,yCoord,0,0,0);
            end
            %    size(spotXyIndex)
            %    display(objectIndex)
            %    display(thisGridCoords(j,1:2));
            %    display(thisObjCoordList(objectIndex,1:2));
            %    display('--------------');
        end
        fclose(fid);
    end
end