# Copyright 2013 Mojo Lingo LLC.
# Modifications by Red Hat, Inc.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
# == Class openshift_origin
# 
# This is the main class to manage parameters for all OpenShift Origin
# installations.
# 
# === Parameters
# [*roles*]
#   Choose from the following roles to be configured on this node.
#     * broker    - Installs the broker and console.
#     * node      - Installs the node and cartridges.
#     * activemq  - Installs activemq message broker.
#     * datastore - Installs MongoDB (not sharded/replicated)
#     * named     - Installs a BIND dns server configured with a TSIG key for updates.
#   Default: ['broker','node','activemq','datastore','named']
# 
# [*install_method*]
#   Choose from the following ways to provide packages:
#     none - install sources are already set up when the script executes (default)
#     yum - set up yum repos manually
#       * repos_base
#       * os_repo
#       * os_updates_repo
#       * jboss_repo_base
#       * jenkins_repo_base
#       * optional_repo
#   Default: yum
# 
# [*repos_base*]
#   Base path to repository for OpenShift Origin
#   Nightlies:
#     Fedora: https://mirror.openshift.com/pub/origin-server/nightly/fedora-19
#     RHEL:   https://mirror.openshift.com/pub/origin-server/nightly/rhel-6
#   Release-2:
#     Fedora: https://mirror.openshift.com/pub/origin-server/release/2/fedora-19
#     RHEL:   https://mirror.openshift.com/pub/origin-server/release/2/rhel-6
#   Default: Fedora-19 Nightlies
# 
# [*override_install_repo*]
#   Repository path override. Uses dependencies from repos_base but uses 
#   override_install_repo path for OpenShift RPMs. Used when doing local builds.
#   Default: none
#   
# [*os_repo*]
#   The URL for a Fedora 19/RHEL 6 yum repository used with the "yum" install method.
#   Should end in x86_64/os/.
#   Default: no change
#   
# [*os_updates*]
#   The URL for a Fedora 19/RHEL 6 yum updates repository used with the "yum" install method.
#   Should end in x86_64/.
#   Default: no change
#   
# [*jboss_repo_base*]
#   The URL for a JBoss repositories used with the "yum" install method.
#   Does not install repository if not specified.
#   
# [*jenkins_repo_base*]
#   The URL for a Jenkins repositories used with the "yum" install method.
#   Does not install repository if not specified.
#   
# [*optional_repo*]
#   The URL for a EPEL or optional repositories used with the "yum" install method.
#   Does not install repository if not specified.
# 
# [*domain*]
#   Default: example.com
#   The network domain under which apps and hosts will be placed.
# 
# [*broker_hostname*]
# [*node_hostname*]
# [*named_hostname*]
# [*activemq_hostname*]
# [*datastore_hostname*]
#   Default: the root plus the domain, e.g. broker.example.com - except
#   named=ns1.example.com 
# 
#   These supply the FQDN of the hosts containing these components. Used
#   for configuring the host's name at install, and also for configuring
#   the broker application to reach the services needed.
# 
#   IMPORTANT NOTE: if installing a nameserver, the script will create
#   DNS entries for the hostnames of the other components being 
#   installed on this host as well. If you are using a nameserver set
#   up separately, you are responsible for all necessary DNS entries.
# 
# [*named_ip_addr*]
#   Default: IP of a named instance or current IP if installing on this 
#   node. This is used by every node to configure its primary name server.
#   Default: the current IP (at install)  
#   
# [*bind_key*]
#   When the nameserver is remote, use this to specify the HMAC-MD5 key
#   for updates. This is the "Key:" field from the .private key file
#   generated by dnssec-keygen. This field is required on all nodes. 
#   
# [*bind_krb_keytab*]
#   When the nameserver is remote, Kerberos keytab together with principal
#   can be used instead of the HMAC-MD5 key for updates.
#   
# [*bind_krb_principal*]
#   When the nameserver is remote, this Kerberos principal together with
#   Kerberos keytab can be used instead of the HMAC-MD5 key for updates.
#   
# [*conf_named_upstream_dns*]
#   List of upstream DNS servers to use when installing named on this node.
#   Default: ['8.8.8.8']
# 
# [*broker_ip_addr*]
#   Default: the current IP (at install)
#   This is used for the node to record its broker. Also is the default
#   for the nameserver IP if none is given.
# 
# [*node_ip_addr*]
#   Default: the current IP (at install)
#   This is used for the node to give a public IP, if different from the
#   one on its NIC.
# 
# [*no_ntp*]
#   Default: false
#   Enabling this option prevents the installation script from
#   configuring NTP.  It is important that the time be synchronized
#   across hosts because MCollective messages have a TTL of 60 seconds
#   and may be dropped if the clocks are too far out of synch.  However,
#   NTP is not necessary if the clock will be kept in synch by some
#   other means.
# 
# Passwords used to secure various services. You are advised to specify
# only alphanumeric values in this script as others may cause syntax
# errors depending on context. If non-alphanumeric values are required,
# update them separately after installation.
# 
# [*activemq_admin_password*]
#   Default: scrambled
#   This is the admin password for the ActiveMQ admin console, which is
#   not needed by OpenShift but might be useful in troubleshooting.
# 
# [*mcollective_user*]
# [*mcollective_password*]
#   Default: mcollective/marionette
#   This is the user and password shared between broker and node for
#   communicating over the mcollective topic channels in ActiveMQ. Must
#   be the same on all broker and node hosts.
# 
# [*mongodb_admin_user*]
# [*mongodb_admin_password*]
#   Default: admin/mongopass
#   These are the username and password of the administrative user that
#   will be created in the MongoDB datastore. These credentials are not
#   used by in this script or by OpenShift, but an administrative user
#   must be added to MongoDB in order for it to enforce authentication.
#   Note: The administrative user will not be created if
#   CONF_NO_DATASTORE_AUTH_FOR_LOCALHOST is enabled.
# 
# [*mongodb_broker_user*]
# [*mongodb_broker_password*]
#   Default: openshift/mongopass
#   These are the username and password of the normal user that will be
#   created for the broker to connect to the MongoDB datastore. The
#   broker application's MongoDB plugin is also configured with these
#   values.
#   
# [*mongodb_name*]
#   Default: openshift_broker
#   This is the name of the database in MongoDB in which the broker will
#   store data.
# 
# [*openshift_user1*]
# [*openshift_password1*]
#   Default: demo/changeme
#   This user and password are entered in the /etc/openshift/htpasswd
#   file as a demo/test user. You will likely want to remove it after
#   installation (or just use a different auth method).
# 
# [*conf_broker_auth_salt*]
# [*conf_broker_auth_public_key*]
# [*conf_broker_auth_private_key*]
# [*conf_broker_auth_key_password*]
#   Salt, public and private keys used when generating secure authentication 
#   tokens for Application to Broker communication. Requests like scale up/down 
#   and jenkins builds use these authentication tokens. This value must be the 
#   same on all broker nodes.
#   Default:  Self signed keys are generated. Will not work with multi-broker 
#             setup.
#   
# [*conf_broker_session_secret*]
# [*conf_console_session_secret*]
#   Session secrets used to encode cookies used by console and broker. This 
#   value must be the same on all broker nodes.
#   
# [*conf_valid_gear_sizes*]
#   List of all gear sizes this will be used in this OpenShift installation.
#   Default: ['small']
# 
# [*broker_dns_plugin*]
#   DNS plugin used by the broker to register application DNS entries.
#   Options:
#     * nsupdate - nsupdate based plugin. Supports TSIG and GSS-TSIG based 
#                  authentication. Uses bind_key for TSIG and bind_krb_keytab, 
#                  bind_krb_principal for GSS_TSIG auth.
#     * avahi    - sets up a MDNS based DNS resolution. Works only for 
#                  all-in-one installations.
# [*broker_auth_plugin*]
#   Authentication setup for users of the OpenShift service.
#   Options:
#     * mongo         - Stores username and password in mongo.
#     * kerberos      - Kerberos based authentication. Uses 
#                       broker_krb_service_name, broker_krb_auth_realms,
#                       broker_krb_keytab values.
#     * htpasswd      - Stores username/password in a htaccess file.
#     * ldap          - LDAP based authentication. Uses broker_ldap_uri
#   Default: htpasswd
# 
# [*broker_krb_service_name*]
#   The KrbServiceName value for mod_auth_kerb configuration
# 
# [*broker_krb_auth_realms*]
# The KrbAuthRealms value for mod_auth_kerb configuration
# 
# [*broker_krb_keytab*]
#   The Krb5KeyTab value of mod_auth_kerb is not configurable -- the keytab
#   is expected in /var/www/openshift/broker/httpd/conf.d/http.keytab
#
# [*broker_ldap_uri*]
#   URI to the LDAP server (e.g. ldap://ldap.example.com:389/ou=People,dc=my-domain,dc=com).
#   Set <code>broker_auth_plugin</code> to <code>ldap</code> to enable
#   this feature.
# 
# [*node_container_plugin*]
#   Specify the container type to use on the node.
#   Options:
#     * selinux - This is the default OpenShift Origin container type.
# 
# [*node_frontend_plugins*]
#   Specify one or more plugins to use register HTTP and web-socket connections 
#   for applications.
#   Options:
#     * apache-mod-rewrite  - Mod-Rewrite based plugin for HTTP and HTTPS 
#         requests. Well suited for installations with a lot of 
#         creates/deletes/scale actions.
#     * apache-vhost        - VHost based plugin for HTTP and HTTPS. Suited for 
#         installations with less app create/delete activity. Easier to 
#         customize.
#     * nodejs-websocket    - Web-socket proxy listening on ports 8000/8444
#   Default: ['apache-mod-rewrite','nodejs-websocket']
#   
# [*node_unmanaged_users*]
#   List of user names who have UIDs in the range of OpenShift gears but must be 
#   excluded from OpenShift gear setups.
#   Default: []
# 
# [*conf_node_external_eth_dev*]
#   External facing network device. Used for routing and traffic control setup.
#   Default: eth0
# 
# [*conf_node_supplementary_posix_groups*]
#   Name of supplementary UNIX group to add a gear to.
# 
# [*install_jbossews_cartridge*]
# [*install_jbosseap_cartridge*]
# [*install_jbossas_cartridge*]
#   Toggles to enable/disable installation of specific JBoss cartridges.
#   Default: false
# 
# [*development_mode*]
#   Set development mode and extra logging. 
#   Default: false
# 
# [*install_login_shell*]
#   Install a Getty shell which displays DNS, IP and login information. Used for 
#   all-in-one VM installation.
# 
# [*register_host_with_named*]
#   Setup DNS entries for this host in a locally installed bind DNS instance.
#   Default: false
# 
# == Manual Tasks
# 
# This script attempts to automate as many tasks as it reasonably can.
# Unfortunately, it is constrained to setting up only a single host at a
# time. In an assumed multi-host setup, you will need to do the 
# following after the script has completed.
# 
# 1. Set up DNS entries for hosts
#    If you installed BIND with the script, then any other components
#    installed with the script on the same host received DNS entries.
#    Other hosts must all be defined manually, including at least your
#    node hosts. oo-register-dns may prove useful for this.
# 
# 2. Copy public rsync key to enable moving gears
#    The broker rsync public key needs to go on nodes, but there is no
#    good way to script that generically. Nodes should not have
#    password-less access to brokers to copy the .pub key, so this must
#    be performed manually on each node host:
#       # scp root@broker:/etc/openshift/rsync_id_rsa.pub /root/.ssh/
#    (above step will ask for the root password of the broker machine)
#       # cat /root/.ssh/rsync_id_rsa.pub >> /root/.ssh/authorized_keys
#       # rm /root/.ssh/rsync_id_rsa.pub
#    If you skip this, each gear move will require typing root passwords
#    for each of the node hosts involved.
# 
# 3. Copy ssh host keys between the node hosts
#    All node hosts should identify as the same host, so that when gears
#    are moved between hosts, ssh and git don't give developers spurious
#    warnings about the host keys changing. So, copy /etc/ssh/ssh_* from
#    one node host to all the rest (or, if using the same image for all
#    hosts, just keep the keys from the image).
class openshift_origin (
  $roles                                = ['broker','node','activemq','datastore','named'],
  $install_method                       = 'yum',
  $repos_base                           = 'https://mirror.openshift.com/pub/origin-server/nightly/fedora-19',
  $override_install_repo                = undef,
  $os_repo                              = undef,
  $os_updates_repo                      = undef,
  $jboss_repo_base                      = undef,
  $optional_repo                        = undef,
  $domain                               = 'example.com',
  $broker_hostname                      = 'broker.example.com',
  $node_hostname                        = 'node.example.com',
  $named_hostname                       = 'ns1.example.com',
  $activemq_hostname                    = 'activemq.example.com',
  $datastore_hostname                   = 'mongodb.example.com',
  $named_ip_addr                        = $ipaddress,
  $bind_key                             = '',
  $bind_krb_keytab                      = '',
  $bind_krb_principal                   = '',
  $broker_ip_addr                       = $ipaddress,
  $node_ip_addr                         = $ipaddress,
  $no_ntp                               = false,  
  $activemq_admin_password              = inline_template('<%= SecureRandon.base64 %>'),
  $mcollective_user                     = 'mcollective',
  $mcollective_password                 = 'marionette',
  $mongodb_admin_user                   = 'admin',
  $mongodb_admin_password               = 'mongopass',
  $mongodb_broker_user                  = 'openshift',
  $mongodb_broker_password              = 'mongopass',
  $mongodb_name                         = 'openshift_broker',
  $openshift_user1                      = 'demo',
  $openshift_password1                  = 'changeme',
  $conf_broker_auth_salt                = undef,
  $conf_broker_auth_key_password        = undef,
  $conf_broker_auth_public_key          = undef,
  $conf_broker_auth_private_key         = undef,
  $conf_broker_session_secret           = undef,
  $conf_console_session_secret          = undef,
  $conf_valid_gear_sizes                = ['small'],
  $broker_dns_plugin                    = 'nsupdate',
  $broker_auth_plugin                   = 'htpasswd',
  $broker_krb_service_name              = '',
  $broker_krb_auth_realms               = '',
  $broker_krb_keytab                    = '',
  $broker_ldap_uri                      = '',
  $node_container_plugin                = 'selinux',
  $node_frontend_plugins                = ['apache-mod-rewrite','nodejs-websocket'],
  $node_unmanaged_users                 = [],
  $conf_node_external_eth_dev           = 'eth0',
  $conf_node_supplementary_posix_groups = '',
  $install_jbossews_cartridge           = false,
  $install_jbosseap_cartridge           = false,
  $install_jbossas_cartridge            = false,
  $development_mode                     = false,
  $conf_named_upstream_dns              = ['8.8.8.8'],
  $install_login_shell                  = false,
  $register_host_with_named             = false,
){
  include openshift_origin::role
  if member( $roles, 'named' ) {
    class{ 'openshift_origin::role::named': }
    if member( $roles, 'broker' )    { Class['openshift_origin::role::named']    -> Class['openshift_origin::role::broker'] }
    if member( $roles, 'node' )      { Class['openshift_origin::role::named']    -> Class['openshift_origin::role::node'] }
    if member( $roles, 'activemq' )  { Class['openshift_origin::role::named']    -> Class['openshift_origin::role::activemq'] }
    if member( $roles, 'datastore' ) { Class['openshift_origin::role::named']    -> Class['openshift_origin::role::datastore'] }
  }
  if member( $roles, 'broker' ) {    class{ 'openshift_origin::role::broker':    } }
  if member( $roles, 'node' ) {      class{ 'openshift_origin::role::node':      } }
  if member( $roles, 'activemq' ) {  class{ 'openshift_origin::role::activemq':  } }
  if member( $roles, 'datastore' ) { class{ 'openshift_origin::role::datastore': } }

  case $::operatingsystem {
    'Fedora': { $ruby_scl_prefix = '' }
    default : { $ruby_scl_prefix = 'ruby193-' }
  }
  
  case $::operatingsystem {
    'Fedora': { $ruby_scl_path_prefix = '' }
    default : { $ruby_scl_path_prefix = '/opt/rh/ruby193/root' }
  }

  if $::operatingsystem == 'Fedora' {
    service { 'NetworkManager-wait-online':
      enable => true,
    }
  }
}
