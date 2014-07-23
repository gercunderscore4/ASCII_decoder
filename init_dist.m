%{
	this function builds several, layered matrices
	first, it takes in trans_ascii, the first order transition count of book
	then it produces col_sum, a sum of each colum
	then it builds pr_mat, a probabilty matrix, normalized by col (or zero if col empty)
	then it takes the logarithm of pr_mat, and returns this
	
	this produces a logrithmic, first-order transition distribution based on book
%}
function [logmat] = init_dist(trans_ascii)
	% calculate transition probability distribution
	len_ascii = size(trans_ascii,1);
	col_sum = zeros(1,len_ascii);
	pr_mat = zeros(len_ascii,len_ascii);
	logmat = zeros(len_ascii,len_ascii);
	
	for ii=1:len_ascii
		col_sum(ii) = sum(trans_ascii(ii,:));
		for jj=1:len_ascii
			if col_sum(ii) ~= 0
				pr_mat(ii,jj) = trans_ascii(ii,jj)/col_sum(ii);
			end
			if pr_mat(ii,jj) == 0
				logmat(ii,jj) = -12;
			else
				logmat(ii,jj) = log(pr_mat(ii,jj));
			end
		end
	end
end
