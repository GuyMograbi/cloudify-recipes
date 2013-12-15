#!/bin/sh

##############################################################################
# This script creates a backup of the /etc/openldap/slapd.d/ configuration   #
# directory if it doesn't already exist then modifies the configuration with #
# new root DN and root pw. It sets the ldap database directory and creates   #
# an initial database if it does not already exist (with containers for      #
# People and Groups. This script must be run as root.                        #
##############################################################################

#
# Inputs
#
echo '$BSWC_INSTALL_PATH:   '${BSWC_INSTALL_PATH}   # /opt/ibm/dsserver
echo '$BSWC_CONFIG_PREFIX:  '${BSWC_CONFIG_PREFIX}  # /mnt/blumeta0/dsserver

echo '$LDAP_IP:             '${LDAP_IP}             # LDAP server IP address
echo '$LDAP_PORT:           '${LDAP_PORT}           # LDAP server port number
echo '$LDAP_PASSWORD:       '${LDAP_PASSWORD}       # LDAP root password
#

dbDIR="${BSWC_INSTALL_PATH}/ldap/Config"
admin='bluldap'
LDAP_ENCRYPTED_PASSWORD=$(${BSWC_INSTALL_PATH}/dsutil/bin/crypt.sh ${LDAP_PASSWORD})
FIRST='NO'
BSWC_CONFIG_PATH="${BSWC_CONFIG_PREFIX}/ldap/Config"

# Make sure slapd is stopped
service slapd stop

# If configuration directory does not exist, this is the initial boot.
if [ ! -d "${BSWC_CONFIG_PATH}" ]; then
  FIRST='YES'
  mkdir -p ${BSWC_CONFIG_PATH}
fi
mkdir -p ${BSWC_INSTALL_PATH}/ldap
ln -s ${BSWC_CONFIG_PATH} ${dbDIR}

if [ ! -d "/etc/openldap/slapd.d.backup/" ]; then
  cp -r /etc/openldap/slapd.d/ /etc/openldap/slapd.d.backup/
fi

# Generate and set the root DN password
ROOTPW=$(slappasswd -s ${LDAP_PASSWORD})
if grep -q olcRootPW /etc/openldap/slapd.d/cn\=config/olcDatabase*bdb.ldif; then
  sed -i "s,olcRootPW:.*,olcRootPW: ${ROOTPW}," \
    /etc/openldap/slapd.d/cn\=config/olcDatabase*bdb.ldif
else
  sed -i "/olcRootDN/a olcRootPW: ${ROOTPW}" \
    /etc/openldap/slapd.d/cn\=config/olcDatabase*bdb.ldif
fi

################################  Fix config  ################################
for file in /etc/openldap/slapd.d/cn\=config/olcDatabase*.ldif
do
  sed -i 's/dc=[-a-z]*,dc=com/dc=blustratus,dc=com/I' ${file}
  sed -i "s/cn=[a-z]*,dc/cn=$admin,dc/I" ${file}
done

# Do not allow v2 binding
sed -i '/olcAllows/d' /etc/openldap/slapd.d/cn\=config.ldif

# Set database directory
sed -i "s,olcDbDirectory:.*,olcDbDirectory: ${dbDIR}," \
  /etc/openldap/slapd.d/cn\=config/olcDatabase*bdb.ldif

# Create an ldap DB_CONFIG file, in this case use the default one
# ONLY DO THIS ON FIRST USE
if [ ${FIRST} == 'YES' ]; then
  cp `rpm -ql openldap-servers | grep DB_CONFIG` ${dbDIR}/DB_CONFIG
fi

# Fix permissions
chown -R ldap:ldap ${BSWC_CONFIG_PATH}
chmod 700 ${BSWC_CONFIG_PATH}

###############################  Start slapd  ################################
service slapd start


##########################  Create initial entries  ##########################
## ONLY DO THIS IF NEW DB ##
if [ ${FIRST} == 'YES' ]; then
  echo Creating default domain
  # This wont work immediately after the slapd daemon has been started (give
  # it a few seconds and its fine though)
  sleep 10
  ldapadd -x -D "cn=$admin,dc=blustratus,dc=com" -w ${LDAP_PASSWORD} <<defaultLDIF
dn: dc=blustratus,dc=com
objectclass: dcObject
objectclass: organization
o: Blu Stratus Offering
dc: blustratus

dn: cn=$admin,dc=blustratus,dc=com
objectclass: organizationalRole
cn: $admin

dn: ou=People,dc=blustratus,dc=com
objectClass: organizationalUnit
objectClass: top
ou: People

dn: ou=Groups,dc=blustratus,dc=com
objectClass: organizationalUnit
objectClass: top
ou: Groups

