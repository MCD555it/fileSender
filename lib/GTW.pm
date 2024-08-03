package lib::GTW;

use strict;
use warnings;
use feature "switch";
use IO::Compress::Zip qw(zip $ZipError);
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
 
use Exporter qw(import);
 
our @EXPORT_OK = qw( todayIs todayIsNew dateIs getDate getDetails getDetailsSmp getDestDetails getRemoteSiteDetails md5 statThis PGP_This pelCmd pelCmdPlus pelCmdFull mover renamer permission getSiteDetails statThisDB );

my $logDir 		= "D:\\Script\\Log\\";
my $tmpDir 		= "D:\\Script\\Temp\\";
my $statDir		= "D:\\Script\\Statistics";
my $defLocalRep = "D:\\Script\\Sites\\";

my @optionsKeyList 	= qw(proto tkn dir zip pgp ren chmod sign smf);
my $splitter	= ',';

# -----------------------------------------------------------------------------
# todayIs 															SUBROUTINE 
# -----------------------------------------------------------------------------
# Return the time and date in the format:
#
# DDMMYYYY_HHMMSS
# -----------------------------------------------------------------------------
sub todayIs {
	my $type 	= shift;
	my @TodayIs = localtime( time );
	my $Day 	= sprintf("%02d", $TodayIs[3]);
	$TodayIs[4] += 1;
	my $Month 	= sprintf("%02d", $TodayIs[4]);
	my $Year 	= $TodayIs[5] + 1900;
	my $Hour	= sprintf( "%02d", $TodayIs[2]);
	my $YY		= sprintf( "%02d", $Year-2000);
	my $Mins	= sprintf( "%02d", $TodayIs[1]);
	my $Secs	= sprintf( "%02d", $TodayIs[0]);
	my $prevMonth;
	my $Now;
	
	if(      $type eq "SHORT" ) 		{	$Now = $Year.$Month.$Day; 
	}elsif(  $type eq "LONG" )			{	$Now = $Year."\\".$Month."\\".$Day." \@ ".$Hour.":".$Mins.":".$Secs; 
	}elsif(  $type eq "FULLCOMPACT")	{	$Now = $Year.$Month.$Day.$Hour.$Mins.$Secs; 
	}elsif(  $type eq "TIMEONLY" ) 		{	$Now = $Hour.":".$Mins.":".$Secs; 
	}elsif(  $type eq "HHMMSS" ) 		{	$Now = $Hour.$Mins.$Secs; 
	}elsif(( $type eq "DATETIME" ) ||
		   ( $type eq "FULL" ))			{	$Now = "D".$Year.$Month.$Day.".T".$Hour.$Mins.$Secs; 
	}elsif(  $type eq "MINUTE") 		{	$Now = $Mins;
	}elsif(  $type eq "LESS1") 			{	if ($Month eq "01" ) {
												$prevMonth = "12";
												$Year = $Year-1;
											} else {
												$prevMonth 	= sprintf("%02d", $TodayIs[4]-1);
											}
											$Now = $Year.$prevMonth; 
	}elsif(  $type eq "MONTH") 			{	$Now = $Month; 
	}elsif(  $type eq "YYYYMM")			{	$Now = $Year.$Month; 
	}elsif(  $type eq "YYYYMMDD")		{	$Now = $Year.$Month.$Day; 
	}elsif(  $type eq "YYYY-MM-DD")		{	$Now = $Year."-".$Month."-".$Day; 
	}elsif(  $type eq "YYMMDD")			{	$Now = $YY.$Month.$Day; 
	}elsif(  $type eq "DDMMYY")			{	$Now = $Day.$Month.$YY;
	}elsif(  $type eq "DATEONLY")		{	$Now = $Day."/".$Month."/".$Year;
	}elsif(  $type eq "PREVM") 			{	$Now = $Month-1; 		
	}else								{	$Now = $Year.$Month.$Day." \@ ".$Hour.$Mins.$Secs; 
	}
	# 

	return( $Now );
} 


