%{
%}
function [freq_code trans_code textin] = read_encoded(filename, ascii)

	len_ascii = length(ascii);

	% open message file
	bookfile = fopen(filename, 'r');

	% initialize code
	len_code = len_ascii;
	code = zeros(1,len_code);
	freq_code = zeros(1,len_code);
	trans_code = zeros(len_ascii,len_code);

	% initialize textin
	textin = ' ';
	len_textin = 0;

	% for retrieving chars one at a time
	onechar = '\0';
	
	% previous character index
	prev = 0;

	% find chars and check their frequency
	while 1;
		onechar = fscanf(bookfile, '%c', 1);

		if feof(bookfile);
			break;
		end;

		% incrememt character frequency
		ii = find(onechar == ascii, 1, 'first');
        if ii;
            % increment frequency
            freq_code(ii) = freq_code(ii) + 1;
        
            % if there's a previous character
            if prev ~= 0;
                trans_code(prev,ii) = trans_code(prev,ii) + 1;
            end;
            
            % current char becomes previous char
            prev = ii;

            % increment total number of chars
            len_textin = len_textin + 1;	

            % record
            textin(len_textin) = onechar;
        end;
	end;

	% normalize
	%freq_code = freq_code / len_textin;
	%trans_code = trans_code / len_textin; % no normanlized in current code
	
	% close message file
	fclose(bookfile);
end
