mid_features = {};
fast_features = {};
slow_features = {};
samPeriod = {};
paramKind = {};

[mid_features{1},samPeriod{1},paramKind{1}] = readhtk_lite('MFCC\mid-jiaotongdaxue.mfc');
[mid_features{2},samPeriod{2},paramKind{2}] = readhtk_lite('MFCC\mid-jiaotongdaxuezan.mfc');
[mid_features{3},samPeriod{3},paramKind{3}] = readhtk_lite('MFCC\mid-jiaotongdadui.mfc');
[mid_features{4},samPeriod{4},paramKind{4}] = readhtk_lite('MFCC\mid-jiaotongdaduilan.mfc');
[mid_features{5},samPeriod{5},paramKind{5}] = readhtk_lite('MFCC\mid-xinhaochuli.mfc');
[mid_features{6},samPeriod{6},paramKind{6}] = readhtk_lite('MFCC\mid-yuyinxinhao.mfc');
[mid_features{7},samPeriod{7},paramKind{7}] = readhtk_lite('MFCC\mid-yuyinchuli.mfc');

[fast_features{1},samPeriod{1},paramKind{1}] = readhtk_lite('MFCC\fast-jiaotongdaxue.mfc');
[fast_features{2},samPeriod{2},paramKind{2}] = readhtk_lite('MFCC\fast-jiaotongdadui.mfc');
[fast_features{3},samPeriod{3},paramKind{3}] = readhtk_lite('MFCC\fast-xinhaochuli.mfc');
[fast_features{4},samPeriod{4},paramKind{4}] = readhtk_lite('MFCC\fast-yuyinxinhao.mfc');
[fast_features{5},samPeriod{5},paramKind{5}] = readhtk_lite('MFCC\fast-yuyinchuli.mfc');

[slow_features{1},samPeriod{1},paramKind{1}] = readhtk_lite('MFCC\slow-jiaotongdaxue.mfc');
[slow_features{2},samPeriod{2},paramKind{2}] = readhtk_lite('MFCC\slow-jiaotongdadui.mfc');
[slow_features{3},samPeriod{3},paramKind{3}] = readhtk_lite('MFCC\slow-xinhaochuli.mfc');
[slow_features{4},samPeriod{4},paramKind{4}] = readhtk_lite('MFCC\slow-yuyinxinhao.mfc');
[slow_features{5},samPeriod{5},paramKind{5}] = readhtk_lite('MFCC\slow-yuyinchuli.mfc');

for i = 1:5
% Test data and template
template = mid_features{1};
test_data = slow_features{i};

template_len = size(template,1);
test_len = size(test_data,1);

% Set available path
available_path = {};
available_path{1} = [0,1];
available_path{2} = [1,0];
available_path{3} = [1,1];
available_path{4} = [0,2];
available_path{5} = [2,0];

% Find optimal path and cost
path_cost = 0;
optimal_path = {};

% Current Index
tem_index = 1;
test_index = 1;

% Store optimal path
path_index = 1;
optimal_path{path_index} = [tem_index, test_index];
path_index = path_index + 1;

% Number of MFCC Features
feature_len = size(template,2);
path_cost = compute_cost(template(tem_index,:),test_data(test_index,:),feature_len);

while(1)
	min_cost = 999999;
	for step_forward = 1:size(available_path,2) % compute cost of all neighbouring nodes
		cost = compute_cost(template(tem_index+available_path{step_forward}(1),:), ...
			test_data(test_index+available_path{step_forward}(2),:),feature_len);
		if(cost < min_cost) % find the node with the minimum cost
			min_cost = cost;
			min_tem_index = tem_index+available_path{step_forward}(1);
			min_test_index = test_index+available_path{step_forward}(2);
		end
	end
	% update all necessary information
	tem_index = min_tem_index;
	test_index = min_test_index;
	path_cost = path_cost + min_cost;
	optimal_path{path_index} = [tem_index, test_index];
	path_index = path_index + 1;
	if(tem_index+2>=template_len || test_index+2>=test_len);
		break;
	end
end

% Fills the rest of the speech segment and add to existing cost
if(tem_index+2>=template_len && test_index+2<test_len)
	while(1)
		cost = compute_cost(template(tem_index,:), test_data(test_index+1,:),feature_len);
		path_cost = path_cost + min_cost;
		optimal_path{path_index} = [tem_index, test_index+1];
		test_index = test_index+1;
		path_index = path_index + 1;
		if(test_index+2==test_len)
			break;
		end
	end
elseif(test_index+2>=test_len && tem_index+2<template_len)
	while(1)
		cost = compute_cost(template(tem_index+1,:), test_data(test_index,:),feature_len);
		path_cost = path_cost + min_cost;
		optimal_path{path_index} = [tem_index+1, test_index];
		tem_index = tem_index+1;
		path_index = path_index + 1;
		if(tem_index+2==template_len)
			break;
		end
	end
end

disp(path_cost)
end

plot_opt_path_X = int16.empty(size(optimal_path,2),0);
plot_opt_path_Y = int16.empty(size(optimal_path,2),0);

for ind = 1:size(optimal_path,2)
	plot_opt_path_X(ind) = optimal_path{ind}(1);
	plot_opt_path_Y(ind) = optimal_path{ind}(2);
end

plot(plot_opt_path_X,plot_opt_path_Y)
title 'DTW'
xlabel 'Template', ylabel 'Test Data';