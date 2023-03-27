job "tinycore" {
  datacenters = ["dc1"]

  meta {
    user = "TCJfqYSmSxVD8COHvCvqdWnlrkm2"
  }

  group "tinycore" {

    network {
      port "http" { 
        to = -1
      }
      port "ssh" {
        to = -1
      }
    }

    service {
      port = "http"

      check {
        type     = "http"
        port     = "http"
        path     = "/index.html"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "tinycore" {
      template {
        data = <<EOH
      Hello TinyCore!
      EOH

        destination = "local/index.html"
      }

      artifact {
        source = "https://raw.githubusercontent.com/angrycub/nomad_example_jobs/main/qemu/tinycore.qcow2"
        destination = "tinycore.qcow2"
        mode = "file"
      }

      driver = "qemu"

      config {
        image_path = "tinycore.qcow2"

        accelerator = "kvm"

        args = [
          "-device",
          "e1000,netdev=user.0",
          "-netdev",
          "user,id=user.0,hostfwd=tcp::${NOMAD_PORT_http}-:80,hostfwd=tcp::${NOMAD_PORT_ssh}-:22",
#          "-drive", "file=fat:rw:/etc,format=raw,media=disk",
          "-drive", "file=fat:rw:./local,format=raw,media=disk"
        ]
      }
    }
  }
}

