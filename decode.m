%{
	FILE:		decode.m
	PROGRAM:	decode
	AUTHOR:		Geoffrey Card, Jordan Austin

	terms:
		the encoded message: textin
		the decoded message: textout
		the decoding cypher alph (encoded) -> ascii (decoded)
		English chars: ascii
		encoded chars: alph
		length of blank: len_blank
		frequencies of chars in blank: blank_freq
		first order transiton matrix: blank_trans (rows:prev, cols:next)
		
	features (comment out to disable):
		read English language frequency table instead of whole book (bool_book)
		analysis (bool_analysis) shows p value progress through iterations
		print results every tenth of the way to show progress (bool_print)
		output results to file (bool_file)
		meta (bool_meta) shows histogram of p values from multiple runs
		
	Used hints from Simulation and Solving Substitution Codes by Stephen Connor.
	Our implenetation is all our own (we never even got his code to work).
%}

clc
disp('BEGIN decode')

%format longE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%           files                %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = 'text/text00.txt';
book = 'books/war.txt';
tablename = 'table.txt';
outfile = 'outfile.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%    optional features           %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bool_book = false; % extract frequency table from book

bool_print = false; % show progressive solutions

bool_analysis = false; % show solution progress graph

bool_file = false; % print output to file

bool_meta = false; % run multiple simulation, show solution distribution

bool_mcmcmc = true; % choose best result

bool_guess = true; % initialize alph based on char frequency

switch_rand = 3;
% case 1: choose 1 char from code and 1 from alph, should help deal with large key size
% case 2: weighted by code and alph
% case 3: choose from code based on frequencies
% otherwise: choose chars randomly from alph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%    option exclusions           %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if bool_meta == true
	% speed up and don't print
	bool_analysis = false;
	bool_print = false;
	bool_file = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%         iterations             %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

samples = 1;

iterations = 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%         begin code             %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% file
if bool_file == true
	outf = fopen(outfile, 'w');
end


%ascii(1) = sprintf('%c',10); % newline
for ii=1:95
	ascii(ii) = sprintf('%c',ii+31);
end
len_ascii = length(ascii);


% read a book
if bool_book
	[freq_ascii trans_ascii] = read_a_book(book, ascii);
	write_table(tablename, freq_ascii, trans_ascii);
else
	[freq_ascii trans_ascii] = read_table(tablename, len_ascii);
end
% make sure the sizes match
if len_ascii ~= size(trans_ascii,1)
	disp('ERROR: transition table size incorrect');
	pause()
end
total_ascii = sum(freq_ascii);

% logarithmic tables
lowest = -12; % tweak me!

freq_ascii_log = log(freq_ascii) - log(sum(freq_ascii));
for ii=1:len_ascii
	if freq_ascii_log(ii) == -inf
		freq_ascii_log(ii) = lowest;
	end
end

trans_ascii_log = log(trans_ascii);
for ii=1:len_ascii
	some = sum(trans_ascii(ii,:));
	if some ~= 0
		trans_ascii_log(ii,:) = trans_ascii_log(ii,:) - log(some);
		for jj=1:len_ascii
			if trans_ascii_log(ii,jj) < lowest
				trans_ascii_log(ii,jj) = lowest;
			end
		end
	else
		trans_ascii_log(ii,:) = lowest * ones(1,len_ascii);
	end
end

% mcmcmc
if bool_mcmcmc == true
	p_mcmcmc = -inf;
end

% meta
if bool_meta == true
	sample_p = -inf * ones(1,samples);
else % bool_meta == false
	samples = 1;
