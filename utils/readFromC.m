function vec = readFromC(fileName)
fileID = fopen(fileName,'r');
vec = fread(fileID, 'double');
fclose(fileID);
end