sub todayIsNew {
	my $type 	= shift;
	my @TodayIs = localtime( time );
	my $deltaT	= 0;
	my $specTime;
	my $day 	= substr( $type, 2, 3);
	my %wDay	= (
					"SUN"	=>	0,
					"MON"	=> 	1,
					"TUE"	=> 	2,
					"WED"	=> 	3,
					"THU"	=> 	4,
					"FRI"	=> 	5,
					"SAT"	=>	6,
					"NOW"	=>	0
				);
					
	
	if( 	$type =~ m/^N_/ ){
		if( $wDay{substr( $type, 2, 3)} ne $TodayIs[6] ){
			$deltaT		= ( 7 - $TodayIs[6] + $wDay{substr( $type, 2, 3)});		# Define the delta time
		}
		$type 		= substr( $type, 6 );		# Get the simple date format
	} elsif( $type =~ m/^P_/ ){
		if( $wDay{substr( $type, 2, 3)} ne $TodayIs[6] ){
			$deltaT		= ( $TodayIs[6] + 7 - $wDay{substr( $type, 2, 3)} );		# Define the delta time
		}
		if( $deltaT ge 7 ){ $deltaT = ($deltaT % 7 ); }
		$deltaT 	= -$deltaT;
		$type 		= substr( $type, 6 );     # Get the simple date format
	} 
	$specTime = time + ( $deltaT * 24 * 60 * 60 );
	@TodayIs = localtime( $specTime );
	my $Day 	= sprintf("%02d", $TodayIs[3]);
	$TodayIs[4] += 1;
	my $Month 	= sprintf("%02d", $TodayIs[4]);
	my $Year 	= $TodayIs[5] + 1900;
	my $Hour	= sprintf( "%02d", $TodayIs[2]);
	my $YY		= sprintf( "%02d", $Year-2000);
	my $Mins	= sprintf( "%02d", $TodayIs[1]);
	my $Secs	= sprintf( "%02d", $TodayIs[0]);
	my $prevMonth;
	my $Now;
	
	
	
	if(      $type eq "SHORT" ) 		{	$Now = $Year.$Month.$Day; 
	}elsif(  $type eq "LONG" )			{	$Now = $Year."\\".$Month."\\".$Day." \@ ".$Hour.":".$Mins.":".$Secs; 
	}elsif(  $type eq "FULLCOMPACT")	{	$Now = $Year.$Month.$Day.$Hour.$Mins.$Secs; 
	}elsif(  $type eq "TIMEONLY" ) 		{	$Now = $Hour.":".$Mins.":".$Secs; 
	}elsif(  $type eq "HHMMSS" ) 		{	$Now = $Hour.$Mins.$Secs; 
	}elsif(( $type eq "DATETIME" ) ||
		   ( $type eq "FULL" ))			{	$Now = "D".$Year.$Month.$Day.".T".$Hour.$Mins.$Secs; 
	}elsif(  $type eq "MINUTE") 		{	$Now = $Mins;
	}elsif(  $type eq "LESS1") 			{	if ($Month eq "01" ) {
												$prevMonth = "12";
												$Year = $Year-1;
											} else {
												$prevMonth 	= sprintf("%02d", $TodayIs[4]-1);
											}
											$Now = $Year.$prevMonth; 
	}elsif(  $type eq "MONTH") 			{	$Now = $Month; 
	}elsif(  $type eq "YYYYMM")			{	$Now = $Year.$Month; 
	}elsif(  $type eq "YYYYMMDD")		{	$Now = $Year.$Month.$Day; 
	}elsif(  $type eq "YYYY-MM-DD")		{	$Now = $Year."-".$Month."-".$Day; 
	}elsif(  $type eq "YYMMDD")			{	$Now = $YY.$Month.$Day; 
	}elsif(  $type eq "DDMMYY")			{	$Now = $Day.$Month.$YY;
	}elsif(  $type eq "DATEONLY")		{	$Now = $Day."/".$Month."/".$Year;
	}elsif(  $type eq "PREVM") 			{	$Now = $Month-1; 		
	}else								{	$Now = $Year.$Month.$Day." \@ ".$Hour.$Mins.$Secs; 
	}
	# 

	return( $Now );
}



# -----------------------------------------------------------------------------
# dateIs 															SUBROUTINE 
# -----------------------------------------------------------------------------
# Return the time shifted by (+/-)N from today and return the date in the 
# format:
#
# 	YYYYMMDD
# -----------------------------------------------------------------------------
sub dateIs {
	my $shift 	= shift;
	my $gap 	= $shift*24*60*60;
	my @DateIs = localtime(time-$gap);
	my $Day 	= sprintf("%02d", $DateIs[3]);
	$DateIs[4] += 1;
	my $Month 	= sprintf("%02d", $DateIs[4]);
	my $Year 	= $DateIs[5] + 1900;
	my $Hour	= sprintf( "%02d", $DateIs[2]);
	my $Mins	= sprintf( "%02d", $DateIs[1]);
	my $Secs	= sprintf( "%02d", $DateIs[0]);

	my $dateIs = $Year.$Month.$Day;

	return ($dateIs);
} 

# -----------------------------------------------------------------------------
#                                                          getDate - SUBROUTINE
# -----------------------------------------------------------------------------
sub getDate {
	my $format			= shift;	# [SHORT|LONG|JDATE|YYMMDD]
	my $shifter			= shift;	# numerical (pos|neg values are admitted)
	my $date			= shift;	# specific
	my $now				= time() + (24 * 60 * 60 * $shifter);
	my @dateInfo 		= localtime($now);
	my $response;
	
	#my $timeShift = (24 * 60 * 60) * shift;
	#my 
	$dateInfo[4] 	+= 1;
	my $mm	= sprintf("%02d", $dateInfo[4]);
	my $dd	= sprintf("%02d", $dateInfo[3]);
	my $yy	= $dateInfo[5] - 100;
	
	if ($format eq "SHORT"){
		$response = "D".$yy.$mm.$dd;
	} elsif( $format eq "YYMMDD" ){
		$response = $yy.$mm.$dd;
	}else {
		$response = $dd."-".$mm."-20".$yy;
	}
	
	return( $response ); 
}

exit;