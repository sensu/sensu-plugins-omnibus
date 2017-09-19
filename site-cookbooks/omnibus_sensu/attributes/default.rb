default["omnibus"]["install_dir"] = "/opt/sensu"
default["omnibus_sensu"]["project_dir"] = "/opt/sensu-plugin-omnibus"
default["omnibus_sensu"]["publishers"] = {
  "artifactory" => {},
  "s3" => {}
}
default["omnibus_sensu"]["windows_target_version"] = "2012r2"
