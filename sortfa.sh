#!bin/bash
#use for sorting .fa files in to unique dir based on sample name - made to be run from dir containing all samples.
#Change `../refseq` to dir where you want samples stored

for i in *.fa;
        do name=$(echo ${i} | cut -f1 -d'_')
		sample=$(echo ${i})
		if [ ! -d ../refseq/"$name" ]; then
			mkdir ../refseq/"$name"
		fi
		cp -i "$sample" ../refseq/"$name"
		done
