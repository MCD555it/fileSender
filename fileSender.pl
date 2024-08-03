#!/usr/bin/perl -w

# fileSender.pl 
# 
# Aug.24 -  Micro prj to test and learn git
#           Looking for files in a specific directory and try to send to a remote SFTP srv
#           - cfg for config files
#           - log for logging files
#           - tmp for any needs

#use strict;
use warnings;
#use Time::local;
use Env;
use Cwd 'abs_path';
use File::Basename 'dirname';

# code to get absolute paths
my ($BIN_DIR, $LIB_DIR, $TMP_DIR, $LOG_DIR);
BEGIN {
    $BIN_DIR = dirname abs_path __FILE__;
    $LIB_DIR = abs_path "$BIN_DIR/lib";
    $TMP_DIR = abs_path "$BIN_DIR/tmp";
    $LOG_DIR = abs_path "$BIN_DIR/log";
}

# local parms
# Define who am I ;)
#my ( $mySelf, $myDir, $mySuff ) = fileparse( $BIN_DIR );
# ( $mySelf ) 	=~ s/\.[^.]+$//;
my $mySelf = "fileSender";


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Argoumets given during the call
# 0 => Directory where find the files to GET
# 1 => fileKey key to identify the files to push
# 2 => ops post transfer (default move of files into $ARGGV[0]/sent)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
my ($scanDir, $fileKey, $postOps) = @ARGV;
my $filesList 	= $TMP_DIR.'filesList.dat';
my @filesToPush;
my $toPush		= 0;
my $batchCmd 	= $TMP_DIR."/".time().'_batchCmd.dat';
my $sftpCmd     = "/usr/bin/sftp";
my $sftpCfg     = $HOME."/.ssh/config";
my $host        = "deedee";

#
# Looking for a list of files from $scanDir and save them into 
# array @filesToPush
print "Try listing files from $scanDir directory:\n";
opendir( SCAN_DIR, $scanDir ) or die "Cannot open $scanDir due to error: $!\n";
while( defined ( my $file = readdir SCAN_DIR )){
    if( $file =~ m/$fileKey/) {
        if( -f $scanDir.$file){
            my ($ext) = $file =~ /(\.[^.]+)$/;
            if( !$ext || $ext !~ m/.OK/ ){
                push( @filesToPush, $scanDir.$file );
                $toPush++;
            }
        }
    }
}
print "[inf] Found $toPush files to send...\n";
closedir SCAN_DIR;

#
# Create the SFTP batch command file to drive the files upload
# Default post-push command is DELETE of local file
print "[dbg] $batchCmd\n";
open( BATCH_FILE, ">", $batchCmd) or die "Cannot open $batchCmd due to; $!\n";
foreach( @filesToPush ){ 
    print BATCH_FILE "put $_\n",
        "!rm -f $_\n";
}
close( BATCH_FILE );

#
# Generate the SFTP command to push all the files to remote server
# syntax is: 
#   sftp [Host_as_saved_in_.ssh/config] -b $batchCmd
$sftpCmd = "$sftpCmd -F $sftpCfg $host -b $batchCmd";
print "[cmd] $sftpCmd\n";

exit;