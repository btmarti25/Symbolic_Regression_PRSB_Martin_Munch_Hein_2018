function nummatch = SR_cell_in_string(str,cellarr)
%loop over string array to see if any elements of array are in string
nomatch = zeros(length(cellarr),1);%initialize variable saying whether there is a match
for i = 1:length(cellarr)
   nomatch(i) = isempty(strfind(str,cellarr{i}));
end
nummatch = length(cellarr) - sum(nomatch);
