job "http-echo-dynamic" {
  datacenters = ["dc1"]
  type = "service"
  group "http-echo-dynamic" {
    count = 5
    network {
      mode = "bridge" 
      port "http" {}
    }
    service {
      name = "http-echo"
      port = "http"
      provider = "nomad"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http-echo.entrypoints=https",
        "traefik.http.routers.http-echo.rule=Host(`http-echo.plusvasis.xyz`)",
      ]
    }
    task "server" {
      driver = "docker"
      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":${NOMAD_PORT_http}",
          "-text", "Hello and welcome to ${NOMAD_IP_http} running on port ${NOMAD_PORT_http} via Nomad!",
        ]
        ports = ["http"]
      }
    }
  }
}
