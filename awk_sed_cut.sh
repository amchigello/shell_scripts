########################awk##################
#Awk is a scripting language used for manipulating data and generating reports
date "+%d/%m/%Y" -d "09/99/2013" > /dev/null  2>&1
 is_valid=$?
 
cat>employee.csv
111|Sophia|23/09/1996|2166|Eu Dui Cum Corp.
222|Ora|21/05/1992|6448|Senectus Et Netus Incorporated
333|Judith|31/12/1995|8992|Sem Ut Industries
444|Paloma|20/06/1995|7857|Eget Nisi Ltd
555|Barbara|30/12/1993|4793|Urna Company
666|Hope|14/06/1995|9021|Neque Institute
777|Rae|02/04/1994|4120|Senectus Et Netus LLC
888|Bertha|06/08/1997|7007|Nullam Consulting
999|Nadine|10/08/1990|6643|Elit Inc.
000|Britanney|12/06/1997|3107|Nascetur Ridiculus Incorporated

###NR: NR command keeps a current count of the number of input records. 
###Remember that records are usually lines. 
###Awk command performs the pattern/action statements once for each record in a file.

awk '{print NR,$0}' employee.csv  #Print Line Numbers
awk 'NR==3,NR==6{print NR,$0}' employee.csv  #Print 3-6 Line

###NF: NF command keeps a count of the number of fields within the current input record.

awk 'BEGIN{FS="|";} {print $1,$NF}' employee.csv  #Print first and last field
awk -F'|' '{print $1,$5}' employee.csv  #Print first and last field

###FS: FS command contains the field separator character which is used to divide fields on the input line. 
###The default is “white space”, meaning space and tab characters. 
###FS can be reassigned to another character (typically in BEGIN) to change the field separator.

awk 'BEGIN{FS="|";} {print $1,$NF}' employee.csv 

###RS: RS command stores the current record separator character. 
###Since, by default, an input line is the input record, the default record separator character is a newline. 

###OFS: OFS command stores the output field separator, which separates the fields when Awk prints them. 
###The default is a blank space. Whenever print has several parameters separated with commas, 
###it will print the value of OFS in between each parameter.

###ORS: ORS command stores the output record separator, which separates the output lines when Awk prints them. 
###The default is a newline character. 
###print automatically outputs the contents of ORS at the end of whatever it is given to print.


awk -F'|' '{print $2":"$1}' employee.csv


#####################################################################
###########grep
#  grep [options] pattern [files]
#  Options Description
#  -c : This prints only a count of the lines that match a pattern
#  -h : Display the matched lines, but do not display the filenames.
#  -i : Ignores, case for matching
#  -l : Displays list of a filenames only.
#  -n : Display the matched lines and their line numbers.
#  -v : This prints out all the lines that do not matches the pattern
#  -e exp : Specifies expression with this option. Can use multiple times.
#  -f file : Takes patterns from file, one per line.
#  -E : Treats pattern as an extended regular expression (ERE)
#  -w : Match whole word
#  -o : Print only the matched parts of a matching line,
#   with each such part on a separate output line.

grep -i "et" employee.csv
grep -c "et" employee.csv
grep -w "Incorporated" employee.csv
grep -o "Incorporated" employee.csv
grep -n "et" employee.csv
grep -v "et" employee.csv
grep -i -e "corp" -e "comp" employee.csv
grep -E  -o "[0-9]{2}/{1}[0-9]{2}/{1}[0-9]{4}" employee.csv

