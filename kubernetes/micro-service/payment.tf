# Create kubernetes deployment for cart 

resource "kubernetes_deployment" "kube-payment-deployment" {
  metadata {
    name      = "payment"
    namespace = kubernetes_namespace.kube-namespace.id
    labels = {
      name = "payment"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "payment"
      }
    }
    template {
      metadata {
        labels = {
          name = "payment"
        }
      }
      spec {
        container {
          image = "weaveworksdemos/payment:0.4.3"
          name  = "payment"

      resources {
        limits = {
          cpu = "200m"
          memory = "200Mi"
        }
        requests = {
          cpu = "99m"
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
       # readOnlyRootFilesystem = true
       # runAsNonRoot = true
       # runAsUser = 10001
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

resource "kubernetes_service" "kube-payment-service" {
  metadata {
    name      = "payment"
    namespace = kubernetes_namespace.kube-namespace.id
  /*   annotations = {
        prometheus.io/scrape: "true"
    } */

    labels = {
        name = "payment"
    }
  }
  spec {
    selector = {
      name = "payment"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}




