#!/bin/sh
# Which sides of the repo a change touches, for .github/workflows/test.yml.
#   .github/ci_sides.sh BASE HEAD      prints rytm=true|false and a4=true|false, one a line
# a4/ is the A4's; .github/ is both sides'; anything else is the Rytm's. When the two commits cannot be compared (a new
# branch, a shallow history) or the diff is empty, both sides run: a guess must never skip a test.
base=$1 head=$2
paths=$(git diff --name-only "$base...$head" 2>/dev/null) || paths=
if [ -z "$paths" ]; then
  echo rytm=true
  echo a4=true
  exit 0
fi
rytm=false a4=false
for p in $paths; do
  case $p in
    a4/*) a4=true ;;
    .github/*) rytm=true a4=true ;;
    *) rytm=true ;;
  esac
done
echo rytm=$rytm
echo a4=$a4
