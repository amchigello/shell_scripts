I think that I shall never see
A poem lovely as a tree,A tree whose hungry mouth is prest
Against the earth’s sweet flowing breast
A tree that looks at God all day
And lifts her leafy arms to pray,A tree that may in Summer wear
A nest of robins in her hair


I think that I shall never see
A poem lovely as a tree,A tree whose hungry mouth is prest
Against the earth’s sweet flowing breast
A plant that looks at God all day
And lifts her leafy arms to pray,A tree that may in Summer wear
A nest of robins in her hair



sed 's/tree/plant/g' poem.txt #Replacing words
sed 's/tree/plant/' poem.txt #Replacing words
sed 's/tree/plant/2g' poem.txt #Replacing Second occurence
sed '4 s/tree/plant/' poem.txt #Replacing string on a specific line number
sed '2,4 s/tree/plant/' poem.txt #Replacing string on a range of lines 

sed '5d' poem.txt #Deleting lines from a particular file 
sed '$d' poem.txt #Deleting last line from a particular file 
sed '3,$d' poem.txt #Deleting 3rd to last line
sed '/tree/d' poem.txt #Deleting lines with matching pattern from a particular file 
sed '1d;$d' poem.txt #Deleting header and footer (first and last line)


head -n -2 myfile.txt # remove the last n lines of a file
sed '1,42d' test.sql  # remove the first n lines of a file
