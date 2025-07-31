#!/bin/bash
#######################Help Function #################
show_help()
{
cat <<'EOF'
===================Stream ID =============== 1#StreamID ========================================
#           To find 35=A or 35=0 Message ###### Feed Number ex: 1#Streamid                     #
#           FCGEMB Stream config #### Feed number ex: 2#streamname                             #
===================Stream Config ========= 2#streamname=========================================
EOF

case $# in
0) echo -n -e " Hello $USER, Choose an option (1#sendercompid|2#sendercompid-config|3#DATE): \n "
   read option ;;

1) option=$1 ;;

*) echo "Too many Inputs"
   exit 2 ;;
esac

}

show_help

###############################################Variable#######################
var11=$(echo $option|cut -d '#' -f 1);
#echo -e "Entered Value to seach is $var11 \n"; 
var12=$(echo $option|cut -d '#' -f 2);
#echo -e "Entered Value to seach is $var12 \n"; 

##############################################################################
echo <<EOF
if [ "$var11" = 1 ]; then
echo -e "Entered number was one \n"
else
echo -e "Entered number was two \n"
fi
EOF

#################################################################################
login_message()
{
con=$1;

echo -e "Checking following hosts for connection with String $con \n";

for i in 01 02 03 04
do
USERNAME="fxall";
HOSTNAME="nyintaggfix$i";
echo -e "==================================== ================================================= \n" ;
echo -e "Checking on this Server  nyintaggfix$i  ========== Config File \n" ;
echo -e "==================================== ================================================= \n" ;

REMOTE_COMMAND1="grep -i $con /opt/fxall/logs/*mdg.log|grep -v '35=A' |grep '35=.*' |tr '\01' '\|' |tail -10";
SSH2_OUTPUT=$(ssh -q -T -o StrictHostKeyChecking=no "$USERNAME@$HOSTNAME" "$REMOTE_COMMAND1");

REMOTE_COMMAND3="grep -i $con /opt/fxall/logs/*mdg.log|grep '35=A'|tr '\01' '\|'|tail -5";
SSH3_OUTPUT=$(ssh -q -T -o StrictHostKeyChecking=no "$USERNAME@$HOSTNAME" "$REMOTE_COMMAND3");

#SSH4_output=tail -2 "$SSH3_OUTPUT \n";

if [[ -z "$SSH2_OUTPUT" ]];   # to check Empty String
then
echo -e "Banks Stream Fix Details Not Found on server: nyintaggfix$i \n"
else
echo -e "Banks Stream last 10 Messages \n" 
echo -e "$SSH2_OUTPUT \n"
echo -e "Banks Stream Logon Message \n" 
echo -e "$SSH3_OUTPUT \n"

fi

REMOTE_COMMAND2="sed -n '/Sender MD  Target $con/ , /Sender MD  Target/p' /opt/fxall/logs/*mdg.log";
SSH1_OUTPUT=$(ssh -q -T -o StrictHostKeyChecking=no "$USERNAME@$HOSTNAME" "$REMOTE_COMMAND2");

if [[ $SSH1_OUTPUT -lt 1 ]];  # empty String
then
echo -e "Banks Stream Config Details Not Found on server: nyintaggfix$i \n"
else
echo -e "$SSH1_OUTPUT \n"
fi

done
}


fcgemb()
{
con1=$1
echo "Checking following hosts for connection Details $con1"

for i in 07 13
do
echo -e "==================================== ================================================= \n" ;
echo -e "Checking on this Server  nyatint$i  ========== Config File \n" ;
echo -e "==================================== ================================================= \n" ;
ssh -q nyatint$i "hostname; grep -iC7 $con1 /opt/fxall/fcg*/config/fcgemb.props |sed -n '/SenderCompID/ , /TargetCompID/p'"
echo -e "==================================== ================================================= \n" ;
echo -e "Found on this Server  nyatint$i  ========== Secondaray Check \n" ;
echo -e "==================================== ================================================= \n" ;
ssh -q nyatint$i "hostname; grep -i $con1 /opt/fxall/fcg*/config/efix.props "
echo -e "==================================== ================================================= \n" ;
echo -e "Found on this Server  nyatint$i  ========== Config File \n" ;
echo -e "==================================== ================================================= \n" ;
ssh -q nyatint$i "hostname; grep -iC7 $con1 /opt/fxall/fcg*/config/fcgemb.props |sed -n '/SenderCompID/ , /TargetCompID/p' | awk -F '/' '{print \$4}' |uniq -d "
done
}



case $var11 in
           1) login_message $var12 ;;
		   2) fcgemb  $var12 ;;
		   *) echo "Invalid Number" ;;
esac

#############################################################################################################################
