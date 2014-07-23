%{
%}
function [alph trans_code] = init_cypher(ascii, freq_ascii, freq_code, trans_ascii, trans_code)
	
	% set cypher based on most likely character
	
	len_ascii = length(ascii);

	% rank the indices of ascii
	[garbage ascii_max] = sort(freq_ascii, 'descend');
	
	% rank the indices of code
	[garbage code_max] = sort(freq_code, 'descend');

	% init alph
	alph = ascii;
	% init the new ordering of alph
	ordered = 1:len_ascii;
	for ii=1:len_ascii
		ordered(ascii_max(ii)) = code_max(ii);
	end
	
	% fix alph
	alph = alph(ordered);
	trans_code = trans_code(ordered,:);
	trans_code = trans_code(:,ordered);

	%{
	for ii=1:len_ascii
		disp(sprintf('%5i %5c     | %5i %5c     | %5i %5c     | %5i %5c%1c', ii, ascii(ii), ascii_max(ii), ascii(ascii_max(ii)), code_max(ii), alph(code_max(ii)), ordered(ii), ascii(ii), alph(ii)))
	end
	%}
end
