group { "puppet": 
        ensure => "present", 
} 
package{
    ["curl"]:
        ensure => "present";
    ["build-essential"]:
        ensure => "present";
    ["mysql-server", "libmysqlclient-dev", "git-core"]:
        ensure => "present";
    ["libxslt-dev", "libxml2-dev"]:
        ensure => "present";
}
