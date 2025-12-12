#!/bin/bash
# Find duplicate scripts
find ~/AmsyPycharm/BAZINGA/scripts ~/AmsyPycharm/BAZINGA/bin -type f -name "*.sh" | sort > /tmp/all_scripts.txt
cat /tmp/all_scripts.txt | xargs md5 | sort | awk '{print $1}' | uniq -d > /tmp/duplicate_hashes.txt

if [ -s /tmp/duplicate_hashes.txt ]; then
  echo "Potential duplicate scripts found:"
  for hash in $(cat /tmp/duplicate_hashes.txt); do
    echo "Duplicate group with hash $hash:"
    cat /tmp/all_scripts.txt | xargs md5 | grep $hash | awk '{print $4}'
    echo ""
  done
else
  echo "No duplicate scripts found."
fi

# Find broken symlinks
echo -e "\n==== Finding Broken Symlinks ===="
find ~/AmsyPycharm/BAZINGA -type l -exec test ! -e {} \; -print
