#!/bin/sh
#
#  Licensed Materials - Property of IBM
#
#  IBM Cognos Products: DOCS
#
#  (C) Copyright IBM Corp. 2005, 2010
#
#  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with
#  IBM Corp.
#
#  Copyright (C) 2008 Cognos ULC, an IBM Company. All rights reserved.
#  Cognos (R) is a trademark of Cognos ULC, (formerly Cognos Incorporated).
#
# Run the samples in GUI mode.

# REMOVE this when you edit this file.

# CHANGE the following environment variables to point to IBM Cognos on your system.

CRN_HOME=$1
COGNOS_HOST_NAME=$2
COGNOS_DISPATCHER_PORT=$3
COGNOS_USER_ID=$4
COGNOS_USER_PWD=$5
COGNOS_QUERY_MIN_HEAP=$6
COGNOS_QUERY_MAX_HEAP=$7

JAR_HOME=$CRN_HOME/sdk/java/lib
JAVAC=$JAVA_HOME/../bin/javac
JAVA=$JAVA_HOME/bin/java

# Build the CLASSPATH required to build the Java samples
CLASSPATH=$JAVA_HOME/../lib/tools.jar
for jar in \
  activation axis axisCognosClient commons-discovery-0.2 commons-logging-1.1 \
  commons-logging-adapters-1.1 commons-logging-api-1.1 dom4j-1.6.1 \
  jaxen-1.1.1 jaxrpc mail saaj wsdl4j-1.5.1; do
  CLASSPATH="$CLASSPATH:$JAR_HOME/$jar.jar"
done
CLASSPATH="$CLASSPATH:../Common:../Security:../ReportParams:../HandlersCS:..\
/ReportSpec:../ViewCMReports:../ViewCMPackages:../ExecReports:../runreport:..\
/Scheduler:../ContentStoreExplorer"

# Compile
echo $CLASSPATH
$JAVAC -classpath "$CLASSPATH" CognosAdminServices.java

CLASSPATH=
for dir in \
  ../Common ../HandlersCS ../Security ../ReportParams ../ReportSpec \
  ../ViewCMReports ../ViewCMPackages ../ExecReports ../runreport ../Scheduler \
  ../ContentStoreExplorer; do
  CLASSPATH="$CLASSPATH:$dir"
done
for jar in \
  activation axis axisCognosClient commons-discovery-0.2 commons-logging-1.1 \
  commons-logging-adapters-1.1 commons-logging-api-1.1 dom4j-1.6.1 \
  jaxen-1.1.1 jaxrpc mail saaj wsdl4j-1.5.1 ; do
  CLASSPATH="$CLASSPATH:$JAR_HOME/$jar.jar"
done

# Run Content Store Explorer
$JAVA -classpath "$CLASSPATH" \
  CognosAdminServices -c1 $2 -c2 $3 -cu $4 -cp $5 -cminheap $6 -cmaxheap $7
