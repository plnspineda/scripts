#!/bin/sh

#got it from https://unix.stackexchange.com/questions/31414/how-can-i-pass-a-command-line-argument-into-a-shell-script
helpFunction()
{
 echo ""
 echo "This is a script to take random subsamples from fastq files using seqtk (https://github.com/lh3/seqtk)"
 echo ""
 echo "Sample usage: $0 -x 2 -s 100 -d folder"
 echo ""
 echo -e "\t-x Number of coverage"
 echo -e "\t-s Number of random subsamples to be generated"
 echo -e "\t-d Input directory where fastq files are. Note: remove any / to the directory. This code can't really take path file, just folder name."
 echo ""
 exit 1 # Exit script after printing help
}

while getopts "x:s:d:" opt
do
case "$opt" in
  x ) coverage="$OPTARG";; #input -x
  s ) seeds="$OPTARG";; #input -s
  d ) dir="$OPTARG";; #will take the input folder as basename for dir
  #dir ) dir="$(basename "$1")";; #input directory
  ? ) helpFunction ;;
esac
done

subreads=$((27000000*$coverage)) #compute for how much subreads are needed for x coverage (2.7Gb / 100bp per read)

echo "Number of subreads: $subreads. Number of random samples to be generated: $seeds. Sub-sampling will take a while..."

ls $dir > "$dir"_fq.list ## will list the files/folder in the directory
subrandom=$(($seeds*100)) ## just to make the the seeds an increment of 100
for i in $(cat "$dir"_fq.list)
do
  for ((a=100; a<=$subrandom; a+=100))
  do
   seqtk sample -s_$a $dir/$i $subreads > $dir/sub"$a"_"${i%.*}"
  done
done

echo "Finished."
