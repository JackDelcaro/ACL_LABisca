function action1 = evaluatePolicy(observation1)
%#codegen

% Reinforcement Learning Toolbox
% Generated on: 03-Jan-2022 12:16:44

action1 = localEvaluate(observation1);
end
%% Local Functions
function action1 = localEvaluate(observation1)
persistent policy
if isempty(policy)
	policy = coder.loadDeepLearningNetwork('QubeIPBalRLPolicy.mat','policy');
end
action1 = predict(policy, observation1);
end