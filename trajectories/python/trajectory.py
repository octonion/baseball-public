from ctypes import *
import os

lib = cdll.LoadLibrary(os.path.abspath("libtrajectory.so"))
lib.trajectory_.argtypes = [
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float)
    ]

cd0 = c_float(0.4103)
cddot = c_float(0.0044)
cdspin = c_float(0.2043)
w0 = c_float(2069.4111)
theta0 = c_float(7.2023)
tau0 = c_float(25.0000)
rhodata = c_float(1.19)
vdata = c_float(91.0)
thetadata = c_float(27.5)
vwind = c_float(2.0)
spin_rpm = c_float(0.0)
sfact = c_float(0.0)
cdi = c_float(0.0)
distance = c_float(0.0)
tof = c_float(0.0)

lib.trajectory_(byref(cd0),byref(cddot),byref(cdspin),byref(w0),byref(theta0),byref(tau0),byref(rhodata),byref(vdata),byref(thetadata),byref(vwind),byref(spin_rpm),byref(sfact),byref(cdi),byref(distance),byref(tof))

print spin_rpm.value,sfact.value,cdi.value,distance.value,tof.value
