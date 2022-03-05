
function date_string = get_savefile_date(filename)

filename = strrep(filename, '.mat', '');
filename = strrep(filename, 'data_', '');

name_parts = strsplit(filename, {'_', '-'});

switch name_parts(2)
    case 'Gen'
        month = "01";
    case 'Feb'
        month = "02";
    case 'Mar'
        month = "03";
    case 'Apr'
        month = "04";
    case 'May'
        month = "05";
    case 'Jun'
        month = "06";
    case 'Jul'
        month = "07";
    case 'Aug'
        month = "08";
    case 'Sep'
        month = "09";
    case 'Oct'
        month = "10";
    case 'Nov'
        month = "11";
    case 'Dec'
        month = "12";
end

date_string = name_parts(3) + month + name_parts(1) + "_" + ...
    name_parts(4) + name_parts(5) + "_";

end