#! /bin/bash
function authi()
{
#checking whether userName is correct email or not
regex="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,4}$"
if [[ $1 =~ $regex ]] ; then 
    echo ""
else 
    return 1
fi
INPUT=auth.csv
OLDIFS=$IFS
IFS=','
    while read name1 password
    do
        if [ "$name1" == "$1" ];
        then 
        IFS=$OLDIFS
        return 1
        fi
    done < $INPUT
IFS=$OLDIFS
return 0
}
function show_history()
{
cat -e  ./history/$1
}
function add_history()
{
echo -e $1 $(date) >> ./history/$2
}
echo -e "\nWelcome to  GitCryptex\n1.LogIn \n2.SignIn \n3.Exit"
read auth
if [ $auth -eq 1 ];
then
echo -e "\n Now enter your email: "
read userName
echo -e "\n Now enter your password: "
read  password
INPUT=auth.csv
OLDIFS=$IFS
IFS=','
    while read -r -u 3 name1 password1
    do
        if [ "$name1" == "$userName" ] && [ "$password1" == "$password" ];
        then
        echo -e "\nLogin Sucesssfull"
        sleep 3
        echo -e "READY FOR TEST"
        ##############  write your code of questions & answers ##################
        exec 3<question.txt #adding file descriptor is beast way
        exec 4<answers.txt #adding file decriptor
        score=0
        while read -u3 LINE && read -r -u4 Opt
        #here 3,by exec command taking input from question.csv
        do
        clear
        echo -e $LINE
        for i in {10..00} ##timer
        do
        tput cup  6 0  
        echo -e "\e[1;31m$i \e[0m" ## colored output
        sleep 1
        done
        #here taking input from stdlin,here ifs=','
        #pstree -p
        read REPLY
        if [ "$REPLY" == "$Opt" ];
        then
        score=$((score + 1))
        echo $score
        echo "YOUR OPTION IS CORRECT "
        else
        echo "OPTION WRONG"
        add_history "$LINE Opt is correct answer" $userName
        fi
        sleep 2
        #pstree -p
        done
        echo "Your final score is $score"
        sleep 1
        clear
        add_history "Your final score is $score" $userName
        exec 3<&-
        exec 4<&-  #remove file decriptor 
        IFS=$OLDIFS
        echo -e "Your history is\n"
        show_history $userName
        exit 0
        fi
    done 3<"auth.csv"
    echo  "Invalid login"
IFS=$OLDIFS
elif [ $auth -eq 2 ];
then
echo -e "SignIn"
echo -e "Enter your email"
read userName
authi $userName
check=$? #Avoid spaces
echo $check
while [ $check -ne 0 ]
do
echo "Enter the vaild email"
read userName
authi $userName
check=$? #return output
done 
echo -e "\n Now generate your password"
read -s password #password is hidden
echo "$userName,$password" >> $INPUT #appending in files
touch "./history/$userName"
echo -e "SucessFully Created Account"
fi
