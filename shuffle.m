%{
%}
function [vect] = shuffle(vect)
	len = length(vect);
	for ii=1:len
		random1 = ii;
		random2 = randi(len);
		temp = vect(random1);
		vect(random1) = vect(random2);
		vect(random2) = temp;
	end
end