dn: cn=bluadmin,ou=Groups,dc=blustratus,dc=com
objectclass: top
objectClass: posixGroup
cn: bluadmin
gidNumber: 3000

dn: cn=bludev,ou=Groups, dc=blustratus,dc=com
objectclass: top
objectClass: posixGroup
cn: bludev
gidNumber: 3001

dn: cn=bluusers,ou=Groups, dc=blustratus,dc=com
objectclass: top
objectClass: posixGroup
cn: bluusers
gidNumber: 3002

dn: uid=user1,ou=People,dc=blustratus,dc=com
uid: user1
cn: user1
objectClass: account
objectClass: posixAccount
objectClass: top
loginShell: /bin/bash
uidNumber: 5000
gidNumber: 3000
homeDirectory: /home/user1
gecos: user1

dn: uid=bluadmin,ou=People,dc=blustratus,dc=com
uid: bluadmin
cn: bluadmin
objectClass: account
objectClass: posixAccount
objectClass: top
loginShell: /bin/bash
uidNumber: 5001
gidNumber: 3000
homeDirectory: /home/bluadmin
gecos: bluadmin


dn: uid=bluuser,ou=People,dc=blustratus,dc=com
uid: bluuser
cn: bluuser
objectClass: account
objectClass: posixAccount
objectClass: top
loginShell: /bin/bash
uidNumber: 5002
gidNumber: 3002
homeDirectory: /home/bluadmin
gecos: bluuser


dn: cn=bluadmin,ou=Groups,dc=blustratus,dc =com
changetype: modify
add: memberuid
memberuid: db2inst1
memberuid: user1
memberuid: bluadmin

dn: cn=bluusers,ou=Groups,dc=blustratus,dc =com
changetype: modify
add: memberuid
memberuid: bluuser

defaultLDIF

  # Fix permissions again
  chown -R ldap:ldap ${BSWC_CONFIG_PATH}
fi

sleep 10

ldappasswd -x -D "cn=bluldap,dc=blustratus,dc=com" \
  -w ${LDAP_PASSWORD} \
  -S "uid=user1,ou=People,dc=blustratus,dc=com" \
  -s ${LDAP_PASSWORD}

ldappasswd -x -D "cn=bluldap,dc=blustratus,dc=com" \
  -w ${LDAP_PASSWORD} \
  -S "uid=bluadmin,ou=People,dc=blustratus,dc=com" \
  -s ${LDAP_PASSWORD}

ldappasswd -x -D "cn=bluldap,dc=blustratus,dc=com" \
  -w ${LDAP_PASSWORD} \
  -S "uid=bluuser,ou=People,dc=blustratus,dc=com" \
  -s ${LDAP_PASSWORD}

# Update LDAP information in dswebserver.properies file
${BSWC_INSTALL_PATH}/scripts/updatedswebserver.sh \
  -ldap.host ${LDAP_IP} \
  -ldap.port ${LDAP_PORT} \
  -ldap.root.passwd ${LDAP_ENCRYPTED_PASSWORD}


######################  Change Authconfig to use LDAP  #######################
# Create backup if it doesn't already exist
if [ ! -d /var/lib/authconfig/backup-ldap/ ]; then
  authconfig --savebackup=openldap
fi

authconfig \
  --enableldap \
  --enableldapauth \
  --ldapserver=ldap://${LDAP_IP}:${LDAP_PORT} \
  --ldapbasedn="dc=blustratus,dc=com" \
  --enablemkhomedir \
  --enableforcelegacy \
  --update


################### Add pam.d entry for DB2 authentication ###################
if [ ! -f /etc/pam.d/db2 ]; then
  cat << 'EOF' > /etc/pam.d/db2
#%PAM-1.0
auth    required    pam_env.so
auth    sufficient  pam_unix.so likeauth nullok
auth    sufficient  pam_ldap.so use_first_pass
auth    required    pam_deny.so

account  required   pam_unix.so
account  sufficient pam_succeed_if.so uid < 100 quiet
account  sufficient pam_ldap.so
account  required   pam_permit.so

password requisite  pam_cracklib.so retry=3 dcredit=-1 ucredit=-1
password sufficient pam_unix.so nullok use_authtok md5 shadowremember=3
password sufficient pam_ldap.so  use_first_pass
password required   pam_deny.so

session  required   pam_limits.so
session  required   pam_unix.so
EOF
fi

# Add entry in rsyslog.conf file for slapd
cat >> /etc/rsyslog.conf << EOF
# Send slapd(8c) logs to /var/log/slapd.log
if \$programname == 'slapd' then /var/log/slapd.log
& ~
EOF

# Restart the rsyslog service
service rsyslog restart
sleep 10

exit 0

