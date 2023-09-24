function vec = readFromC(fileName)
fileID = fopen(fileName,'r');
if fileID<0
    error("fail to open %s, maybe it doesn't exist.\n", fileName);
end
vec = fread(fileID, 'double');
fclose(fileID);
end

