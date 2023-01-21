for dir in compressed_discover_logfiles/*/
do
  echo $dir
  read -p 'stime=' stime
  echo start removing
  cd ${dir}
  rm *_*_*_${stime}_*_*
  rm *_*_*_${stime}_{0..499}
  echo finish removing
  pwd
  ls
done
