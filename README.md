# Single Read Archive Sequence Downloader
A small bash script that automates the process of downloading, extracting and compressing sequence files from NCBI's Single Read Archive.

All you need is SRA-tools installed (I recommend a to use a conda environment for this) and a .csv file with the sequence ID and the species name separated by a comma.

## 1. Set up a conda-environment
Before you create a new conda-environment, you should set the necessary channels. This is a one-time thing to do as is explained on the Bioconda [homepage](https://bioconda.github.io/) or search for `set-up-channels bioconda`
```
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```
After the channels are set you can (1) create a new conda-environment for SRA-tools, (2) activate the environment so you can use SRA-tool and (3) install the SRA-tool kit. Please consult the respective [homepage](https://bioconda.github.io/recipes/sra-tools/README.html) on bioconda to make sure the here proposed process will still work.
```
conda create -n sra-tools
conda activate sra-tools
conda install sra-tools
conda update sra-tools
```

### 1b. Install `pigz` to parallel the compression step
In the second last step the fastq files are compiled into the .gz format. This is usually done with the program gunzip or `gzip`. The disadvantage is that this program uses only one core for compression and thus takes a long time with the usually very large sequence data, especially if you want to download and process a lot of files in one go. The program `pigz` ([Parallel Implementation of GZip](https://github.com/madler/pigz)) is basically gzip on steroids, since it can utilize all processor cores/threads.
You can easily install pigz on Ubuntu/Debian with `sudo apt install pigz`. Because it is also practical in other situations, I don't think it needs to be installed in the Conda environment, but better locally.

## 2. Git clone this repository
To get the shell script, the easiest way is to `git clone` this repository and make it part of your path or simply set an `alias` in your `.bashrc`.

```
git clone https://github.com/TimBoeh/SRA_seq_downloader.git
```

In your `.bashrc` add the following line, just make sure you replace the placeholder that specifies the path:
```
alias sra_downloader='/home/USER/PATH/TO/SRA_seq_downloader/SRA_seq_downloader.sh'
```
Afterwards you might want to restart your terminal or reload the .bashrc file with `source .bashrc`.

## 3. prepare a .csv file
The script expects as input a simple .csv file with the SRA ID followed by the species name or what ever you to have as additional name separated by a comma: 
```
sequence_ID_1,species_name_1
sequence_ID_2,species_name_2
sequence_ID_3,species_name_3
...
```
**Make sure there are no spaces in the sample names, as this will most likely cause problems downstream.**

## 4. Function of the script
The script basically pipes four steps that are executed in sequence:
1. The `prefetch` function is used to download the sequence data in SRA format. The file is stored in a subfolder named after the sequence ID.
2. `fastq-dump` is used to extract the files from the .SRA file and stores it in .fastq format. The `--split-files` flag is used to ensure that you get forward and reverse reads.
3. The two resulting .fastq files for each sequence ID, which looks like this: `sequence_ID_1.fastq` & `sequence_ID_2.fastq` are renamed by adding the species name taken from the .csv file.
4. Once all the files have been downloaded, extracted and renamed, `pigz` is used to gunzip all the .fastq files in the directory.
5. Finally, all subfolder with the original SRA files are removed and you are left with compressed and perfectly named sequence file that can be used for downstream analyses.

## 5. Some final thoughts
- The script will only work if the conda environment is enabled.
- The script should be run in an empty folder, except for the .csv file. Be aware that all folders will be deleted ... **ALL** folders!!
- Use the script with caution and only if you know what you are doing. I have written the script for my specific use cases. Yours may be different.
- Use the script at your own risk!



