
# Create kubernetes deployment for cart 

resource "kubernetes_deployment" "kube-carts-deployment" {
  metadata {
    name      = "carts"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "carts"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "carts"
      }
    }
    template {
      metadata {
        labels = {
          name = "carts"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/carts:0.4.8"
          name  = "carts"

      env {
        name = "JAVA_OPTS"
        value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
      }

      resources {
        limits = {
          cpu = "300m"
          memory = "500Mi"
        }
        requests = {
          cpu = "100m"
          memory = "200Mi"
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
        #privileged = false
        #readOnlyRootFilesystem = true
       # runAsNonRoot = true
        #runAsUser = 10001
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
         
      }
    }
  }
}




# Create kubernetes  for cart service

resource "kubernetes_service" "kube-carts-service" {
  metadata {
    name      = "carts"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "carts"
    }
  }
  spec {
    selector = {
      name = "carts"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}



# create kubernetes cart-db deployment


resource "kubernetes_deployment" "kube-carts-db-deployment" {
  metadata {
    name      = "carts-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "carts-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "carts-db"
      }
    }
    template {
      metadata {
        labels = {
          name = "carts-db"
        }
      }
      spec {
        container {
          image = "mongo"
          name  = "carts-db"

       port {
        name = "mongo"
        container_port = 80
      }

      security_context {
        capabilities {
          drop = ["ALL"]
          add = ["CHOWN", "SETGID", "SETUID"]
        }

        #readOnlyRootFilesystem = false
        read_only_root_filesystem = true
            
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

resource "kubernetes_service" "kube-carts-db-service" {
  metadata {
    name      = "carts-db"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
        name = "carts-db"
    }
  }
  spec {
    selector = {
      name = "carts-db"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}
