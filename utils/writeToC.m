function writeToC(data, fileName)
    %input
    %data = [-1, 2, -3
    %             4, -5, 6];
    %fileName="testdata.bin";
    %parse input
    %store metadata of data to fileName in the following format
    %------------------------------------------------------------------
    %0-3  bytes: number of row in uint32
    %4-7  bytes: number of columns in uint32
    %8-15 bytes: data type in string, ended with NULL. 
    %            E.g. double, single, int32, uint16, ...
    %16--end   : data content
    %%

    dataShape = size(data); %in bytes
    dataType = char(zeros(1,8));
    type = class(data); %in string
    for i=1:numel(type)
        dataType(i)=type(i);
    end

    fileID = fopen(fileName,'w');
    fwrite(fileID, dataShape, 'uint32');
    fwrite(fileID, dataType, 'char');
    fwrite(fileID, data, class(data));
    fclose(fileID);
end