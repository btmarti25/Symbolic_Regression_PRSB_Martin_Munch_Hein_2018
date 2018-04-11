function pairs = SR_get_unique_par_pairs(parvec)
%get unique pairs using parameter set and +,-,*,/ operators
operatorvec = {'+','-','*','/'};
[p, q, g] = meshgrid(parvec,operatorvec,parvec);
pairs = cellstr(cell2mat(([p(:), q(:), g(:)])));
pairs = strrep(pairs, ' ','');%drop spaces from strings
