#! /bin/bash
source $1

#config
bin_path=$(cd `dirname $0`; pwd)
juicer_dir=${bin_path}/../juicer/
dna_dir=${bin_path}/../3ddna/
outdir=`pwd`
new_ref="${outdir}/juicer/reference/${name}.fasta"

#dryrun
mkdir shell
cd shell
#pre_juicer.sh
echo "source activate 3ddna" >pre_juicer.sh
echo "mkdir ${outdir}/juicer;cd ${outdir}/juicer" >>pre_juicer.sh
echo "ln -s ${fastq_dir} ./fastq" >>pre_juicer.sh
echo "ln -s ${juicer_dir}CPU/scripts scripts" >>pre_juicer.sh
echo "mkdir restriction_sites;cd restriction_sites" >>pre_juicer.sh
echo "python ${juicer_dir}misc/generate_site_positions.py ${enzyme} ${name} ${ref}" >>pre_juicer.sh
echo "awk 'BEGIN{OFS="\t"}{print \$1, \$NF}' ${name}_${enzyme}.txt > ${name}.chrom.sizes" >>pre_juicer.sh
echo "cd ${outdir}/juicer;mkdir reference;cd reference;ln -s ${ref} ${name}.fasta" >>pre_juicer.sh
echo "bwa index ${new_ref}" >>pre_juicer.sh

#juicer.sh
echo "source activate 3ddna;cd ${outdir}/juicer" >run_juicer.sh
echo "sh ./scripts/juicer.sh \
 -d ${outdir}/juicer \
 -s ${enzyme} \
 -S early \
 -p restriction_sites/${name}.chrom.sizes \
 -y restriction_sites/${name}_${enzyme}.txt\
 -z reference/${name}.fasta \
 -D ${outdir}/juicer \
 -t $p"  >>run_juicer.sh

 #3ddna
 echo "source activate 3ddna;cd ${outdir}; mkdir 3ddna;cd 3ddna" >run_3ddna.sh
 echo "${dna_dir}run-asm-pipeline.sh ${new_ref} ${outdir}/juicer/aligned/merged_nodups.txt" >>run_3ddna.sh

 #run
 if [ ! $dryrun == 1 ];then
 	echo "pre_juicer submit"
 	python ${bin_path}/sgearray.py -l vf=${vf},p=1 ${opts} -c `cat pre_juicer.sh|wc -l` pre_juicer.sh
 	echo "run_juicer submit"
 	python ${bin_path}/sgearray.py -l vf=${vf},p=${p} ${opts} -c `cat run_juicer.sh|wc -l` run_juicer.sh
 	echo "run_3ddna submit"
 	python ${bin_path}/sgearray.py -l vf=${vf},p=${p} ${opts} -c `cat run_3ddna.sh|wc -l` run_3ddna.sh
 fi


