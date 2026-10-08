# CI overrides REGISTRY and TAG; the defaults name the image `just build` loads locally.
variable "REGISTRY" {
    default = "ghcr.io/whatishedoing"
}

variable "TAG" {
    default = "dev"
}

group "default" {
    targets = ["toolchain"]
}

target "_common" {
    platforms = ["linux/amd64", "linux/arm64"]
    labels = {
        "org.opencontainers.image.source" = "https://github.com/WhatIsHeDoing/containers"
    }
}

target "toolchain" {
    inherits = ["_common"]
    context  = "images/toolchain"
    tags     = ["${REGISTRY}/toolchain:${TAG}"]
    labels = {
        "org.opencontainers.image.description" = "The gate tools that WhatIsHeDoing repositories run in just verify"
        "org.opencontainers.image.title"       = "toolchain"
    }
}
