import pytest
import math

def test_calc_rmsd():
    from pyxmolpp2.geometry import calc_alignment, XYZ, VectorXYZ, calc_rmsd

    a = VectorXYZ([XYZ(1,2,3)])
    b = VectorXYZ([XYZ(3,4,5)])

    assert calc_rmsd(a,b) == pytest.approx( math.sqrt(2**2*3) )

    a = VectorXYZ([XYZ(1,2,3),XYZ(1,2,3)])
    b = VectorXYZ([XYZ(3,4,5),XYZ(1,2,3)])

    assert calc_rmsd(a,b) == pytest.approx( math.sqrt(2**2*3*0.5) )

def test_calc_rmsd_exception():
    from pyxmolpp2.geometry import calc_alignment, XYZ, VectorXYZ, calc_rmsd, GeometryException, Transformation3d

    a = VectorXYZ([])
    with pytest.raises(GeometryException):
        calc_rmsd(a, a)

    with pytest.raises(GeometryException):
        calc_rmsd(a, a, Transformation3d())

    a = [XYZ(1, 2, 3)] * 10

    with pytest.raises(GeometryException):
        calc_rmsd(VectorXYZ(a[:4]), VectorXYZ(a))

    with pytest.raises(GeometryException):
        calc_rmsd(VectorXYZ(a[:4]), VectorXYZ(a), Transformation3d())


def test_calc_geom_center_exception():
    from pyxmolpp2.geometry import calc_geom_center, XYZ, VectorXYZ, calc_rmsd, GeometryException, Transformation3d

    with pytest.raises(GeometryException):
        calc_geom_center(VectorXYZ([]))

    calc_geom_center(VectorXYZ([XYZ(1,2,3)]))



def test_alignment_exception():
    from pyxmolpp2.geometry import calc_alignment, XYZ, VectorXYZ, calc_rmsd, AlignmentError

    a = [XYZ(1, 2, 3)] * 10

    with pytest.raises(AlignmentError):
        calc_alignment(VectorXYZ(a[:2]), VectorXYZ(a[:2]))

    calc_alignment(VectorXYZ(a[:3]), VectorXYZ(a[:3]))

    with pytest.raises(AlignmentError):
        calc_alignment(VectorXYZ(a[:4]), VectorXYZ(a))



def test_calc_alignment():
    from pyxmolpp2.geometry import calc_alignment, XYZ, VectorXYZ, calc_rmsd, Rotation3d, Translation3d, Degrees

    a = VectorXYZ([XYZ(1,2,3),XYZ(1,2,5),XYZ(4,2,7),XYZ(8,1,4)])
    G = Rotation3d(XYZ(7,6,5),Degrees(12))*Translation3d(XYZ(8,-9,1))
    b = VectorXYZ([ G.transform(x) for x in a ])



    G2 = calc_alignment(a,b)
    assert calc_rmsd(a,b) > 1
    assert calc_rmsd(a,b,G2) == pytest.approx(0)





