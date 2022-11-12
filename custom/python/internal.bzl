load("@product_container//:requirements.bzl", container_requirement = "requirement")
load("@product_host//:requirements.bzl", host_requirement = "requirement")

def map_dependency_container(dependency):
    if _is_3rdparty(dependency):
        return container_requirement(dependency)
    return _fullname(dependency) + ".container"

def map_dependency_host(dependency):
    if _is_3rdparty(dependency):
        return host_requirement(dependency)
    return dependency

def _is_3rdparty(dependency):
    return "//" not in dependency

def _fullname(dependency):
    if ":" in dependency:
        return dependency
    return dependency + ":" + dependency.split("/")[-1]
