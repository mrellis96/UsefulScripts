#!/usr/bin/awk -f

BEGIN {
    location = "NA";  # Default location value
}

/^ACCESSION/ {
    acc = $2;         # Capture the accession number
    location = "NA";  # Reset location for each accession
}

/^ {5}source/,/^ {5}\S/ {
    # Look for /country= or /geo_loc_name= qualifiers
    if ($0 ~ /\/country=/) {
        location = substr($0, index($0, "/country=") + 9);  # Start extracting after '/country='
        gsub(/^"|"$/, "", location);                       # Remove surrounding quotes
    } else if ($0 ~ /\/geo_loc_name=/) {
        location = substr($0, index($0, "/geo_loc_name=") + 14);  # Start after '/geo_loc_name='
        gsub(/^"|"$/, "", location);                              # Remove surrounding quotes
    }
}

# When a new accession or end of the block is reached, print the data
/^ACCESSION/ || /^ {0,4}\/\// {
    if (acc != "") {
        print acc, location;  # Print accession and location
    }
}

#run as awk -f extract_locs.sh sequence.gb >locations.txt
