function matSizeBytes_ret = matSizeBytes(array)
    size = numel(array);
    datatype = class(array);
    switch (datatype)
        case 'single'
            matSizeBytes_ret = size*4;
        case 'double'
            matSizeBytes_ret = size*8;
        case {'int8', 'uint8', 'char'}
            matSizeBytes_ret = size;
        case {'int16', 'uint16'}
            matSizeBytes_ret = size*2;
        case {'int32', 'uint32'}
            matSizeBytes_ret = size*4;
        case {'int64', 'uint64'}
            matSizeBytes_ret = size*8;
        otherwise
            error (['data type', dataType ,'is not supported. Exit...']);
    end

end

