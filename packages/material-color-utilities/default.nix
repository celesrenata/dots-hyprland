{ lib
, python3Packages
, fetchPypi
}:

python3Packages.buildPythonApplication rec {
  pname = "material-color-utilities";
  version = "0.1.5";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    pillow
    numpy
  ];

  meta = with lib; {
    description = "Material Design color utilities";
    homepage = "https://github.com/material-foundation/material-color-utilities-python";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
