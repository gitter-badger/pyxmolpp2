#include "xmol/geometry/alignment.h"

#include "init.h"

#include <pybind11/stl_bind.h>

using namespace xmol::geometry;

PYBIND11_MAKE_OPAQUE(std::vector<XYZ>);

void pyxmolpp::geometry::init_alignment(pybind11::module& geometry) {

  py::bind_vector<std::vector<XYZ>>(geometry, "VectorXYZ",
                                    py::module_local(false));

  geometry.def("calc_alignment", xmol::geometry::calc_alignment, py::arg("ref"),
               py::arg("var"),
               R"pydoc(
    Calculate transformation to superimpose var over ref

    Preconditions:
       1) len(ref) == len(var)
       2) len(ref) >= 3
)pydoc");
  geometry.def("calc_geom_center", xmol::geometry::calc_geom_center,
               py::arg("coords"), "Returns mean coordinates");
  geometry.def("calc_rmsd",
               (double (*)(const std::vector<XYZ>&,
                           const std::vector<XYZ>&))xmol::geometry::calc_rmsd,
               py::arg("ref"), py::arg("var"),
               "Calculate RMSD between ref and var");
  geometry.def("calc_rmsd",
               (double (*)(const std::vector<XYZ>&, const std::vector<XYZ>&,
                           const Transformation3d&))xmol::geometry::calc_rmsd,
               py::arg("ref"), py::arg("var"), py::arg("T"),
               "Calculate RMSD between ref and T*var");
}