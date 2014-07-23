%{
%}
function [textout] = write_decoded(textin, ascii, alph)
	textout = textin;
	for ii=1:length(textin)
		% find alph index
		jj = find(alph == textin(ii), 1, 'first');
		% print ascii equivalent
		if length(jj) == 1
			textout(ii) = ascii(jj);
		else
			disp('wtf')
		end
	end
end
