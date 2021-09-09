#get the data fro the global vars WS
data "terraform_remote_state" "appvm" {
  backend = "remote"
  config = {
    organization = "Lab14"
    workspaces = {
      name = var.appvmwsname
    }
  }
}

data "terraform_remote_state" "global" {
  backend = "remote"
  config = {
    organization = "Lab14"
    workspaces = {
      name = var.globalwsname
    }
  }
}

data "external" "appd" {
  program = ["bash", "./scripts/getappd.sh"]
  query = {
    appname = "${local.appname}"
    accesskey = "${local.accesskey}"
    jver = "${local.javaver}"
    clientid = "${local.clientid}"
    clientsecret = "${local.clientsecret}"
    url = "${local.url}"
  }
#  download = data.external.appd.result["download"]
#  install = data.external.appd.result["install"]


#    clsecrt = "${var.clsecrt}"
#    zerover = "${var.zerover}"
#    infraver = "${var.infraver}"
#    machinever = "${var.machinever}"
#    ibmver = "${var.ibmver}"
#    javaver = "${var.javaver}"
}

variable "appvmwsname" {
  type = string
}
variable "globalwsname" {
  type = string
}

variable "download" {
  type = string
}
variable "install" {
  type = string
}

resource "null_resource" "vm_node_init" {
  #download = data.external.appd.result["download"]
  #install = data.external.appd.result["install"]
  provisioner "file" {
    source = "scripts/"
    destination = "/tmp"
    connection {
      type = "ssh"
      host = "${local.appvmip}"
      user = "root"
      password = "${local.root_password}"
      port = "22"
      agent = false
    }
  }
  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/rbac.sh",
        "${data.external.appd.result["download"]}",
	"/tmp/rbac.sh ${local.nbrapm} ${local.nbrma} ${local.nbrsim} ${local.nbrnet}",
	". /home/ec2-user/environment/workshop/application.env",
	"echo echoing install",
	"echo ${data.external.appd.result["install"]}",
	"echo echoing accesskey",
	"echo $APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY",
	"echo replacement",
	"echo ${data.external.appd.result["install"]} > /tmp/installcmd.sh",
	"sed 's/fillmein/'$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY'/g' /tmp/installcmd.sh > /tmp/installexec.sh",
	"chmod +x /tmp/installexec.sh",
	"echo installing",
	"/tmp/installexec.sh",
    ]
    connection {
      type = "ssh"
      host = "${local.appvmip}"
      user = "root"
      password = "${local.root_password}"
      port = "22"
      agent = false
    }
  }
}


locals {
  appvmip = data.terraform_remote_state.appvm.outputs.vm_ip[0]
  nbrapm = data.terraform_remote_state.global.outputs.nbrapm
  nbrma = data.terraform_remote_state.global.outputs.nbrma
  nbrsim = data.terraform_remote_state.global.outputs.nbrsim
  nbrnet = data.terraform_remote_state.global.outputs.nbrnet
  root_password = yamldecode(data.terraform_remote_state.global.outputs.root_password)
  appname = yamldecode(data.terraform_remote_state.global.outputs.appname)
  accesskey = yamldecode(data.terraform_remote_state.global.outputs.accesskey)
  javaver = yamldecode(data.terraform_remote_state.global.outputs.jver)
  clientid = yamldecode(data.terraform_remote_state.global.outputs.clientid)
  clientsecret = yamldecode(data.terraform_remote_state.global.outputs.clientsecret)
  url = yamldecode(data.terraform_remote_state.global.outputs.url)
  
}

