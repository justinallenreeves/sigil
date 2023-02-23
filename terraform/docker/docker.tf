data "docker_registry_image" "base_foundry" {
  name = local.docker_image
}

output "base_foundry_image" {
  value = data.docker_registry_image.base_foundry
}

resource "docker_image" "foundry" {
  name          = data.docker_registry_image.base_foundry.name
  pull_triggers = [data.docker_registry_image.base_foundry.sha256_digest]
  keep_locally  = false
}

output "docker_image" {
  value = docker_image.foundry
}

resource "docker_tag" "latest" {
  source_image = docker_image.foundry.name
  target_image = local.ecr_image_latest
}

resource "docker_registry_image" "foundry" {
  depends_on = [
    docker_image.foundry,
    docker_tag.latest
  ]

  lifecycle {
    replace_triggered_by = [
      docker_image.foundry.sha256_digest
    ]
  }

  name          = local.ecr_image
  keep_remotely = true
}
