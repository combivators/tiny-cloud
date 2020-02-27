#!/bin/sh
# source JDK distribution names
# update from https://jdk.java.net/java-se-ri/11
export JDK_VERSION="11+28"
export JDK_URL="https://download.java.net/openjdk/jdk11/ri/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz"
export JDK_HASH_URL="https://download.java.net/openjdk/jdk11/ri/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz.sha256"
export JDK_ARJ_FILE="openjdk-${JDK_VERSION}.tar.gz"
export JDK_HASH_FILE="${JDK_ARJ_FILE}.sha2"
# downlodad JDK to the local file
curl $JDK_URL -L -o $JDK_ARJ_FILE
curl $JDK_HASH_URL -L -o $JDK_HASH_FILE
# verify downloaded file hashsum
echo "Verify downloaded JDK file $JDK_ARJ_FILE:"
#sha256sum -c "$JDK_HASH_FILE"
# target JDK installation names
export OPT="./opt"
export JKD_DIR_NAME="jdk-${JDK_VERSION}"
export JAVA_HOME="${OPT}/jdk-11"
export JAVA_MINIMAL="java"
# extract JDK and add to PATH
echo "Unpack downloaded JDK to ${JAVA_HOME}/:"
mkdir -p "$OPT"
tar xf "$JDK_ARJ_FILE" -C "$OPT"
PATH_ORG=$PATH
export PATH="$PATH:$JAVA_HOME/bin"
java --version
echo "jlink version:"
jlink --version
# build modules distribution
jlink \
 --verbose \
 --add-modules \
    java.base,java.sql,java.naming,java.management,java.se,java.net.http,jdk.net,jdk.httpserver,java.desktop,java.security.jgss,java.instrument \
 --compress 2 \
 --strip-debug \
 --no-header-files \
 --no-man-pages \
 --output "$JAVA_MINIMAL"
rm -fr "$OPT"
export JAVA_HOME=$JAVA_MINIMAL
export PATH="$JAVA_HOME/bin:$PATH_ORG"
java --version
