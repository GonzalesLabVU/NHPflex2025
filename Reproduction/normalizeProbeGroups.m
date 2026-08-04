function group = normalizeProbeGroups(raw)
s = lower(strtrim(string(raw)));
group = strings(size(s));
group(contains(s,'plexon')) = "Plexon";
group(contains(s,'dbc') | contains(s,'deep array')) = "DBC";
group(contains(s,'flex')) = "Flex";
group(contains(s,'neuropixel') | strcmp(s,'np')) = "Neuropixels";
end
