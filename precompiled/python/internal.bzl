precompiled = {
    "psycopg2-binary": "//precompiled/python/psycopg2-binary/psycopg2:psycopg2-binary",
}

def is_precompiled(dependency):
    return dependency in precompiled

def map_dependency_precompiled(dependency):
    return precompiled[dependency]
