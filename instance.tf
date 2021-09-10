data "external" "appd" {
  program = ["bash", "./scripts/getappd.sh"]
  query = {
    appname = "${var.appname}"
    accesskey = "${var.accesskey}"
    jver = "${var.javaver}"
    clientid = "${var.clientid}"
    clientsecret = "${var.clientsecret}"
    url = "${var.url}"
  }
#    clsecrt = "${var.clsecrt}"
#    zerover = "${var.zerover}"
#    infraver = "${var.infraver}"
#    machinever = "${var.machinever}"
#    ibmver = "${var.ibmver}"
#    javaver = "${var.javaver}"
}



output "download" {
  value = data.external.appd.result["download"]
}
output "install" {
  value = data.external.appd.result["install"]
}

