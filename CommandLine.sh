#!/bin/bash

#command useful in order to format the output
paint=$(tput rev)
no_paint=$(tput sgr 0)
blue=$(tput setaf 4)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)


#printing formatted title and introduction
echo -e "\n"
echo "$paint$red                      COMMAND LINE QUESTION HW4 AMDM GROUP 21                         $no_paint"
echo "$paint$red  $no_paint                                                                                  $paint$red  $no_paint"
echo "$paint$red  $no_paint This bash script answers to the three questions from CLQ                         $paint$red  $no_paint"
echo "$paint$red  $no_paint                                                                                  $paint$red  $no_paint"
echo "$paint$red                                                                                      $no_paint"
echo -e "\n"
echo "Please make yourself comfortable, the code is going to run for a while: the machine is calculating untill you see the result on standard output."
echo "For a clearly visualization of the output it's recommended to maximize the terminal window."
echo "While the code is running a status bar will appear for each question: when you see ten times the symbol '#' the calculation for the specific question is complete."
echo -e "\n"

#-------------------------------------------


##############################
#                            #
# Most-watched Netflix title #--------------
#                            #
##############################

max_1=0
max_title=' '
i=1

#extracting the column 'title' from data, sorting with no duplicate
mlr --csv cut -o -f title vodclickstream_uk_movies_03.csv | sed 1d | sort -u > title.csv

#extracting the column 'title'
mlr --csv cut -o -f title vodclickstream_uk_movies_03.csv | sed 1d | sort > title_col.csv

#this command says to the for loop to consider the entire line as a variable 
IFS=$'\n'

#inizialization of the status bar
echo -n 'Progress Q1: '

#for loop along all the titles
for title in $(cat 'title.csv')
do
    #l contains the occurrence of the title
    l=$(grep -i -F -c -x $title title_col.csv)
    
    #if statement in order to compare and extract the max
    if [ $l -ge $max_1 ]
    then
	max_1=$l
	max_title=$title
    fi

    #status bar update
    m=$((i%790))
    if [ $m == 0 ]
    then
	echo -n '#'
    fi
    
    i=$((i+1))

done

echo -e '\n'


################
#              #
# Average time #--------------
#              #
################

average=0
p=0
i=1

#extracting the column 'duration'
mlr --csv cut -o -f duration vodclickstream_uk_movies_03.csv | sed 1d | sort > duration_col.csv

#remove 0.0 and -1.0 duration, in this way we consider the average of the actual views
grep -i -v '\<0\.0\>' duration_col.csv | grep -i -v '\-1\.0' > dur_grep.csv

IFS=$'\n'

echo -n 'Progress Q2: '

#for loop along the duration column
for duration in $(cat 'dur_grep.csv')
do
    #sum
    average=$(echo "scale=3;$average+$duration" | bc)

    #counter for the final division
    p=$((p+1))
    
    #status bar
    m=$((i%35038))
    if [ $m == 0 ]
    then
	echo -n '#'
    fi
    
    i=$((i+1))
done

#actual average
average=$(echo "scale=3;$average/$p" | bc)

echo -e '\n'


################
#              #
# Most user    #--------------
#              #
################

max_2=0.0
max_user=' '
i=1

#extracting the duration and user_id column
mlr --csv cut -o -f duration,user_id vodclickstream_uk_movies_03.csv > user_dur.csv

#extracting only the user_id column
mlr --csv cut -o -f user_id vodclickstream_uk_movies_03.csv | sed 1d | sort -u > user.csv

echo -n 'Progress Q3: '

#for loop along all the users
for user in $(cat 'user.csv')
do
    #insert the headers 
    head -n1 user_dur.csv > user_grep.csv

    #appending only the lines of the current user
    grep $user user_dur.csv >> user_grep.csv

    #removing the 0.0 and -1.0 values
    grep -i -v '\<0\.0\>' user_grep.csv | grep -i -v '\-1\.0' > user_grep_2.csv

    #extracting only the duration column for the current user without the header
    mlr --csv cut -o -f duration user_grep_2.csv | sed 1d > file_1.csv

    #inizialization of the variable that will contain the total duration for the user
    t=0.0

    #for loop along all the duration for the current user
    for dur in $(cat 'file_1.csv')
    do
	#sum
	t=$(echo "scale=3;$t+$dur" | bc)
    done

    #if statement in order to compare and extract the max
    if [ $(echo "$t>$max_2" | bc -l) -eq 1 ]
    then
	max_2=$t
        max_user=$user
    fi

    #status bar
    m=$((i%16190))
    if [ $m == 0 ]
    then
	echo -n '#'
    fi
    
    i=$((i+1))

done

echo -e '\n'

#----------------------------------------

#removing the temporary files used for the analysis 
rm title.csv
rm title_col.csv
rm duration_col.csv
rm dur_grep.csv
rm user_dur.csv
rm user.csv
rm user_grep.csv
rm user_grep_2.csv
rm file_1.csv


#printing formatted output question 1
echo "$paint$blue    QUESTION 1: WHAT IS THE MOST-WATCHED NETFLIX TITLE?                               $no_paint"
echo "$paint$blue  $no_paint                                                                                  $paint$blue  $no_paint"
echo "$paint$blue  $no_paint The most-watched netflix title is:                                               $paint$blue  $no_paint"
echo "$paint$blue  $no_paint "$max_title" with "$max_1" clicks                                      $paint$blue  $no_paint"
echo "$paint$blue  $no_paint                                                                                  $paint$blue  $no_paint"
echo "$paint$blue                                                                                      $no_paint"

#question 2
echo "$paint$green    QUESTION 2: REPORT THE AVERAGE TIME BETWEEN SUBSEQUENT CLICKS ON NETFLIX.COM      $no_paint"
echo "$paint$green  $no_paint                                                                                  $paint$green  $no_paint"
echo "$paint$green  $no_paint The average time between subsequent clicks on Netflix.com is:                    $paint$green  $no_paint"
echo "$paint$green  $no_paint "$average" s, hence about 18 hours                                                $paint$green  $no_paint"
echo "$paint$green  $no_paint                                                                                  $paint$green  $no_paint"
echo "$paint$green                                                                                      $no_paint"

#question 3
echo "$paint$yellow    QUESTION 3: PROVIDE THE ID OF THE USER THAT HAS SPENT THE MOST TIME ON NETFLIX    $no_paint"
echo "$paint$yellow  $no_paint                                                                                  $paint$yellow  $no_paint"
echo "$paint$yellow  $no_paint The user that has spent the most time on netflix is:                             $paint$yellow  $no_paint"
echo "$paint$yellow  $no_paint "$max_user" with "$max_2" seconds, hence about 245 days                         $paint$yellow  $no_paint"
echo "$paint$yellow  $no_paint                                                                                  $paint$yellow  $no_paint"
echo "$paint$yellow                                                                                      $no_paint"

echo -e "\n"

