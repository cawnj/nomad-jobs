job "hedgedoc" {
    datacenters = ["dc1"]
    type = "service"

    meta {
        user = "TCJfqYSmSxVD8COHvCvqdWnlrkm2"
    }

    group "hedgedoc" {
        network {
            mode = "host"
            port "http" {
                to = 3000
            }
        }

        service {
            name = "hedgedoc"
            port = "http"
            provider = "nomad"

            tags = [
                "traefik.enable=true",
                "traefik.http.routers.hedgedoc.entrypoints=https",
                "traefik.http.routers.hedgedoc.rule=Host(`md.local.plusvasis.xyz`)",
                "traefik.port=${NOMAD_PORT_http}",
            ]
        }

        task "hedgedoc" {
            template {
                data = <<EOH
{{ range nomadService "hedgedoc-db" }}
CMD_DB_URL="postgres://hedgedoc:password@{{ .Address }}:{{ .Port }}/hedgedoc"
{{ end }}
EOH

                destination = "secrets/config.env"
                env = true
            }

            driver = "docker"

            env {
                CMD_DOMAIN = "md.local.plusvasis.xyz"
                CMD_PROTOCOL_USESSL = "true"
            }

            config {
                image = "quay.io/hedgedoc/hedgedoc:1.9.4"
                ports = ["http"]

                mount {
                    type = "volume"
                    source = "TCJfqYSmSxVD8COHvCvqdWnlrkm2-hedgedoc"
                    target = "/hedgedoc/public/uploads"
                    readonly = false
                }
                mount {
                    type = "volume"
                    source = "TCJfqYSmSxVD8COHvCvqdWnlrkm2"
                    target = "/userdata"
                    readonly = false
                }
            }
        }
    }
}