end
for zz=1:samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%     initialize variables       %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% copy encoded message
	[freq_code trans_code textin] = read_encoded(filename, ascii);

	% creating initial cypher
	alph = ascii;
	if bool_guess == true
		[alph trans_code] = init_cypher(ascii, freq_ascii, freq_code, trans_ascii, trans_code);
	end

	% print
	if bool_print == true
		textout = write_decoded(textin, ascii, alph);
		disp(textout)
	end

	% keep track of the first char, necessary for p
	firstchar = find(alph == textin(1), 1, 'first');

	% p = Log[ prob(c_1) * product{transition(c_n,c_n+1)} ]
	% p = Log[ prob(c_1)] + #transitions(c_n,c_n+1) * Log[transition(c_n,c_n+1)]
	% logarithms simplify this equation a ton
	p_prev = freq_ascii_log(firstchar) + trans_code(:)'*trans_ascii_log(:);

	
	% analysis
	if bool_analysis == true
		icarus = zeros(1,iterations+1); % all p_prev's
		icarus(1) = p_prev;
		daedalus = icarus; % all accepted p_prev's
		crete = zeros(1,iterations+1); % all u's
	end

	
	% print at every 10%
	if bool_print == true
		printline = floor([0.1:0.1:1]*iterations);
		printcount = 1;
	end
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%        begin loop              %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% running algorithm
	count = 0;
	for ii=1:iterations
	
		% method of chosing chars to be swapped
		switch switch_rand
			case 1 % choose 1 char from code and 1 from alph
				theindex = randi(length(textin));
				random1 = find(alph == textin(theindex), 1, 'first');
				random2 = randi(len_ascii);
			
			case 2 % weighted by code and alph
				% pick two random numbers to swap
				% simple and ineffective
				random1 = randw(1:len_ascii, freq_code, 1);
				random2 = randw(1:len_ascii, freq_ascii, 1);
			
			case 3 % choose from code based on frequencies
				% select a character in the code
				theindex = randi(length(textin));
				if theindex == 1
					% if it's the first
					random1 = find(alph == textin(theindex), 1, 'first');
					% select other based on character probability
					% select based on transition probability of space
					random2 = randw(1:len_ascii, trans_ascii(1,:), 1); % space is first, unless \n
				else
					% not it's not the first
					random1 = find(alph == textin(theindex), 1, 'first');
					% choose based on transition probability
					char_prev = find(alph == textin(theindex-1), 1, 'first');
					random2 = randw(1:len_ascii, trans_ascii(char_prev,:), 1);
				end
				
			otherwise % choose chars randomly from alph
				random1 = randi(len_ascii);
				random2 = randi(len_ascii);
				
		end
	
		
		
		% maintain lock on firstchar
		firstchar_new = firstchar;
		if random1 == firstchar
			firstchar_new = random2;
		elseif random2 == firstchar
			firstchar_new == random1;
		end

		% swap characters
		[alph_new trans_code_new] = swap(alph, trans_code, random1, random2);

		% calculate probability of this move
		p_next = freq_ascii_log(firstchar_new) + trans_code_new(:)'*trans_ascii_log(:);
		
		% calculate ratio
		ratio = p_next - p_prev;
		
		% random value
		u = log(rand()); % tweak me!
		
		if ratio >= u
			% accept
			alph = alph_new;
			trans_code = trans_code_new;
			p_prev = p_next;
			firstchar = firstchar_new;
			count = count + 1;
		else
			% do not accept
			%alph = alph
			%trans_code = trans_code;
			%p_prev = p_prev;
			%firstchar = firstchar;
		end
		
		% print
		if bool_print == true
			if ii == printline(printcount)
				textout = write_decoded(textin, ascii, alph);
				disp(textout)
				printcount = printcount + 1;
			end
		end

		% mcmcmc
		if bool_mcmcmc == true 
			if p_prev >= p_mcmcmc
				p_mcmcmc = p_prev;
				mcmcmc = alph;
			end
		end
		
		% analysis
		if bool_analysis == true
			icarus(ii+1) = p_next;
			daedalus(ii+1) = p_prev;
			crete(ii+1) = u;
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%          end loop              %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% meta
	% mcmcmc
	if bool_mcmcmc == true
		% copy the best match
		sample_p(zz) = p_mcmcmc;
		% reset mcmcmc for the next round
		p_mcmcmc = -inf;
		% if the latest is the best, record its key
		[garbage theindex] = max(sample_p);
		if theindex == zz
			sample_mcmcmc = mcmcmc;
		end
	else
		sample_p(zz) = p_prev;
	end
end

% meta
if bool_meta == true
	hist(sample_p, samples/10)
	
	% mcmcmc
	if bool_mcmcmc == true
		alph = sample_mcmcmc;
		[garbage theindex] = max(sample_p);
		p_prev = sample_p(theindex);

		% decode and display
		textout = write_decoded(textin, ascii, alph);
		disp(textout)
		disp(sprintf('\n%i changes in %i iterations, p = %i\n', count, iterations, p_prev))
	end

else

	% mcmcmc
	if bool_mcmcmc == true
		alph = mcmcmc;
		p_prev = p_mcmcmc;
	end

	% decode and display
	textout = write_decoded(textin, ascii, alph);
	disp(textout)
	disp(sprintf('\n%i changes in %i iterations, p = %i\n', count, iterations, p_prev))

	% analysis
	if bool_analysis == true
		plot(icarus , 'Color', [0 1 0])
		hold('on')
		plot(daedalus, 'Color', [0 0.5 0])
		plot(zeros(1,iterations), 'Color', [0.7 0 0])
		plot(icarus(2:iterations+1) / icarus(1:iterations) - crete(2:iterations+1), 'k')
		hold('off')
	end
	
	% file
	if bool_file == true
		fprintf(outf, 'alph -> ascii\n');
		fprintf(outf, '%s\n', alph);
		fprintf(outf, '%s\n', ascii);
		fprintf(outf, '\ntextin -> textout\n');
		fprintf(outf, '%s\n', textin);
		fprintf(outf, '%s\n', textout);
		fprintf(outf, '\n%i changes in %i iterations, p = %i\n', count, iterations, p_prev);
		fclose(outf);
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%           end code             %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('END decode')
