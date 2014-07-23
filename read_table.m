%{
%}
function [freq_ascii, trans_ascii] = read_table(tablename, len_ascii)

	% open file to read
	tablefile = fopen(tablename, 'r');
	
	% read
	% freq_ascii
	freq_ascii = zeros(1,len_ascii);
	freq_ascii = fscanf(tablefile, '%f', [1 len_ascii]);
	% freq_ascii
	trans_ascii = zeros(len_ascii,len_ascii);
	trans_ascii = fscanf(tablefile, '%f', [len_ascii len_ascii])';
	fclose(tablefile);
end
