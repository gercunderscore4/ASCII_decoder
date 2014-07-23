%{
%}
function write_table(tablename, freq_ascii, trans_ascii)

	len_ascii = length(freq_ascii);

	% open file to write
	tablefile = fopen(tablename, 'w');
	
	% write
	% freq_ascii
	for ii=1:len_ascii
		fprintf(tablefile, '%.10f ', freq_ascii(ii));
	end
	% freq_ascii
	for ii=1:len_ascii
		for jj=1:len_ascii
			fprintf(tablefile, '%.10f ', trans_ascii(ii,jj));
		end
	end
	
	fclose(tablefile);
end
