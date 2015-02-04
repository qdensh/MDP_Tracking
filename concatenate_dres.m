function dres_new = concatenate_dres(dres1, dres2)

n = fieldnames(dres1);
for i = 1:length(n),
    f = n{i};
    dres_new.(f) = [dres1.(f); dres2.(f)];
end