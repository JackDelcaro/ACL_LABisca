% Copyright 2021 The MathWorks, Inc.
function policy_new = cut_unnecessary_layers_for_SAC_policy(policy)
%%
lgraph = layerGraph(policy);
% 
% remove tanh and scaling layers
lgraph = removeLayers(lgraph,{'ActorTanh','ActorScaling'});
lgraph2 = connectLayers(lgraph,'ActorFC3','RepresentationLoss');
% create new policy 
policy_new = assembleNetwork(lgraph2);

end

