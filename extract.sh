#!/bin/bash
#extracts mames from opt `filename` from grp filename

filename="$1"
while read -r line; do
    name="$line"
    grpfile="$2"
    out=$(echo $name | cut -f1 -d'_' )
    grep $name "$2" -A1 > $out
done < "$filename"

#one line
cat contig.list | while read line; do out=$(echo $line | cut -f1 -d'_'); grep $line trimmed.fasta -A1 > 18S/"$out".18s.fa; done
