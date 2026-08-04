function group = normalizeFig3HGroup(sourceGroup,probeLabel)
s = lower(strtrim(string(sourceGroup) + " " + string(probeLabel)));
group = "";
if contains(s,'checker')
    group = "Checkerboard";
elseif contains(s,'linear')
    group = "Linear";
elseif contains(s,'plexon')
    group = "Plexon";
elseif contains(s,'dbc') || contains(s,'deep array') || contains(s,'diagnostic bio')
    group = "DBC";
end
end
