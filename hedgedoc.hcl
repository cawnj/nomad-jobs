job "hedgedoc" {
    datacenters = ["dc1"]
    type = "service"

    meta {
        user = "TCJfqYSmSxVD8COHvCvqdWnlrkm2"
    }

    group "hedgedoc" {
        network {
            port "http" {
                to = 3000
            }

            port "db" {
                to = 5432
            }
        }

        service {
            name = "hedgedoc"
            port = "http"

            tags = [
                "traefik.enable=true",
                "traefik.http.routers.nomad-hedgedoc.entrypoints=https",
                "traefik.http.routers.nomad-hedgedoc.rule=Host(`md.local.plusvasis.xyz`)",
                "traefik.port=${NOMAD_PORT_http}",
            ]
        }

        task "hedgedoc" {
            driver = "docker"

            env {
                CMD_DB_URL = "postgres://hedgedoc:password@${NOMAD_ADDR_db}/hedgedoc"
                CMD_DOMAIN = "md.local.plusvasis.xyz"
                CMD_PROTOCOL_USESSL = "true"
            }


            config {
                image = "quay.io/hedgedoc/hedgedoc:1.9.4"
                ports = ["http"]

                mount {
                    type = "bind"
                    source = "/opt/nomad/user_data/TCJfqYSmSxVD8COHvCvqdWnlrkm2/hedgedoc"
                    target = "/hedgedoc/public/uploads"
                    readonly = false
                }
                mount {
                    type = "bind"
                    source = "/opt/nomad/user_data/TCJfqYSmSxVD8COHvCvqdWnlrkm2/"
                    target = "/userdata"
                    readonly = false
                }
            }
        }

        task "db" {
            driver = "docker"

            env {
                POSTGRES_USER = "hedgedoc"
                POSTGRES_PASSWORD = "password"
                POSTGRES_DB = "hedgedoc"
            }


            config {
                image = "postgres:13.4-alpine"
                ports = ["db"]

                mount {
                    type = "bind"
                    source = "/opt/nomad/user_data/TCJfqYSmSxVD8COHvCvqdWnlrkm2/hedgedoc-db"
                    target = "/var/lib/postgresql/data"
                    readonly = false
                }
                mount {
                    type = "bind"
                    source = "/opt/nomad/user_data/TCJfqYSmSxVD8COHvCvqdWnlrkm2/"
                    target = "/userdata"
                    readonly = false
                }
            }
        }
    }
}
