%{
	reads a txt file and calculates the char frequency and 
	first order transition frequency
	PARAMETERS:
		book is the name of the file
		ascii is a vertical array of chars to be counted
	RETURNS:
		freq_alpha is a vertical array matching the frequenies of chars in ascii
		trans_ascii is a table of first order trans_ascii,
			size len_ascii x len_ascii,
			trans_ascii * previous = next
%}
function [freq_alpha trans_ascii] = read_a_book(book, ascii)

	% open book
	bookfile = fopen(book, 'r');

	len_ascii = length(ascii);
	freq_alpha = zeros(len_ascii,1);
	trans_ascii = zeros(len_ascii);

	% for retrieving chars one at a time
	onechar = '\0';

	% number of characters in book
	len_book = 0;

	% previous character index
	prev = 0;

	% fill out character frequency and trans_ascii
	while 1;
		onechar = fscanf(bookfile, '%c', 1);

		if feof(bookfile);
			break;
		end;

		% incrememt character frequency
		for ii=1:len_ascii;
			if ascii(ii) == onechar;
				% increment frequency
				freq_alpha(ii) = freq_alpha(ii) + 1;
			
				% if there's a previous character
				if prev ~= 0;
					trans_ascii(prev,ii) = trans_ascii(prev,ii) + 1;
				end;
				
				% current char becomes previous char
				prev = ii;

				% increment total number of chars
				len_book = len_book + 1;	
			end;
		end;
	end;
	
	% normalize
	%freq_alpha = freq_alpha / len_book;
	%for ii=1:size(trans_ascii,1)
	%	some = sum(trans_ascii(ii,:));
	%	if some ~= 0
	%		trans_ascii(ii,:) = trans_ascii(ii,:) / some;
	%	end
	%end
	
	% close the book
	fclose(bookfile);
end
