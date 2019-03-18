provider "google" {
  project = "<project-name>"
  credentials = "<path-to-the-json-file>"
  region  = "asia-south1"
  zone    = "asia-south1-c"
}


resource "google_compute_instance" "myinstance" {
  name         = "myinstance"
  machine_type = "f1-micro"

  boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

  metadata {
    sshKeys = "station2:ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXation2@dummy2"
       }

  metadata_startup_script = "sudo curl -sSL https://get.docker.com/ | sh && sudo usermod -aG docker `echo $USER` && sudo docker run -d -p 80:80 nginx"
  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  tags = ["docker-hosts"]
}

resource "google_compute_firewall" "http-server" {
   name    = "default-allow-http"
   network = "default"

   allow {
     protocol = "tcp"
     ports    = ["80"]
     }
    // Apply the firewall rule to allow external IPs to access this instance
    // Allow traffic from everywhere to instances with an http-server tag
   source_ranges = ["0.0.0.0/0"]
   target_tags   = ["docker-hosts"]
}

output "ip" {
  value = "${google_compute_instance.myinstance.network_interface.0.access_config.0.nat_ip}"
}

