#!/bin/bash

## Function to download SRA files using prefetch
download_sra() {
	entry=$1
	prefetch $entry
}

## Function to extract SRA files into fastq using fastq-dump
extract_fastq() {
	entry=$1
	fastq-dump $entry --split-files
}

## Function to gunzip files in parallel using pigz
gunzip_files() {
	file=$1
	pigz $file
}

## Function to rename fastq files using species name
rename_fastq() {
    sequence_id=$1
    species_name=$2

    for fastq_file in "${sequence_id}"*.fastq; do
        new_name="${species_name}_${fastq_file}"
        mv "$fastq_file" "$new_name"
    done
}

## Function to display script usage
show_help() {
    echo "    Usage: $0 <input_file>"
    echo "    Download SRA sequences from the input file, extract them into fastq,"
    echo "        and compress using pigz."
    echo "    The input_file should contain a list of SRA sequence IDs and"
    echo "        species names in CSV format (sequence_id,species_name)."
}

## Check if the script is called with the --help option or without any arguments
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    "")
        echo "Error: No input file provided."
        show_help
        exit 1
        ;;
    *)
        ## Check if the input file exists
        if [ ! -f "$1" ]; then
            echo "Error: The input file '$1' does not exist in current directory."
            show_help
            exit 1
        fi

        ## Check if the input file is empty
        if [ ! -s "$1" ]; then
            echo "Error: The input file '$1' is empty."
            show_help
            exit 1
        fi

        input_file=$1

        printf "\n"
        echo "This script will download SRA sequences specified in the $input_file file,"
        echo "extract them into fastq format, rename them and then use pigz to compress"
        echo "the resulting fastq files."
        printf "\n"
        echo "-----------------------------"
        echo "Start downloading SRA files"
        
        ## Read the list of entries and species names from the input file (CSV format: sequence_id,species_name)
        while IFS=',' read -r sequence_id species_name; do
            printf "\n"
            echo "Start downloading SRA sequences of $species_name ($sequence_id)"
            download_sra "$sequence_id"
            extract_fastq "$sequence_id"
            rename_fastq "$sequence_id" "$species_name"
            printf "\n"
            echo "$sequence_id downloaded, extracted and $species_name added to file name."
            echo "-----------------------------"
        done < "$input_file"

        printf "\n"
        echo "Done extracting and renaming fastq files"
        printf "\n"
        echo "-----------------------------"
        printf "\n"
        echo "Start gunzipping"

        ## Gunzip files in parallel
        fastq_files=$(ls *.fastq)
        for file in $fastq_files; do
            gunzip_files "$file" &
        done

        ## Wait for all parallel processes to finish
        wait

        printf "\n"
        echo "All files downloaded, extracted, and gunzipped."
        printf "\n"
        echo "-----------------------------"
        echo "Now, let's clean up and remove the download folders that are no longer needed"
        rm -rf ./*/
	printf "\n"
	echo "DONE!"
        exit 0
        ;;
esac

