#!/bin/bash
# Usage:
# docker build -t black_gallery .
# docker run -it \
#    -v /host/directory/for/output:/output black_gallery:latest \
#    -p Twisted \
#    19.10b0:pyproject-19.10b0.toml \
#    master:pyproject-master.toml

set -e

BLACK_VERSIONS=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -p)
    PKG="$2"
    shift # past argument
    shift # past value
    ;;
  -v)
    VERSION="$2"
    shift # past argument
    shift # past value
    ;;
  *)
    BLACK_VERSIONS+=("$1")
    shift
    ;;

  esac
done
set -- "${BLACK_VERSIONS[@]}"

if [ -z "$PKG" ]; then
  echo "Provide a package with -p"
  exit 1
fi

if [ ! -z "$VERSION" ]; then
  PKG="${PKG}==${VERSION}"
fi

# Bail on undefined variables
set -u

if [ ${#BLACK_VERSIONS[@]} -eq 0 ]; then
  BLACK_VERSIONS+=("master")
fi

echo "Package: $PKG"
echo "Version: $VERSION"
echo "Black versions: ${BLACK_VERSIONS[*]}"

echo "------------------------------------"
read -p "Continue? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo " Aborting."
    exit 1
fi

for version in "${BLACK_VERSIONS[@]}"; do
  BLACK_PKG="Black==${version}"
  TARGET="/output/${version}/${PKG}"
  mkdir -p "${TARGET}"
  echo "Installing ${BLACK_PKG}"
  echo "Running pip install --install-option=--prefix=${TARGET} $PKG"
  pip install --install-option="--prefix=${TARGET}" "$PKG"

  echo "Formatting $PKG with ${BLACK_PKG}; outputting to ${TARGET}"
  black "${TARGET}"
  echo "---"
done
exit 0


black output/
