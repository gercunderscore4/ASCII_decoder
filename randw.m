%{
	weighted random number generator
%}
function [r] = randw(options, weights, nn)
	r = zeros(1,nn);
	
	% disallow zeros
	if sum(weights) == 0
		weights = ones(size(weights));
	end
	
	for jj=1:nn
		% probability
		p = rand(1) * sum(weights); % just in case not normal
		% keep track of sum of weights
		t_weight = 0;
		for ii=1:length(weights)
			t_weight = t_weight + weights(ii);
			if p <= t_weight
				r(jj) = options(ii);
				break
			end
		end
	end
end
