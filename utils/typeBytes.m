function typeBytes_ret = typeBytes(array)
    datatype = class(array);
    switch (datatype)
        case 'single'
            typeBytes_ret = 4;
        case 'double'
            typeBytes_ret = 8;
        case {'int8', 'uint8', 'char'}
            typeBytes_ret = 1;
        case {'int16', 'uint16'}
            typeBytes_ret = 2;
        case {'int32', 'uint32'}
            typeBytes_ret = 4;
        case {'int64', 'uint64'}
            typeBytes_ret = 8;
        otherwise
            error (['data type', dataType ,'is not supported. Exit...']);
    end

end

