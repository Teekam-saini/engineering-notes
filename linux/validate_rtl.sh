file=$1
module=$(grep -i -c "module" $file)

if [[ -s "$file" && -r "$file" ]] && [[ $module -gt 0 ]]; then
echo " pass "
else
echo "fail"
fi
