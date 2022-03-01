function template_BUSCreator()
% TEMPLATE_BUSCREATOR
clear elems name_type;

% specify the signal names and types

name_type = {
    'variable_1',   'double', 'unit' %[-]
    'variable_2',   'double', 'unit' %[-]
    'variable_3',   'double', 'unit' %[-]
};

for i=1:size(name_type,1)
    elems(i) = Simulink.BusElement;
    elems(i).Name = char(name_type(i,1));
    elems(i).Dimensions = 1;
    elems(i).DimensionsMode = 'Fixed';
    elems(i).DataType = char(name_type(i,2)); 
    elems(i).SampleTime = -1;
    elems(i).Complexity = 'real';
    elems(i).SamplingMode = 'Sample based';
    elems(i).Min = [];
    elems(i).Max = [];
    elems(i).Unit = char(name_type(i,3));
end

template_BUS = Simulink.Bus;
template_BUS.HeaderFile = '';
template_BUS.Description = 'template_BUS';
template_BUS.Elements = elems;
assignin('base', 'template_BUS', template_BUS);

