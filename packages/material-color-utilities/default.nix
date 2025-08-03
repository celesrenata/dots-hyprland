{ lib, python3Packages, fetchPypi }:

python3Packages.buildPythonApplication rec {
  pname = "material-color-utilities";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0000000000000000000000000000000000000000000="; # TODO: Get real hash
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    numpy
  ];

  # TODO: Implement proper build and installation
  doCheck = false; # Disable tests for now

  meta = with lib; {
    description = "Material Design color utilities for Python";
    homepage = "https://github.com/material-foundation/material-color-utilities-python";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
