#!/bin/bash

#if no args specified index src files from current dir, create cscope.files and cross ref in current dir
#if launched with -h print help message
#-k , we are indexing linux kernel src else we are indexing usr src
#-u , cscope option. Unconditionally build the cross-reference file (assume that all files have changed). 

show_help() {
cat << EOF
Usage: ${0##*/} [-hukv] [-d SRC_DIR]
Looks for {c,cpp,h,hpp,java,cc} src file to build cross ref used by cscope.
If no aruments are specified CWD is searched for src files. Cross ref is always
created in the src dir.

    -h          display this help and exit
    -k          perpare cscope index for kernel source code (not implemented)
    -d SRC_DIR  source directory to look for source code files
    -u   	Build fresh crossref. 
    -v          verbose mode.
             
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.


# Initialize our own variables:
src_dir=$PWD
cscope_opts=""
verbose=0
kernel=0
un_conditional=0

while getopts "h?vud:" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    v)  verbose=1
      ;;
    u)  un_conditional=1
      ;;
    k)  kernel=1
      ;;
    d)  src_dir=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "un_conditional=$un_conditional, verbose=$verbose, src_dir='$src_dir', Leftovers: $@"
if [ $un_conditional == 1 ]
	then
		cscope_opts="-ubqv"
	else
		cscope_opts="-bqv"
fi

declare -a arr=("c" "cpp" "h" "hpp" "java" "cc") 
echo "Removing previous cscope.files from $src_dir"
rm $src_dir/cscope.files

echo "Looking for source files in $src_dir"
for i in "${arr[@]}"
do
   #echo "$i $MYDIR"
   CMD="find ${src_dir} -name '*.${i}' -print >> ${src_dir}/cscope.files"
   #echo "$CMD"
   eval $CMD
   if [ $? -ne 0 ]
	then
		echo "Error"
   	exit 1
   fi
   # or do whatever with individual element of the array
done
CMD="cscope ${cscope_opts} -i ${src_dir}/cscope.files -f${src_dir}/cscope.out"
echo "$CMD"
echo "cscope opts $cscope_opts"
eval $CMD
exit 0
