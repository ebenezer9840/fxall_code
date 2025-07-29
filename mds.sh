#!/bin/bash
#######################Help Function #################
show_help()
{
cat <<'EOF'
===================Stream ID =============== 1#StreamID ========================================
#           To find 35=A or 35=0 Message ###### Feed Number 1#Streamid                          #
#           FCGEMB Stream config #### Feed number 2#streamname                                  #
===================Stream Config ========= 2#streamname=========================================
EOF

case $# in
0) echo -n -e " Hello $USER, Choose an option (1#Loginconnectiondetails|2#sendercompid|3#Date): \n "
   read option ;;

1) option=$1 ;;

*) echo "Too many Inputs"
   exit 2 ;;
esac

}

show_help

###############################################Variable#######################
var11=$(echo $option|cut -d '#' -f 1);
echo -e "Entered Value to seach is $var11 \n"; 

var12=$(echo $option|cut -d '#' -f 2);
echo -e "Entered Value to seach is $var12 \n"; 

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
con=$1
echo "Checking following hosts for connection with String $con"

for i in 01 02 03 04
do
echo -e "==================================== ================================================= \n" ;
echo -e "Checking on this Server  nyintaggfix$i  ========== Config File \n" ;
echo -e "==================================== ================================================= \n" ;
ssh -q nyintaggfix$i "hostname; sed -n '/Sender MD  Target $con/ , /Sender MD  Target/p' /opt/fxall/logs/*mdg.log"
echo -e "==================================== ================================================= \n" ;
echo -e "Server nyintaggfix$i  ========== Fix Logon on this server Login \n" ;
echo -e "==================================== ================================================= \n" ;

ssh -q nyintaggfix$i "hostname; grep -i $con /opt/fxall/logs/*mdg.log|grep '35=A' |tail -5;
echo -e "==================================== Heart Beat Message ======================================== \n";
grep -i $con /opt/fxall/logs/*mdg.log|grep '35=.*' |tail -20 "

echo "==================================== =======================================================" ;
echo "End of Server Log nyintaggfix$i" ;
echo "==================================== ====================================" ;
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


######################################################################################################################