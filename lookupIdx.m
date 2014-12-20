function result = lookupIdx(idx)
    smallChars = 'abcdefghijklmnopqrstuvwxyz';
    bigChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    if (idx <= 10)
        result = idx - 1;
    elseif (idx > 10 && idx <= 36)
        result = bigChars(idx - 10);
    elseif (idx > 36 && idx <= 62)
        result = smallChars(idx - 36);
    end
end