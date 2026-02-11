function x = TalkerTypeDifferent(Code1, Code2)
% return 1 if the talker type is idfferent in the two codes
if (strcmp(Code1.talkerType,Code2.talkerType) ) x=0;
else
    x=1;
end
