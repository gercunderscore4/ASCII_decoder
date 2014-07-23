%{
%}
function [alph trans] = swap(alph, trans, ii, jj)
		% swap alph
		temp = alph(ii);
		alph(ii) = alph(jj);
		alph(jj) = temp;

		% swap trans rows
		temp = trans(ii,:);
		trans(ii,:) = trans(jj,:);
		trans(jj,:) = temp;

		% swap trans cols
		temp = trans(:,ii);
		trans(:,ii) = trans(:,jj);
		trans(:,jj) = temp;
end
