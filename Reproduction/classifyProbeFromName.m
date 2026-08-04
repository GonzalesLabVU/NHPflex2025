function group = classifyProbeFromName(name)
s = lower(string(name));
group = "";
if startsWith(s,'plexon_') || contains(s,'_plexon_')
    group = "Plexon";
elseif startsWith(s,'dbc_') || contains(s,'_dbc_')
    group = "DBC";
elseif startsWith(s,'flex_') || contains(s,'_flex_')
    group = "Flex";
elseif contains(s,'neuropixel') || contains(s,'np_')
    group = "Neuropixels";
end
end
