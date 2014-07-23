clc
disp('BEGIN encrypt')

inputfile = 'text/sentence 7.txt';
outputfile = 'text/text07.txt';

inputf = fopen(inputfile, 'r');
outputf = fopen(outputfile, 'w');

if inputf ~= -1 & outputf ~= -1

	% ascii
	for ii=1:95
		ascii(ii) = sprintf('%c',ii+31);
	end
	len_ascii = length(ascii);

	% initialize cypher
	alph = shuffle(ascii);

	goodtext = fgetl(inputf);

	[badtext] = write_decoded(goodtext, alph, ascii);

	fprintf(outputf, '%s', badtext);

	fclose(inputf);
	fclose(outputf);
	
	disp('success')
else
	disp('failed')
end

disp('END encrypt')
