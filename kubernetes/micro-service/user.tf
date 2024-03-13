# Create kubernetes deployment for cart 

resource "kubernetes_deployment" "kube-user-deployment" {
  metadata {
    name      = "user"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "user"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "user"
      }
    }
    template {
      metadata {
        labels = {
          name = "user"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/user:0.4.7"
          name  = "user"

      env {
        name = "mongo"
        value = "user-db:27017"
      }

      resources {
        limits = {
          cpu = "300m"
          memory = "200Mi"
        }
        requests = {
          cpu = "100m"
          memory = "100Mi"
        }
      }

      port {
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["NET_BIND_SERVICE"]
        }
        read_only_root_filesystem = true
        run_as_non_root = true
        run_as_user = 10001
        /* readOnlyRootFilesystem = true
        runAsNonRoot = true
        runAsUser = 10001 */
      }

     liveness_probe {
         http_get {
              path = "/health"
              port = 80
        }
        initial_delay_seconds = 300
        period_seconds = 3
    }

     readiness_probe {
        http_get {
            path = "/health"
            port = 80
         }
            initial_delay_seconds = 180
            period_seconds = 3
    }
        }
       node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "kube-user-service" {
  metadata {
    name      = "user"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "user"
    }
  }
  spec {
    selector = {
      name = "user"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}



# create kubernetes cart-db deployment


resource "kubernetes_deployment" "kube-user-db-deployment" {
  metadata {
    name      = "user-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "user-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "user-db"
      }
    }
    template {
      metadata {
        labels = {
          name = "user-db"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/user-db:0.3.0"
          name  = "user-db"

       port {
        name = "mongo"
        container_port = 27017
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["CHOWN", "SETGID", "SETUID"]
        }
        read_only_root_filesystem = true
       # readOnlyRootFilesystem = false
            
        }

      volume_mount {
        name = "tmp-volume"
        mount_path = "/tmp"
      }

        }

     volume {
        name = "tmp-volume"
        empty_dir {
            medium = "Memory"
        }
      }
      node_selector = {
        "beta.kubernetes.io/os" = "linux"
      }
      }
    }
  }
}


# service for cart-db

resource "kubernetes_service" "kube-user-db-service" {
  metadata {
    name      = "user-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
        name = "user-db"
    }
  }
  spec {
    selector = {
      name = "user-db"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}
