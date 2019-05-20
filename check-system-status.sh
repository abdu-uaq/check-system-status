#!/bin/bash 
#
#Script Name : check-system-status.sh
#Description : This script will report on the status of a Linux system,
#              including processes taking the most RAM and CPU, disk,
#              recent logins, sudos, and changes, ...
#              The initial goal of this script is to aid in troubleshooting
#              servers.
#Author      : Chris Lamke
#Copyright   : 2019 Christopher R Lamke
#License     : MIT - See https://opensource.org/licenses/MIT
#Last Update : 2019 May 12
#Version     : 0.1  
#Usage       : ./check-system-status.sh
#Notes       : 
#

# Report header and data display formats
reportLabelDivider="--------------------"
subReportHeader="****************"
subReportFooter="****************"
headerFormat="%-10s %-13s %-13s %-24s %-8s"
dataFormat="%-10s %-13s %-13s %-24s %-8s"

# Paths to external tools if needed

# Constants to define function behavior
topProcessCount=5


# Name: reportHeader
# Parameters: none
# Description: Report on processes consuming the most RAM and CPU
function reportHeader
{
  # Print headers and data such as hostname and IP
  # that won't change over script run.
  hostName=$(hostname)
  hostIP=$(hostname -i)
  printf "\n\n%s %s %s\n" $reportLabelDivider "System Status Report" $reportLabelDivider
  printf "\nHostname: %s\tHost IP: %s\n" $hostName $hostIP
}

# Name: reportTopProcesses
# Parameters: none
# Description: Report on processes consuming the most RAM and CPU
function reportTopProcesses()
{
  printf "\n%s %s %s\n" "$subReportHeader" "Top Processes" "$subReportHeader" 
  # Add one to topProcessCount to account for showing the header line.
  processLinesToShow=$(($topProcessCount+1))
  printf "Top %s processes by CPU\n" $topProcessCount
  ps -Ao pcpu,comm,pid,user,uid,pmem,cmd --sort=-pcpu | head -n $processLinesToShow
  printf "\nTop %s processes by RAM\n" $topProcessCount
  ps -Ao pmem,pcpu,comm,pid,user,uid,pcpu,cmd --sort=-pmem | head -n $processLinesToShow
}


# Name: reportDiskStatus
# Parameters: none
# Description: Report on disk status, usage and mounts
function reportDiskStatus()
{
  printf "\n%s %s %s\n" "$subReportHeader" "Disk Status" "$subReportHeader" 
  printf "Disk Status using \"df -klh\"\n"
  df -klh
}


# Name: reportAnomalousProcesses
# Parameters: none
# Description: Report zombie, orphan, and other potentially anomalous processes
function reportAnomalousProcesses()
{
  printf "\n%s %s %s\n" "$subReportHeader" "Anomalous Processes" "$subReportHeader" 
  printf "Checking for zombie processes using \"ps axo pid=,stat= | awk '$2~/^Z/ { print $1 }'\"\n"
  ps axo pid=,stat= | awk '$2~/^Z/ { print $1 }'
  printf "Checking for orphan processes - not yet implemented\n"
}


# Name: reportRecentUsers
# Parameters: none
# Description: Report recently logged in users
function reportRecentUsers()
{
  printf "\n%s %s %s\n" "$subReportHeader" "Recent Users" "$subReportHeader" 
  printf "Current users and their activities using \"w\"\n"
  w
  printf "\nRecently logged in users using \"last\"\n"
  last -F -n 10
}


# Name: reportRecentPackageChanges
# Parameters: none
# Description: Report recent system changes via yum
function reportRecentPackageChanges()
{
  printf "\n%s %s %s\n" "$subReportHeader" "Recent Package Changes" "$subReportHeader" 
  printf "yum history\n"
  yum history
}


# Name: reportCurrentStatus
# Parameters: none
# Description: Report current system status
function reportCurrentStatus
{
  printf "\n%s %s %s\n" $reportLabelDivider "Current System Status" $reportLabelDivider

  reportTopProcesses

  reportDiskStatus

  reportRecentUsers

  reportAnomalousProcesses
}

# Name: reportRecentEvents
# Parameters: none
# Description: Report current system status
function reportRecentEvents
{
  printf "\n%s %s %s\n" $reportLabelDivider "Recent System Events" $reportLabelDivider

  reportRecentPackageChanges
}


# Name: reportSuggestions
# Parameters: none
# Description: Report current system status
function reportSuggestions
{
  printf "\n%s %s %s\n" $reportLabelDivider "Troubleshooting Suggestions" $reportLabelDivider
  printf "\nSuggestions not yet implemented\n"

}


# Name: reportFooter
# Parameters: none
# Description: Report on processes consuming the most RAM and CPU
function reportFooter
{
  hostName=$(hostname)
  hostIP=$(hostname -i)
  printf "\n\nHostname: %s\tHost IP: %s\n" $hostName $hostIP
  printf "\n%s %s %s\n" $reportLabelDivider "End System Status Report" $reportLabelDivider
}

# Trap ctrl + c 
trap ctrl_c INT
function ctrl_c() 
{
  printf "\n\nctrl-c received. Exiting\n"
  exit
}

#First, check that we have sudo permissions so we can gather the info we need.
if [ "$EUID" -ne 0 ]
  then echo "Please run as root/sudo"
  exit
fi


reportHeader

reportCurrentStatus

reportRecentEvents

reportSuggestions

reportFooter

