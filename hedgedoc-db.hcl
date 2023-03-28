job "hedgedoc-db" {
    datacenters = ["dc1"]
    type = "service"

    meta {
        user = "TCJfqYSmSxVD8COHvCvqdWnlrkm2"
    }

    group "hedgedoc-db" {
        network {
            mode = "host"
            port "db" {
                to = 5432
            }
        }

        service {
            name = "hedgedoc-db"
            port = "db"
            provider = "nomad"
        }

        task "hedgedoc-db" {
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
                    type = "volume"
                    source = "TCJfqYSmSxVD8COHvCvqdWnlrkm2-hedgedoc-db"
                    target = "/var/lib/postgresql/data"
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
