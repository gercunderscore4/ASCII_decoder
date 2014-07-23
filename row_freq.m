%{
%}
function [temp] = row_freq (mat)
	temp = zeros(1,length(mat));
	for ii=1:length(temp)
		temp(ii) = sum(mat(ii,:));
	end
	temp = temp / sum(mat(:));
end
