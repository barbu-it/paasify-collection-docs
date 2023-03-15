# Paasify Collection Documentation

This repos contains the documentation of all official Paasify collections.

## Quickstart

Clone this repo with submodules and `cd` into the project directory:
```
git clone --recurse-submodules git@github.com:barbu-it/paasify-collections.git
cd paasify-collections
```

Create a Python virtualenv:
```
virtualenv .venv
. .venv/bin/activate
```

Install project dependencies:
```
pip install -r requirements.txt
```

To get live documentation:
```
mkdocs serve -a 127.0.0.1:8001
```

Documentation should be available on [http://localhost:8001](http://localhost:8001)
