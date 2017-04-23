function [ cost ] = compute_cost( template, test_data, feature_len )
	distance = 0;
	for fea_num = 1:feature_len
		distance = distance + (template(fea_num) - test_data(fea_num))^2;
	end
	cost = distance ^ 0.5;
