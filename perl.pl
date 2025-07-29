#!/usr/local/bin/perl

#use strict;
use DBI;
use DBD::Oracle;
use Getopt::Long;     #to use get options#

###########################################################################
#                        Global Variabl                                   #
###########################################################################
my ($last_login, $help ,$cust, $trade_id) ;
my $dir="/opt/fxall/ux500061/";
my $db="rptit.fxall.com";
my $username="viewer";
my $passwd="iviewer";

####option Library###
GetOptions('help|h|?'  => \$help,
           'last_login|l|L'   => \$last_login,
		   'trade|te|TE'  => \$trade_id,
		   'cust|C|c'  =>  \$cust
		  ) or die "Error in command line arguments\n";


###########################################################################
#               Query Passing Parameter                                   #
###########################################################################

#my $sql_query1 = ("select customer,long_name,max_providers,max_ssp_providers from ADMIN_DATA.CUSTOMERS where customer= '$cust' ") ;

my $sql_query2 = ("select customer,long_name,max_providers,max_ssp_providers from ADMIN_DATA.CUSTOMERS where country= '$cust' ") ;

#my $sql_query3 = ("Select ID,Trade_GTMSID,MESSAGE_ID,EVENT_FAIL_REASON,USER_ID,PROVIDER_NAME,EVENT_DATE,SOURCE,HOST,PROCESS from rpt.TRADE_MESSAGES where TRADE_GTMSID = '$trade_id' ");

##########################Section Started ###################

if ($help)
{
	helpText ();
	exit 0;
}
elsif ($trade_id)
{
my $int = shift ;	
print "Given Input  $int \n" ;
trade_event($int) ;
}
elsif ($last_login)
{
	print "Given Input  $Last_login \n" ;
	lastlogin ();
}
elsif ($cust)
{
	my $int = shift ;
    print "Given Input  $int \n" ;	
    custmax($int) ;
}

else
{
	helpText ();
}


###########################################################################
#                        Database                                         #
###########################################################################

sub Query_execution 
{

($sql_query)  = @_ ;
#print "SQL Query inside DB $sql_query :\n";

my $dbh = DBI->connect("dbi:Oracle:$db", $username, $passwd ) || die( $DBI::errstr . "\n" );
print "Successfully connected to the database.\n";  # SQL query to execute
my $sth = $dbh->prepare($sql_query)
    or die "Failed to prepare statement: $dbh->errstr";
$sth->execute()
    or die "Failed to execute statement: $sth->errstr";
print "Query Results:\n";

# Fetch column names
my @column_names = @{$sth->{NAME_lc}}; # Use NAME_lc for lowercase names, or NAME_uc for uppercase 
# Print the header row
print join("\t", @column_names) . "\n";
# Fetch Row data
while (my @row = $sth->fetchrow_array())
{
    print join("\t", @row), "\n";
}	
$dbh->disconnect();
print "Disconnected from the database.\n";
}


###########################################################################
#                        Functions                                        #
###########################################################################

sub helpText
{
	print <<EOF
###########################################################################
#               Query HELP to use as below                                #
###########################################################################
	script.pl -L(last_login|l)
	script.pl -C(cust|c)
	script.pl -TE(cust|te)      	
Give input in this way to execute the query sample(last_login.pl -l)
###########################################################################
EOF
}

############################################################################

sub trade_event
{
$trade_id = shift;
my $sql_query3 = ("Select ID,Trade_GTMSID,MESSAGE_ID,EVENT_FAIL_REASON,USER_ID,PROVIDER_NAME,EVENT_DATE,SOURCE,HOST,PROCESS from rpt.TRADE_MESSAGES where TRADE_GTMSID = '$trade_id' ");
my $sql_query_f = $sql_query3 ;
print "SQl Query to be passed $sql_query_f \n" ;
print "Getting Data for Trade_id $trade_id \n" ;
Query_execution($sql_query_f);
}

#############################################################################

sub lastlogin
{

my $sql_query2 = ("Select Trade_GTMSID,MESSAGE_ID,MESSAGE_DATE_TIME_STAMP,PROVIDER_NAME,EVENT_DATE,HOST,PROCESS from rpt.TRADE_MESSAGES where message_YYYYMMDD = to_char(sysdate,  'YYYYMMDD') and process not in ('DBINSERTER') and MESSAGE_DATE_TIME_STAMP >= sysdate - interval '10' minute order by MESSAGE_DATE_TIME_STAMP desc fetch first 20 rows only" );

my $sql_query_f = $sql_query2 ;
print "SQl Query to be passed $sql_query_f \n" ;
Query_execution($sql_query_f);

}

###############################################################
sub custmax
{

$cust = shift ;
my $sql_query1 = ("select customer,long_name,max_providers,max_ssp_providers from ADMIN_DATA.CUSTOMERS where customer= '$cust' ") ;
my $sql_query_f = $sql_query1 ;
print "SQl Query to be passed $sql_query_f \n" ;
Query_execution($sql_query_f);

}
#####################################################

